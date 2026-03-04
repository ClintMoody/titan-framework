#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════╗
# ║  ⚡ TITAN — UNINSTALLER                                     ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Remove the TITAN framework from Claude Code and/or OpenCode.
#
# Usage:
#   bash uninstall.sh --global              # Remove globally
#   bash uninstall.sh --project-dir /path   # Remove from project
#   bash uninstall.sh --global --purge      # Also remove .titan/ data

TITAN_VERSION="1.0.0"

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
  echo -e "${CYAN}║${NC}  ${BOLD}⚡ TITAN${NC} — Uninstaller                                     ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

info()    { echo -e "  ${BLUE}▸${NC} $1"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
error()   { echo -e "  ${RED}✗${NC} $1"; }

# ─── Uninstall Functions ───────────────────────────────────────

remove_from_platform() {
  local platform="$1"
  local base_dir="$2"

  info "Removing TITAN from ${platform}..."

  # Remove commands
  if [ -d "${base_dir}/commands/titan" ]; then
    rm -rf "${base_dir}/commands/titan"
    success "Removed commands/titan/"
  fi

  # Remove agents (only titan-* files)
  local agents_removed=0
  for f in "${base_dir}"/agents/titan-*.md; do
    if [ -f "$f" ]; then
      rm "$f"
      agents_removed=$((agents_removed + 1))
    fi
  done
  if [ $agents_removed -gt 0 ]; then
    success "Removed ${agents_removed} titan agents"
  fi

  # Remove templates
  if [ -d "${base_dir}/templates/titan" ]; then
    rm -rf "${base_dir}/templates/titan"
    success "Removed templates/titan/"
  fi
}

uninstall_global() {
  # Claude Code
  if [ -d "${HOME}/.claude" ]; then
    remove_from_platform "Claude Code (global)" "${HOME}/.claude"
  else
    info "Claude Code global directory not found, skipping."
  fi

  # OpenCode
  if [ -d "${HOME}/.opencode" ]; then
    remove_from_platform "OpenCode (global)" "${HOME}/.opencode"
  else
    info "OpenCode global directory not found, skipping."
  fi
}

uninstall_project() {
  local project_dir="$1"

  if [ ! -d "$project_dir" ]; then
    error "Directory does not exist: ${project_dir}"
    exit 1
  fi

  # Claude Code project-local
  if [ -d "${project_dir}/.claude" ]; then
    remove_from_platform "project (Claude Code)" "${project_dir}/.claude"
  fi

  # OpenCode project-local
  if [ -d "${project_dir}/.opencode" ]; then
    remove_from_platform "project (OpenCode)" "${project_dir}/.opencode"
  fi
}

purge_project_data() {
  local project_dir="$1"

  if [ -d "${project_dir}/.titan" ]; then
    warn "This will permanently delete all TITAN project data:"
    echo "    - STATE.md, PROJECT.md, REQUIREMENTS.md, ARCHITECTURE.md, ROADMAP.md"
    echo "    - All phase plans, summaries, evaluations"
    echo "    - Knowledge base, decisions log"
    echo "    - Investigation and experiment records"
    echo ""
    read -p "  Are you sure? (type 'yes' to confirm): " confirm
    if [ "$confirm" = "yes" ]; then
      rm -rf "${project_dir}/.titan"
      success "Removed .titan/ project data"
    else
      info "Purge cancelled."
    fi
  else
    info "No .titan/ directory found."
  fi
}

# ─── What Is NEVER Removed ─────────────────────────────────────

print_safety_note() {
  echo ""
  echo "  ${BOLD}What is NEVER removed:${NC}"
  echo "    - Your source code"
  echo "    - Other frameworks (gsd/, forge/, paul/, bmad/)"
  echo "    - CLAUDE.md or AGENTS.md at project root"
  echo "    - Git history (titan branches and commits remain)"
  echo "    - mockups/ directory"
  echo ""
}

# ─── Parse Arguments ───────────────────────────────────────────

GLOBAL=false
PROJECT_DIR=""
PURGE=false

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
    --purge|-p)
      PURGE=true
      shift
      ;;
    --help|-h)
      print_banner
      echo "Usage:"
      echo "  bash uninstall.sh --global              Remove TITAN globally"
      echo "  bash uninstall.sh --project-dir /path   Remove from specific project"
      echo "  bash uninstall.sh --global --purge      Also remove .titan/ project data"
      echo ""
      print_safety_note
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      echo "Run 'bash uninstall.sh --help' for usage."
      exit 1
      ;;
  esac
done

# ─── Main ──────────────────────────────────────────────────────

print_banner

if [ -n "$PROJECT_DIR" ]; then
  info "Uninstalling TITAN from project: ${PROJECT_DIR}"
  echo ""
  uninstall_project "$PROJECT_DIR"

  if [ "$PURGE" = true ]; then
    echo ""
    purge_project_data "$PROJECT_DIR"
  fi

elif [ "$GLOBAL" = true ]; then
  info "Uninstalling TITAN globally..."
  echo ""
  uninstall_global

  if [ "$PURGE" = true ]; then
    warn "--purge with --global only removes global files."
    warn "To purge a project's .titan/ data, use: --project-dir /path --purge"
  fi

else
  error "Please specify --global or --project-dir."
  echo "  Run 'bash uninstall.sh --help' for usage."
  exit 1
fi

# ─── Summary ───────────────────────────────────────────────────

print_safety_note

echo -e "  ${GREEN}✓ TITAN uninstalled.${NC}"
echo ""
echo "  To reinstall: bash install.sh --global"
echo ""
