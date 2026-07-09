#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
  printf 'Error: target directory does not exist: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

copy_dir() {
  local source="$1"
  local target="$2"

  if [ -d "$source" ]; then
    mkdir -p "$target"
    cp -R "$source"/. "$target"/
  fi
}

copy_file_if_missing() {
  local source="$1"
  local target="$2"

  if [ -f "$source" ] && [ ! -f "$target" ]; then
    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
  fi
}

copy_file() {
  local source="$1"
  local target="$2"

  if [ -f "$source" ]; then
    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
  fi
}

append_gitignore_once() {
  local line="$1"
  local file="$TARGET_DIR/.gitignore"

  if [ ! -f "$file" ]; then
    touch "$file"
  fi

  if ! grep -qxF "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

# Harness config: the kit's version wins, but never silently — existing
# differing files are backed up as <file>.pre-autoflow and reported.
OVERRIDE_NOTICES=""
KEEP_NOTICES=""

backup_and_override() {
  local source="$1"
  local target="$2"

  if [ ! -f "$source" ]; then
    return
  fi
  if [ -f "$target" ] && ! cmp -s "$source" "$target"; then
    cp "$target" "$target.pre-autoflow"
    OVERRIDE_NOTICES="${OVERRIDE_NOTICES}  OVERRIDDEN: ${target}  (backup: ${target}.pre-autoflow)\n"
  fi
  mkdir -p "$(dirname "$target")"
  cp "$source" "$target"
}

# Project instructions stay the project's — seed only if missing, and point
# the user at the kit template to merge from when theirs differs.
seed_or_keep() {
  local source="$1"
  local target="$2"

  if [ ! -f "$source" ]; then
    return
  fi
  if [ -f "$target" ]; then
    if ! cmp -s "$source" "$target"; then
      KEEP_NOTICES="${KEEP_NOTICES}  KEPT: ${target} — merge the Skills, Verification, and Kit Protection sections from ${source}\n"
    fi
  else
    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
  fi
}

printf 'Installing Agentic AutoFlow into %s\n' "$TARGET_DIR"

copy_dir "$TEMPLATE_DIR/.claude/agents" "$TARGET_DIR/.claude/agents"
copy_dir "$TEMPLATE_DIR/.claude/commands" "$TARGET_DIR/.claude/commands"
copy_dir "$TEMPLATE_DIR/.claude/hooks" "$TARGET_DIR/.claude/hooks"
copy_dir "$TEMPLATE_DIR/.claude/rules" "$TARGET_DIR/.claude/rules"
copy_dir "$TEMPLATE_DIR/.claude/skills" "$TARGET_DIR/.claude/skills"
backup_and_override "$TEMPLATE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"

backup_and_override "$TEMPLATE_DIR/.codex/config.toml" "$TARGET_DIR/.codex/config.toml"
copy_dir "$TEMPLATE_DIR/.codex" "$TARGET_DIR/.codex"

# Never ship python bytecode caches from the kit checkout
find "$TARGET_DIR/.claude" "$TARGET_DIR/.codex" -type d -name __pycache__ -prune -exec rm -rf {} +

seed_or_keep "$TEMPLATE_DIR/.claude/CLAUDE.template.md" "$TARGET_DIR/CLAUDE.md"
seed_or_keep "$TEMPLATE_DIR/.codex/AGENTS.template.md" "$TARGET_DIR/AGENTS.md"
backup_and_override "$TEMPLATE_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"

mkdir -p "$TARGET_DIR/docs/delivery" "$TARGET_DIR/dev/active"
copy_file "$TEMPLATE_DIR/dev/check-line-limits.sh" "$TARGET_DIR/dev/check-line-limits.sh"
copy_file_if_missing "$TEMPLATE_DIR/dev/test-credentials.example.json" "$TARGET_DIR/dev/test-credentials.example.json"
copy_file_if_missing "$TEMPLATE_DIR/docs/delivery/backlog.md" "$TARGET_DIR/docs/delivery/backlog.md"
copy_dir "$TEMPLATE_DIR/docs/delivery/examples" "$TARGET_DIR/docs/delivery/examples"

append_gitignore_once ''
append_gitignore_once '# Agentic AutoFlow local state'
append_gitignore_once '.claude/settings.local.json'
append_gitignore_once 'CLAUDE.local.md'
append_gitignore_once 'dev/active/*'
append_gitignore_once '!dev/active/.gitkeep'
append_gitignore_once '.claude/hooks/__pycache__/'
append_gitignore_once '.codex/hooks/__pycache__/'
append_gitignore_once 'dev/test-credentials.json'
append_gitignore_once '.claude/kit-unlock'
append_gitignore_once '*.pre-autoflow'

printf 'Install complete.\n'

if [ -n "$OVERRIDE_NOTICES" ]; then
  printf '\n!! The kit OVERRODE existing agent-harness config (the kit'\''s hooks and\n'
  printf '!! protections only work with its own config in place):\n'
  # shellcheck disable=SC2059
  printf "$OVERRIDE_NOTICES"
  printf '!! Merge anything project-specific back from the .pre-autoflow backups,\n'
  printf '!! keeping the kit'\''s hooks and permissions sections intact.\n'
fi

if [ -n "$KEEP_NOTICES" ]; then
  printf '\nKept existing project instructions:\n'
  # shellcheck disable=SC2059
  printf "$KEEP_NOTICES"
fi

printf '\nNext: review CLAUDE.md, AGENTS.md, .claude/settings.json, and .mcp.json for project-specific commands and MCP servers.\n'
