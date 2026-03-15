# Generic Tooling Philosophy

**Upgrade 18 — Phase 6: Autonomous Loop Engine**

Restructures TITAN to maximize generic, model-native tools over specialized integrations. Agents keep specialized *knowledge* but use generic *tools*. This reduces fragility, improves portability, and ensures the framework works across any domain without tool-specific dependencies.

---

## Core Principle

> Every agent prompt should prefer bash-native approaches. The model's strength is *reasoning about* domain problems, not *using* domain-specific tool APIs. A well-crafted bash command with the right flags is more reliable, more inspectable, and more portable than a custom tool wrapper.

---

## Tooling Hierarchy

```
TIER 1 (Always available — generic, model-native):
  bash           — Execute any CLI command
  read/write/edit — File operations
  git            — Version control
  grep/find/rg   — Search across codebase

TIER 2 (Domain helpers — thin wrappers around CLI):
  build:   cmake / make / cargo / npm / gradle    (invoked via bash)
  test:    ctest / vitest / pytest / jest          (invoked via bash)
  lint:    clang-tidy / eslint / clippy / ruff     (invoked via bash)
  format:  clang-format / prettier / rustfmt       (invoked via bash)
  package: codesign / notarize / npm publish       (invoked via bash)

TIER 3 (Environment interaction):
  Browser automation    — Puppeteer / Playwright via MCP or CLI
  Audio host automation — pluginval / test host via CLI
  Screenshot capture    — screencapture / headless browser
  Visual comparison     — pixelmatch / ImageMagick via CLI
  HTTP testing          — curl / httpie via bash

TIER 4 (Specialized — use sparingly):
  Domain-specific analysis tools
  Custom verification scripts
  Platform-specific APIs (CoreAudio, WASAPI)
  IDE/editor integrations
```

### When to Use Each Tier

| Tier | Use When | Example |
|------|----------|---------|
| 1 | Always. Default choice for everything. | `git diff`, `grep -r "TODO"`, `cat src/main.cpp` |
| 2 | Building, testing, linting. But invoke through bash. | `bash -c "cmake --build build && ctest"` |
| 3 | Need to interact with running processes or visual output. | `playwright test`, `pluginval --validate plugin.vst3` |
| 4 | No generic tool can accomplish the task. | Custom FFT analysis script, platform SDK calls |

---

## Good vs Bad Tool Usage Patterns

### Pattern 1: Building a Project

**Bad — Custom build tool:**
```
# Hypothetical custom MCP tool
use_tool("juce-builder", { project: "MyPlugin", config: "Release" })
```
Problems: Tied to one build system, opaque, hard to debug, another dependency.

**Good — Bash with standard tools:**
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel $(nproc)
```
Benefits: Works everywhere cmake does, inspectable, standard flags, no wrapper overhead.

---

### Pattern 2: Running Tests

**Bad — Custom test runner integration:**
```
# Hypothetical specialized tool
use_tool("test-runner", { framework: "catch2", filter: "DSP*", verbose: true })
```

**Good — Bash with test framework CLI:**
```bash
cd build && ctest --output-on-failure -R "DSP" --verbose
```

---

### Pattern 3: Checking Code Quality

**Bad — Custom lint analysis tool:**
```
use_tool("code-analyzer", { file: "src/DSP.cpp", rules: "all" })
```

**Good — Standard linter via bash:**
```bash
clang-tidy src/DSP.cpp -- -Iinclude -std=c++17 2>&1
```

---

### Pattern 4: Reading Build Errors

**Bad — Parsing errors with a custom tool:**
```
use_tool("error-parser", { log: "build.log", format: "structured" })
```

**Good — Read the log directly:**
```bash
# Build and capture errors
cmake --build build 2>&1 | tail -50

# Or search for specific error patterns
grep -n "error:" build/build.log | head -20
```

---

### Pattern 5: Verifying Audio Output

**Bad — Custom audio analysis MCP server:**
```
use_tool("audio-analyzer", { file: "output.wav", check: "not_silence" })
```

**Good — Standard CLI tools:**
```bash
# Check if audio is silence using sox
sox output.wav -n stat 2>&1 | grep "Maximum amplitude"

# Get detailed audio stats
ffprobe -v quiet -print_format json -show_format -show_streams output.wav

# Compare two audio files
sox reference.wav output.wav -n stat 2>&1 | grep "RMS"
```

---

### Pattern 6: Visual Regression Testing

**Bad — Custom screenshot comparison service:**
```
use_tool("visual-diff", { reference: "ref.png", actual: "new.png", threshold: 0.05 })
```

**Good — ImageMagick via bash:**
```bash
# Compare images and get difference metric
compare -metric RMSE reference.png actual.png diff.png 2>&1

# Check if difference exceeds threshold
DIFF=$(compare -metric AE reference.png actual.png null: 2>&1)
if [ "$DIFF" -gt 100 ]; then
  echo "Visual regression detected: $DIFF pixels differ"
  exit 1
fi
```

---

### Pattern 7: Database Verification

**Bad — Custom database tool:**
```
use_tool("db-query", { database: "app.db", query: "SELECT count(*) FROM users" })
```

**Good — sqlite3 via bash:**
```bash
sqlite3 app.db "SELECT count(*) FROM users;"
sqlite3 -json app.db "SELECT * FROM users ORDER BY created_at DESC LIMIT 5;"
```

---

## Decision Framework

When choosing how to accomplish a task, walk through this checklist:

```
1. Can I do this with bash + standard CLI tools?
   YES → Use bash (Tier 1-2)
   NO  → Continue

2. Can I do this with a well-known CLI tool installed via package manager?
   YES → Install it, then use via bash (Tier 2-3)
   NO  → Continue

3. Can I do this with a simple script (< 50 lines)?
   YES → Write the script, run via bash (Tier 3)
   NO  → Continue

4. Does an MCP server or specialized tool already exist?
   YES → Use it, but wrap calls in bash where possible (Tier 3-4)
   NO  → Continue

5. Do I need to build a custom tool?
   YES → Build it as a CLI tool that bash can invoke (Tier 4)
   NO  → Re-examine the problem; you probably can use bash
```

---

## Agent Prompt Guidelines

Every TITAN agent prompt should include this principle:

```
TOOLING PRINCIPLE:
- Prefer bash-native approaches for all operations
- Use standard CLI tools (cmake, ctest, git, grep, curl, jq, sox, ffmpeg, etc.)
- Avoid custom tool wrappers when a bash one-liner would work
- When you need a tool, check if it's available via `which <tool>` first
- If a tool isn't installed, suggest installing it via the system package manager
- Keep specialized knowledge in your reasoning, but use generic tools for execution
```

### What This Means in Practice

The agent for an audio plugin project should:
- **Know** about JUCE architecture, DSP concepts, real-time constraints, AU/VST3 APIs
- **Use** cmake, make, bash, grep, git, sox, ffmpeg, pluginval (all CLI tools)
- **Not require** a custom "JUCE MCP server" or "audio plugin builder tool"

The agent for a web app project should:
- **Know** about React patterns, accessibility, performance budgets, SEO
- **Use** npm, node, curl, jq, playwright CLI, bash
- **Not require** a custom "React analyzer tool" or "web performance MCP server"

---

## Benefits of Generic Tooling

| Benefit | Explanation |
|---------|-------------|
| **Portability** | Same framework works for audio, web, CLI, API, mobile projects |
| **Debuggability** | Every action is a visible bash command you can copy and run manually |
| **No dependency rot** | Standard CLI tools are maintained by large communities |
| **Inspectable** | `git log` shows exactly what commands were run |
| **Composable** | Pipe commands together for complex operations |
| **Offline** | No API keys, no network calls for basic operations |
| **Teachable** | New users already know bash, git, and grep |

---

## Exceptions: When Specialized Tools Are Justified

Specialized tools (Tier 4) are justified when:

1. **No CLI equivalent exists** — e.g., real-time audio monitoring requires platform APIs
2. **Performance is critical** — e.g., embedding generation needs GPU access via a library
3. **The task is inherently interactive** — e.g., browser automation needs a driver protocol
4. **Safety requires it** — e.g., credential management should use a dedicated secrets tool

Even in these cases, wrap the specialized tool in a CLI interface so it can be invoked via bash:

```bash
# Good: specialized tool with CLI interface
python3 scripts/analyze-fft.py --input output.wav --expected-peak 440

# Bad: specialized tool only accessible via API
# POST http://localhost:8080/analyze {"file": "output.wav"}
```
