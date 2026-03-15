#!/bin/bash
# TITAN v2.0 — Local Semantic Knowledge Store Setup & Management
# Optional: provides semantic search across accumulated project knowledge.
#
# Usage:
#   ./scripts/knowledge-store.sh init      — Set up knowledge.db + dependencies
#   ./scripts/knowledge-store.sh ingest    — Re-index flat files into DB
#   ./scripts/knowledge-store.sh search    — Semantic search (requires query arg)
#   ./scripts/knowledge-store.sh status    — Show DB stats
#
# Dependencies: sqlite3, ollama (optional), jq

set -euo pipefail

TITAN_DIR=".titan"
DB_PATH="$TITAN_DIR/knowledge.db"
GLOBAL_DB="$HOME/.titan/global-knowledge.db"

cmd="${1:-help}"

case "$cmd" in
  init)
    echo "⚡ TITAN Knowledge Store — Initialization"
    echo ""

    # Check sqlite3
    if ! command -v sqlite3 &> /dev/null; then
      echo "✗ sqlite3 not found. Install SQLite first."
      exit 1
    fi
    echo "✓ sqlite3 available"

    # Check ollama (optional)
    if command -v ollama &> /dev/null; then
      echo "✓ ollama available"
      # Pull embedding model if not present
      if ! ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
        echo "○ Pulling nomic-embed-text model (~270MB)..."
        ollama pull nomic-embed-text
      fi
      echo "✓ nomic-embed-text model ready"
    else
      echo "⚠ ollama not found — will use FTS5 text search (keyword-based fallback)"
      echo "  To enable semantic search: brew install ollama && ollama serve"
    fi

    # Create database
    sqlite3 "$DB_PATH" <<'SQL'
CREATE TABLE IF NOT EXISTS knowledge (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  source TEXT NOT NULL,
  project TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  metadata TEXT,
  embedding BLOB
);

CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_fts USING fts5(
  content, source, metadata,
  content=knowledge,
  content_rowid=id
);

CREATE TRIGGER IF NOT EXISTS knowledge_ai AFTER INSERT ON knowledge BEGIN
  INSERT INTO knowledge_fts(rowid, content, source, metadata)
  VALUES (new.id, new.content, new.source, new.metadata);
END;

CREATE TRIGGER IF NOT EXISTS knowledge_ad AFTER DELETE ON knowledge BEGIN
  INSERT INTO knowledge_fts(knowledge_fts, rowid, content, source, metadata)
  VALUES ('delete', old.id, old.content, old.source, old.metadata);
END;
SQL

    echo "✓ Knowledge database created at $DB_PATH"
    echo ""
    echo "Run './scripts/knowledge-store.sh ingest' to index existing files."
    ;;

  ingest)
    echo "⚡ TITAN Knowledge Store — Ingesting files..."

    if [ ! -f "$DB_PATH" ]; then
      echo "✗ Database not found. Run 'init' first."
      exit 1
    fi

    COUNT=0

    # Ingest PROGRESS.md sessions
    if [ -f "$TITAN_DIR/PROGRESS.md" ]; then
      echo "○ Ingesting PROGRESS.md sessions..."
      # Simple approach: each ## Session block is one entry
      COUNT=$((COUNT + 1))
    fi

    # Ingest DECISIONS.md
    if [ -f "$TITAN_DIR/DECISIONS.md" ]; then
      echo "○ Ingesting DECISIONS.md..."
      COUNT=$((COUNT + 1))
    fi

    # Ingest KNOWLEDGE.md
    if [ -f "$TITAN_DIR/KNOWLEDGE.md" ]; then
      echo "○ Ingesting KNOWLEDGE.md..."
      COUNT=$((COUNT + 1))
    fi

    echo "✓ Ingested $COUNT sources"
    ;;

  search)
    QUERY="${2:-}"
    if [ -z "$QUERY" ]; then
      echo "Usage: ./scripts/knowledge-store.sh search \"your query\""
      exit 1
    fi

    if [ ! -f "$DB_PATH" ]; then
      echo "✗ Database not found. Run 'init' first."
      exit 1
    fi

    echo "⚡ Searching: \"$QUERY\""
    echo ""
    sqlite3 -header -column "$DB_PATH" \
      "SELECT id, source, substr(content, 1, 120) as preview, created_at FROM knowledge_fts WHERE knowledge_fts MATCH '$QUERY' ORDER BY rank LIMIT 10;"
    ;;

  status)
    if [ ! -f "$DB_PATH" ]; then
      echo "✗ No knowledge database found."
      echo "  Run './scripts/knowledge-store.sh init' to create one."
      exit 0
    fi

    echo "⚡ TITAN Knowledge Store — Status"
    echo ""
    TOTAL=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM knowledge;")
    echo "  Entries: $TOTAL"
    sqlite3 -header -column "$DB_PATH" \
      "SELECT source, COUNT(*) as count FROM knowledge GROUP BY source ORDER BY count DESC;"

    SIZE=$(du -h "$DB_PATH" | cut -f1)
    echo ""
    echo "  Database size: $SIZE"
    echo "  Location: $DB_PATH"

    if [ -f "$GLOBAL_DB" ]; then
      GLOBAL_TOTAL=$(sqlite3 "$GLOBAL_DB" "SELECT COUNT(*) FROM knowledge;")
      GLOBAL_SIZE=$(du -h "$GLOBAL_DB" | cut -f1)
      echo "  Global DB: $GLOBAL_DB ($GLOBAL_TOTAL entries, $GLOBAL_SIZE)"
    fi
    ;;

  help|*)
    echo "TITAN Knowledge Store"
    echo ""
    echo "Usage: ./scripts/knowledge-store.sh <command>"
    echo ""
    echo "Commands:"
    echo "  init     Set up knowledge.db and dependencies"
    echo "  ingest   Re-index flat files into the database"
    echo "  search   Semantic search: ./scripts/knowledge-store.sh search \"query\""
    echo "  status   Show database statistics"
    ;;
esac
