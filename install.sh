#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚡ TITAN — INSTALLER                                       ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Install the TITAN framework for Claude Code and/or OpenCode.
#
# Usage:
#   bash install.sh --global              # Global install (both platforms)
#   bash install.sh --global --claude-only
#   bash install.sh --global --opencode-only
#   bash install.sh --project-dir /path   # Project-local install
#   bash install.sh                       # Auto-detect (global if from TITAN dir)

TITAN_VERSION="2.3.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────

print_banner() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${BOLD}⚡ TITAN${NC} — The Complete Software Development Framework     ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}     Version ${TITAN_VERSION}                                            ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

info()    { echo -e "  ${BLUE}▸${NC} $1"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
error()   { echo -e "  ${RED}✗${NC} $1"; }

check_source_files() {
  local missing=0
  for dir in commands/core commands/power commands/session agents templates domains references; do
    if [ ! -d "${SCRIPT_DIR}/${dir}" ]; then
      error "Missing source directory: ${dir}"
      missing=1
    fi
  done
  if [ $missing -eq 1 ]; then
    error "Source files incomplete. Please re-download TITAN."
    exit 1
  fi
}

# ─── Platform Detection ────────────────────────────────────────

detect_claude_code() {
  if command -v claude &>/dev/null || [ -d "${HOME}/.claude" ]; then
    return 0
  fi
  return 1
}

detect_opencode() {
  if command -v opencode &>/dev/null || [ -d "${HOME}/.opencode" ]; then
    return 0
  fi
  return 1
}

# ─── Install Functions ─────────────────────────────────────────

install_commands() {
  local target_dir="$1"
  local commands_dir="${target_dir}/commands/titan"

  mkdir -p "${commands_dir}"

  # Core commands (numbered)
  for f in "${SCRIPT_DIR}"/commands/core/*.md; do
    [ -f "$f" ] && cp "$f" "${commands_dir}/$(basename "$f")"
  done

  # Power commands
  for f in "${SCRIPT_DIR}"/commands/power/*.md; do
    [ -f "$f" ] && cp "$f" "${commands_dir}/$(basename "$f")"
  done

  # Session commands
  for f in "${SCRIPT_DIR}"/commands/session/*.md; do
    [ -f "$f" ] && cp "$f" "${commands_dir}/$(basename "$f")"
  done

  local count
  count=$(find "${commands_dir}" -name "*.md" -type f | wc -l | tr -d ' ')
  success "Installed ${count} commands → ${commands_dir}"
}

install_agents() {
  local target_dir="$1"
  local agents_dir="${target_dir}/agents"

  mkdir -p "${agents_dir}"

  for f in "${SCRIPT_DIR}"/agents/*.md; do
    [ -f "$f" ] && cp "$f" "${agents_dir}/$(basename "$f")"
  done

  local count
  count=$(find "${agents_dir}" -name "titan-*.md" -type f | wc -l | tr -d ' ')
  success "Installed ${count} agents → ${agents_dir}"
}

install_templates() {
  local target_dir="$1"
  local templates_dir="${target_dir}/templates/titan"

  mkdir -p "${templates_dir}/design"
  mkdir -p "${templates_dir}/domains"
  mkdir -p "${templates_dir}/references"

  # Core templates
  for f in "${SCRIPT_DIR}"/templates/*.md "${SCRIPT_DIR}"/templates/*.yaml; do
    [ -f "$f" ] && cp "$f" "${templates_dir}/$(basename "$f")"
  done

  # Design templates
  for f in "${SCRIPT_DIR}"/templates/design/*.md; do
    [ -f "$f" ] && cp "$f" "${templates_dir}/design/$(basename "$f")"
  done

  # Domain plugins
  for f in "${SCRIPT_DIR}"/domains/*.yaml; do
    [ -f "$f" ] && cp "$f" "${templates_dir}/domains/$(basename "$f")"
  done

  # References
  for f in "${SCRIPT_DIR}"/references/*.md; do
    [ -f "$f" ] && cp "$f" "${templates_dir}/references/$(basename "$f")"
  done

  success "Installed templates → ${templates_dir}"
  success "Installed domain plugins → ${templates_dir}/domains/"
  success "Installed references → ${templates_dir}/references/"

  # Checklists (v2.3)
  if [ -d "${SCRIPT_DIR}/checklists" ]; then
    mkdir -p "${templates_dir}/checklists"
    for f in "${SCRIPT_DIR}"/checklists/*.md; do
      [ -f "$f" ] && cp "$f" "${templates_dir}/checklists/$(basename "$f")"
    done
    local checklist_count
    checklist_count=$(find "${templates_dir}/checklists" -name "*.md" -type f | wc -l | tr -d ' ')
    success "Installed ${checklist_count} domain checklists → ${templates_dir}/checklists/"
  fi
}

install_to_platform() {
  local platform="$1"  # "claude" or "opencode"
  local target_dir="$2"

  info "Installing for ${platform}..."

  install_commands "${target_dir}"
  install_agents "${target_dir}"
  install_templates "${target_dir}"

  # Write version marker
  echo "${TITAN_VERSION}" > "${target_dir}/templates/titan/.titan-version"
  success "Version marker written: ${TITAN_VERSION}"
}

install_global() {
  local install_claude=$1
  local install_opencode=$2

  if [ "$install_claude" = true ]; then
    if detect_claude_code; then
      local claude_dir="${HOME}/.claude"
      mkdir -p "${claude_dir}"
      install_to_platform "Claude Code" "${claude_dir}"
    else
      warn "Claude Code not detected. Skipping. Install Claude Code first, then re-run."
    fi
  fi

  if [ "$install_opencode" = true ]; then
    if detect_opencode; then
      local opencode_dir="${HOME}/.opencode"
      mkdir -p "${opencode_dir}"
      install_to_platform "OpenCode" "${opencode_dir}"
    else
      warn "OpenCode not detected. Skipping."
    fi
  fi
}

install_project() {
  local project_dir="$1"

  if [ ! -d "$project_dir" ]; then
    error "Directory does not exist: ${project_dir}"
    exit 1
  fi

  # Install to .claude/ within the project
  local claude_dir="${project_dir}/.claude"
  mkdir -p "${claude_dir}"
  install_to_platform "project (Claude Code)" "${claude_dir}"

  # Also install to .opencode/ if it exists
  if [ -d "${project_dir}/.opencode" ]; then
    install_to_platform "project (OpenCode)" "${project_dir}/.opencode"
  fi
}

# ─── Parse Arguments ───────────────────────────────────────────

GLOBAL=false
PROJECT_DIR=""
CLAUDE_ONLY=false
OPENCODE_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global|-g)
      GLOBAL=true
      shift
      ;;
    --project-dir|-d)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --claude-only)
      CLAUDE_ONLY=true
      shift
      ;;
    --opencode-only)
      OPENCODE_ONLY=true
      shift
      ;;
    --help|-h)
      print_banner
      echo "Usage:"
      echo "  bash install.sh --global              Install globally (Claude Code + OpenCode)"
      echo "  bash install.sh --global --claude-only Install globally (Claude Code only)"
      echo "  bash install.sh --global --opencode-only Install globally (OpenCode only)"
      echo "  bash install.sh --project-dir /path   Install for a specific project"
      echo "  bash install.sh                        Auto-detect installation target"
      echo ""
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      echo "Run 'bash install.sh --help' for usage."
      exit 1
      ;;
  esac
done

# ─── Main ──────────────────────────────────────────────────────

print_banner
check_source_files

if [ -n "$PROJECT_DIR" ]; then
  # Project-local install
  info "Installing TITAN to project: ${PROJECT_DIR}"
  echo ""
  install_project "$PROJECT_DIR"

elif [ "$GLOBAL" = true ]; then
  # Global install
  local_claude=true
  local_opencode=true

  if [ "$CLAUDE_ONLY" = true ]; then
    local_opencode=false
  fi
  if [ "$OPENCODE_ONLY" = true ]; then
    local_claude=false
  fi

  info "Installing TITAN globally..."
  echo ""
  install_global "$local_claude" "$local_opencode"

else
  # Auto-detect: if running from TITAN framework dir, do global
  if [ -f "${SCRIPT_DIR}/ARCHITECTURE-SPEC.md" ] || [ -f "${SCRIPT_DIR}/README.md" ]; then
    info "Auto-detected: running from TITAN framework directory → global install"
    echo ""
    install_global true true
  else
    error "Cannot auto-detect install target."
    echo "  Use --global for global install, or --project-dir /path for project install."
    exit 1
  fi
fi

# ─── Summary ───────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}⚡ TITAN installed successfully!${NC}                            ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Get started:"
echo "    1. Open your project in Claude Code (or OpenCode)"
echo "    2. Run /titan:01-init to initialize your project"
echo "    3. Follow the Golden Path: init → vision → bootstrap → explore → design → plan → build → verify → ship"
echo ""
echo "  Run /titan:help for the complete command reference."
echo ""
