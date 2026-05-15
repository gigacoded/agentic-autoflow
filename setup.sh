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

printf 'Installing Agentic AutoFlow into %s\n' "$TARGET_DIR"

copy_dir "$TEMPLATE_DIR/.claude/agents" "$TARGET_DIR/.claude/agents"
copy_dir "$TEMPLATE_DIR/.claude/commands" "$TARGET_DIR/.claude/commands"
copy_dir "$TEMPLATE_DIR/.claude/hooks" "$TARGET_DIR/.claude/hooks"
copy_dir "$TEMPLATE_DIR/.claude/hooks-global" "$TARGET_DIR/.claude/hooks-global"
copy_dir "$TEMPLATE_DIR/.claude/rules" "$TARGET_DIR/.claude/rules"
copy_dir "$TEMPLATE_DIR/.claude/skills" "$TARGET_DIR/.claude/skills"
copy_file "$TEMPLATE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"

copy_dir "$TEMPLATE_DIR/.codex" "$TARGET_DIR/.codex"

copy_file_if_missing "$TEMPLATE_DIR/.claude/CLAUDE.template.md" "$TARGET_DIR/CLAUDE.md"
copy_file_if_missing "$TEMPLATE_DIR/.codex/AGENTS.template.md" "$TARGET_DIR/AGENTS.md"
copy_file_if_missing "$TEMPLATE_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"

mkdir -p "$TARGET_DIR/docs/delivery" "$TARGET_DIR/dev/active"
copy_file "$TEMPLATE_DIR/dev/check-line-limits.sh" "$TARGET_DIR/dev/check-line-limits.sh"
copy_file_if_missing "$TEMPLATE_DIR/docs/delivery/backlog.md" "$TARGET_DIR/docs/delivery/backlog.md"
copy_dir "$TEMPLATE_DIR/docs/delivery/examples" "$TARGET_DIR/docs/delivery/examples"

append_gitignore_once ''
append_gitignore_once '# Agentic AutoFlow local state'
append_gitignore_once '.claude/settings.local.json'
append_gitignore_once 'CLAUDE.local.md'
append_gitignore_once 'dev/active/*'
append_gitignore_once '!dev/active/.gitkeep'

printf 'Install complete.\n'
printf 'Next: review CLAUDE.md, AGENTS.md, .claude/settings.json, and .mcp.json for project-specific commands and MCP servers.\n'
