# Local Semantic Knowledge Store

**Upgrade 20 (Optional) — Phase 6: Autonomous Loop Engine**

A local-first semantic search system for cross-session and cross-project knowledge retrieval. Uses SQLite + sqlite-vec + Ollama for zero-cost, zero-infrastructure semantic search.

---

## Why a Knowledge Store

Each TITAN session starts fresh. The agent re-reads MANIFEST, PROGRESS, and source code every time. But some knowledge is harder to rediscover:

- **Error patterns:** "This build error means X, fix it with Y"
- **Session summaries:** "Session 7 tried approach A, failed because B"
- **Architectural decisions:** "We chose X over Y because Z"
- **Domain knowledge:** "This DSP algorithm requires N samples of latency"

The knowledge store captures these insights and makes them retrievable via semantic search, so future sessions can query "how did we fix the pluginval silence issue?" and get a direct answer.

**This component is OPTIONAL.** The core autonomous loop (Upgrades 12-19) works without it. The file-based approach (MANIFEST.json, PROGRESS.md, git log) remains the primary system. The knowledge store makes long-term retrieval smarter, not possible.

---

## Stack

| Component | Purpose | Why This Choice |
|-----------|---------|----------------|
| **SQLite** | Storage | Zero config, single file, everywhere |
| **sqlite-vec** | Vector similarity search | SQLite extension, no server, C-based |
| **Ollama** | Local LLM inference | Runs locally, free, no API keys |
| **nomic-embed-text** | Embedding model | 768-dim, fast, good quality, 8K context |

**Total infrastructure cost: $0.00/month**

---

## Schema

```sql
-- Core knowledge table
CREATE TABLE IF NOT EXISTS knowledge (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  source TEXT NOT NULL,
  project TEXT,
  category TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  access_count INTEGER DEFAULT 0,
  metadata TEXT,
  embedding BLOB
);

-- Vector index for semantic search
CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_vec USING vec0(
  id INTEGER PRIMARY KEY,
  embedding float[768]
);

-- Full-text search fallback
CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_fts USING fts5(
  content,
  source,
  category,
  project,
  content='knowledge',
  content_rowid='id'
);

-- Triggers to keep FTS in sync
CREATE TRIGGER IF NOT EXISTS knowledge_ai AFTER INSERT ON knowledge BEGIN
  INSERT INTO knowledge_fts(rowid, content, source, category, project)
  VALUES (new.id, new.content, new.source, new.category, new.project);
END;

CREATE TRIGGER IF NOT EXISTS knowledge_ad AFTER DELETE ON knowledge BEGIN
  INSERT INTO knowledge_fts(knowledge_fts, rowid, content, source, category, project)
  VALUES ('delete', old.id, old.content, old.source, old.category, old.project);
END;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_knowledge_project ON knowledge(project);
CREATE INDEX IF NOT EXISTS idx_knowledge_category ON knowledge(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_created ON knowledge(created_at);
```

---

## What Gets Indexed vs What Does Not

### Indexed (semantic search adds value)

| Category | Example | Why Index It |
|----------|---------|-------------|
| Error patterns | "Build error X means Y, fix with Z" | Same errors recur; semantic match finds them even with different wording |
| Session summaries | "Session 7: tried refactoring Reverb, blocked by circular dependency" | Future sessions can query "what happened with reverb?" |
| Architectural decisions | "Chose ring buffer over std::vector for real-time safety" | Prevents re-litigating settled decisions |
| Domain knowledge | "IIR filters need coefficient smoothing to avoid zipper noise" | Specialized knowledge the model may not have |
| Bug fixes | "Crash in processBlock was caused by null channel pointer when sidechain disconnected" | Same bugs often resurface in different forms |
| Performance findings | "FFT size 2048 at 44.1kHz gives 23ms latency, acceptable for reverb" | Saves re-benchmarking |

### NOT Indexed (structured data, better accessed directly)

| Data | Why Not Index |
|------|--------------|
| MANIFEST.json | Structured, always read directly during orientation |
| LOOP-STATE.json | Ephemeral state, changes every session |
| Architecture rules | Declarative JSON, enforced by structural tests |
| Git history | Already searchable with `git log --grep` |
| Source code | Already searchable with grep/ripgrep |
| PROGRESS.md | Read directly during orientation (last N lines) |

---

## Ingest Flow

### Automatic Ingestion (End of Session)

At the end of each session, the loop controller extracts knowledge and ingests it:

```bash
#!/bin/bash
# ingest-session.sh — Extract and store knowledge from a completed session
set -euo pipefail

PROJECT=$(basename "$(pwd)")
SESSION_NUM="$1"
DB="${2:-.titan/knowledge.db}"

# Initialize DB if needed
init_db() {
  sqlite3 "$DB" < scripts/knowledge-schema.sql
}

# Generate embedding via Ollama
embed() {
  local text="$1"
  curl -s http://localhost:11434/api/embeddings \
    -d "{\"model\": \"nomic-embed-text\", \"prompt\": $(echo "$text" | jq -Rs .)}" \
    | jq -r '.embedding | @csv'
}

# Ingest a knowledge entry
ingest() {
  local content="$1"
  local source="$2"
  local category="$3"

  # Generate embedding
  local embedding_csv=$(embed "$content")

  if [ -z "$embedding_csv" ]; then
    echo "  WARNING: Could not generate embedding, inserting without vector"
    sqlite3 "$DB" "INSERT INTO knowledge (content, source, project, category)
      VALUES ('$(echo "$content" | sed "s/'/''/g")', '$source', '$PROJECT', '$category');"
    return
  fi

  # Insert into knowledge table and get ID
  local id=$(sqlite3 "$DB" "INSERT INTO knowledge (content, source, project, category)
    VALUES ('$(echo "$content" | sed "s/'/''/g")', '$source', '$PROJECT', '$category');
    SELECT last_insert_rowid();")

  # Insert into vector index via Python (handles binary blob conversion)
  python3 -c "
import sqlite3, struct
try:
    import sqlite_vec
    db = sqlite3.connect('$DB')
    db.enable_load_extension(True)
    sqlite_vec.load(db)
    embedding = [float(x) for x in '''$embedding_csv'''.split(',')]
    blob = struct.pack(f'{len(embedding)}f', *embedding)
    db.execute('INSERT INTO knowledge_vec (id, embedding) VALUES (?, ?)', ($id, blob))
    db.execute('UPDATE knowledge SET embedding = ? WHERE id = ?', (blob, $id))
    db.commit()
except Exception as e:
    print(f'  Vector insert skipped: {e}')
"

  echo "  Ingested: [$category] ${content:0:80}..."
}

# ─── Extract Knowledge from Session ──────────────────────────────────────

echo "Ingesting knowledge from session $SESSION_NUM"

# 1. Session summary from PROGRESS.md
SUMMARY=$(sed -n "/## Session $SESSION_NUM/,/## Session/p" PROGRESS.md | head -20)
if [ -n "$SUMMARY" ]; then
  ingest "$SUMMARY" "session-$SESSION_NUM" "session_summary"
fi

# 2. Error patterns from session log
if [ -f ".titan/session-${SESSION_NUM}.log" ]; then
  grep -i "error\|fail\|exception" ".titan/session-${SESSION_NUM}.log" \
    | sort -u \
    | head -10 \
    | while read -r line; do
      ingest "Session $SESSION_NUM error: $line" "session-$SESSION_NUM" "error_pattern"
    done
fi

# 3. Git commit messages (contain decisions and changes)
COMMITS=$(git log --oneline --since="1 hour ago" --format="%s" 2>/dev/null || true)
if [ -n "$COMMITS" ]; then
  ingest "Session $SESSION_NUM commits: $COMMITS" "session-$SESSION_NUM" "changes"
fi

echo "Ingestion complete"
```

### Manual Ingestion

```bash
# Add a specific piece of knowledge
titan knowledge add "IIR filter coefficients must be smoothed over 10ms to avoid zipper noise" \
  --category "domain_knowledge" \
  --source "manual"

# Add from a file
titan knowledge add --file docs/architecture-decisions.md \
  --category "decision" \
  --source "docs"
```

---

## Retrieval Flow

### Semantic Search

```bash
#!/bin/bash
# query-knowledge.sh — Semantic search across knowledge store
set -euo pipefail

QUERY="$1"
DB="${2:-.titan/knowledge.db}"
LIMIT="${3:-5}"

# Generate query embedding
QUERY_EMBEDDING=$(curl -s http://localhost:11434/api/embeddings \
  -d "{\"model\": \"nomic-embed-text\", \"prompt\": $(echo "$QUERY" | jq -Rs .)}" \
  | jq -r '.embedding | @csv')

if [ -z "$QUERY_EMBEDDING" ]; then
  echo "Ollama unavailable, falling back to FTS5..."
  sqlite3 -json "$DB" "
    SELECT content, source, category, rank
    FROM knowledge_fts
    WHERE knowledge_fts MATCH '$(echo "$QUERY" | sed "s/'/''/g")'
    ORDER BY rank
    LIMIT $LIMIT;
  "
  exit 0
fi

# Vector similarity search via Python
python3 -c "
import sqlite3, struct, json

try:
    import sqlite_vec
    db = sqlite3.connect('$DB')
    db.enable_load_extension(True)
    sqlite_vec.load(db)

    query_emb = [float(x) for x in '''$QUERY_EMBEDDING'''.split(',')]
    query_blob = struct.pack(f'{len(query_emb)}f', *query_emb)

    results = db.execute('''
        SELECT k.content, k.source, k.category, k.created_at, v.distance
        FROM knowledge_vec v
        JOIN knowledge k ON k.id = v.id
        WHERE v.embedding MATCH ?
        ORDER BY v.distance
        LIMIT ?
    ''', (query_blob, $LIMIT)).fetchall()

    for r in results:
        print(f'[{r[2]}] (distance: {r[4]:.4f}) {r[0][:200]}')
        print(f'  Source: {r[1]} | Created: {r[3]}')
        print()

    # Update access counts
    for r in results:
        db.execute('UPDATE knowledge SET access_count = access_count + 1 WHERE source = ?', (r[1],))
    db.commit()

except Exception as e:
    print(f'Vector search failed: {e}')
    print('Falling back to FTS5...')
    db = sqlite3.connect('$DB')
    cursor = db.execute('''
        SELECT content, source, category
        FROM knowledge_fts
        WHERE knowledge_fts MATCH ?
        ORDER BY rank
        LIMIT ?
    ''', ('$QUERY', $LIMIT))
    for r in cursor:
        print(f'[{r[2]}] {r[0][:200]}')
        print(f'  Source: {r[1]}')
        print()
"
```

### Session Orientation Integration

During session orientation, automatically query relevant knowledge:

```bash
# In session-orientation.sh:

# Get current feature
CURRENT_FEATURE=$(jq -r '.current_feature' .titan/LOOP-STATE.json)

# Query knowledge store for relevant context
echo "## Relevant Knowledge"
echo ""
./scripts/query-knowledge.sh "implementing $CURRENT_FEATURE" .titan/knowledge.db 3
echo ""
./scripts/query-knowledge.sh "errors with $CURRENT_FEATURE" .titan/knowledge.db 3
```

---

## Graceful Degradation

The knowledge store is **optional**. Every component has a fallback:

| Component | Available | Degraded | Fallback |
|-----------|-----------|----------|----------|
| Ollama | Full semantic search | Not installed/not running | grep-based keyword search |
| sqlite-vec | Vector similarity | Extension not available | FTS5 full-text search |
| SQLite DB | Normal operation | DB file missing | Create new DB or skip entirely |
| Knowledge DB | Query returns results | No entries match | Return empty, continue session |

### Fallback Implementation

```bash
#!/bin/bash
# knowledge-query.sh — Query with graceful degradation
set -euo pipefail

QUERY="$1"
DB=".titan/knowledge.db"

# Level 1: Full semantic search (Ollama + sqlite-vec)
if curl -s --connect-timeout 2 http://localhost:11434/api/tags > /dev/null 2>&1; then
  if [ -f "$DB" ]; then
    if python3 -c "
import sqlite3
try:
    import sqlite_vec
    db = sqlite3.connect('$DB')
    db.enable_load_extension(True)
    sqlite_vec.load(db)
    exit(0)
except:
    exit(1)
" 2>/dev/null; then
      echo "[semantic search]"
      ./scripts/query-knowledge.sh "$QUERY" "$DB"
      exit 0
    fi
  fi
fi

# Level 2: FTS5 full-text search (SQLite only, no Ollama needed)
if [ -f "$DB" ]; then
  echo "[full-text search fallback]"
  sqlite3 -json "$DB" "
    SELECT content, source, category
    FROM knowledge_fts
    WHERE knowledge_fts MATCH '$(echo "$QUERY" | sed "s/'/''/g")'
    ORDER BY rank
    LIMIT 5;
  " 2>/dev/null
  exit 0
fi

# Level 3: Grep fallback (no DB at all)
echo "[grep fallback — no knowledge DB]"
grep -ri "$(echo "$QUERY" | tr ' ' '\|')" \
  PROGRESS.md \
  .titan/session-*.log \
  2>/dev/null | head -20

# Level 4: Nothing found
echo "(no relevant knowledge found — continuing without)"
```

**The loop controller (Upgrade 16) NEVER depends on the knowledge store.** It is an enhancement, not a requirement.

---

## Cross-Project Knowledge

Knowledge that applies across projects is stored in a global database:

**Location:** `~/.titan/global-knowledge.db`

Same schema as the project-local database, but the `project` field tracks origin.

### What Goes in Global vs Local

| Knowledge Type | Store | Reason |
|---------------|-------|--------|
| Project-specific error patterns | Local (`.titan/knowledge.db`) | Only relevant to this project |
| Generic build/tool patterns | Global (`~/.titan/global-knowledge.db`) | Applies everywhere |
| Domain knowledge (DSP, web, etc.) | Global | Reusable across projects in same domain |
| Architectural decisions | Local | Project-specific |
| Session summaries | Local | Project-specific |
| Tool configuration tips | Global | Applies everywhere |

### Cross-Project Query

```bash
# Query both local and global knowledge
query_all() {
  local query="$1"
  echo "=== Project Knowledge ==="
  ./scripts/knowledge-query.sh "$query" ".titan/knowledge.db"
  echo ""
  echo "=== Global Knowledge ==="
  ./scripts/knowledge-query.sh "$query" "$HOME/.titan/global-knowledge.db"
}
```

### Promoting Local to Global

```bash
# Promote a useful finding to global knowledge
titan knowledge promote <id>

# This copies the entry from .titan/knowledge.db to ~/.titan/global-knowledge.db
# and sets the project field to the source project name
```

---

## Cost Analysis

| Metric | Value |
|--------|-------|
| Monthly cost | $0.00 (all local) |
| Embedding time | ~50ms per entry (nomic-embed-text on CPU) |
| Storage per entry | ~1KB text + 3KB embedding = ~4KB |
| 1,000 entries | ~4MB |
| 10,000 entries | ~40MB |
| Query latency | ~20ms (sqlite-vec ANN search) |
| Ollama RAM usage | ~2GB for nomic-embed-text |
| SQLite file size | Negligible relative to source code |

### Comparison with Hosted Alternatives

| Solution | Cost/month | Latency | Privacy | Offline |
|----------|-----------|---------|---------|---------|
| **TITAN Knowledge Store** | **$0.00** | **~20ms** | **Full** | **Yes** |
| OpenAI Embeddings + Pinecone | ~$20+ | ~200ms | Shared | No |
| Cohere + Weaviate Cloud | ~$15+ | ~150ms | Shared | No |
| Local ChromaDB + OpenAI | ~$5+ | ~100ms | Partial | No |

---

## Setup

### Prerequisites

```bash
# 1. Install Ollama (if not already installed)
curl -fsSL https://ollama.com/install.sh | sh

# 2. Pull the embedding model
ollama pull nomic-embed-text

# 3. Install sqlite-vec (Python package for the extension)
pip install sqlite-vec

# 4. Initialize the knowledge database
titan knowledge init
```

### Initialization Script

```bash
#!/bin/bash
# knowledge-init.sh — Initialize knowledge store
set -euo pipefail

PROJECT_DB=".titan/knowledge.db"
GLOBAL_DB="$HOME/.titan/global-knowledge.db"

mkdir -p .titan
mkdir -p "$HOME/.titan"

init_db() {
  local db="$1"
  echo "Initializing $db..."

  sqlite3 "$db" << 'SQLEOF'
CREATE TABLE IF NOT EXISTS knowledge (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  source TEXT NOT NULL,
  project TEXT,
  category TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  access_count INTEGER DEFAULT 0,
  metadata TEXT,
  embedding BLOB
);

CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_fts USING fts5(
  content, source, category, project,
  content='knowledge', content_rowid='id'
);

CREATE TRIGGER IF NOT EXISTS knowledge_ai AFTER INSERT ON knowledge BEGIN
  INSERT INTO knowledge_fts(rowid, content, source, category, project)
  VALUES (new.id, new.content, new.source, new.category, new.project);
END;

CREATE TRIGGER IF NOT EXISTS knowledge_ad AFTER DELETE ON knowledge BEGIN
  INSERT INTO knowledge_fts(knowledge_fts, rowid, content, source, category, project)
  VALUES ('delete', old.id, old.content, old.source, old.category, old.project);
END;

CREATE INDEX IF NOT EXISTS idx_knowledge_project ON knowledge(project);
CREATE INDEX IF NOT EXISTS idx_knowledge_category ON knowledge(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_created ON knowledge(created_at);
SQLEOF

  # Try to create vector table (requires sqlite-vec)
  python3 -c "
import sqlite3
try:
    import sqlite_vec
    db = sqlite3.connect('$db')
    db.enable_load_extension(True)
    sqlite_vec.load(db)
    db.execute('''CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_vec
                  USING vec0(id INTEGER PRIMARY KEY, embedding float[768])''')
    db.commit()
    print('  Vector index: enabled')
except ImportError:
    print('  Vector index: unavailable (install sqlite-vec for semantic search)')
except Exception as e:
    print(f'  Vector index: unavailable ({e})')
" 2>/dev/null || echo "  Vector index: skipped (Python or sqlite-vec not available)"

  echo "  Done: $db"
}

# Initialize both databases
init_db "$PROJECT_DB"
init_db "$GLOBAL_DB"

# Check Ollama
if curl -s --connect-timeout 2 http://localhost:11434/api/tags > /dev/null 2>&1; then
  echo ""
  echo "Ollama: running"
  if curl -s http://localhost:11434/api/tags | jq -r '.models[].name' | grep -q "nomic-embed-text"; then
    echo "Embedding model: nomic-embed-text (ready)"
  else
    echo "Embedding model: not found. Run: ollama pull nomic-embed-text"
  fi
else
  echo ""
  echo "Ollama: not running (semantic search will use FTS5 fallback)"
  echo "  To enable: ollama serve && ollama pull nomic-embed-text"
fi

echo ""
echo "Knowledge store initialized."
```

---

## Knowledge Management Commands

| Command | Description |
|---------|-------------|
| `titan knowledge init` | Initialize local and global knowledge databases |
| `titan knowledge add "text"` | Add a knowledge entry |
| `titan knowledge add --file path` | Ingest a file |
| `titan knowledge query "search term"` | Semantic search |
| `titan knowledge list` | Show recent entries |
| `titan knowledge list --category error_pattern` | Filter by category |
| `titan knowledge promote <id>` | Copy entry to global DB |
| `titan knowledge stats` | Show entry counts, DB size, model status |
| `titan knowledge prune --older-than 90d` | Remove old, low-access entries |
| `titan knowledge export` | Export as JSON |
| `titan knowledge import file.json` | Import from JSON |

---

## Integration Points

| System | Integration |
|--------|-------------|
| **Session Orientation** (Upgrade 13) | Query knowledge store for context relevant to next feature |
| **Error Diagnosis** | Search for similar past errors before investigating |
| **Loop Controller** (Upgrade 16) | Auto-ingest session summary at end of each session |
| **Verifier Agent** | Search for known false-positive patterns before flagging |
| **Cross-Project** | Query global DB when encountering unfamiliar patterns |
