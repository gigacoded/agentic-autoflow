#!/usr/bin/env bash
set -euo pipefail

MAX_LINES="${MAX_LINES:-500}"

find . \
  -path './.git' -prune -o \
  -path '*/node_modules' -prune -o \
  -path '*/.next' -prune -o \
  -path '*/.output' -prune -o \
  -path '*/.vercel' -prune -o \
  -path '*/dist' -prune -o \
  -path '*/build' -prune -o \
  -path '*/coverage' -prune -o \
  -path '*/.venv*' -prune -o \
  -path './.gemini' -prune -o \
  -path '*/_generated' -prune -o \
  -type f \( \
    -name '*.ts' -o \
    -name '*.tsx' -o \
    -name '*.js' -o \
    -name '*.jsx' -o \
    -name '*.mjs' -o \
    -name '*.cjs' -o \
    -name '*.css' -o \
    -name '*.scss' -o \
    -name '*.vue' -o \
    -name '*.svelte' -o \
    -name '*.py' -o \
    -name '*.go' -o \
    -name '*.rs' -o \
    -name '*.java' -o \
    -name '*.kt' -o \
    -name '*.swift' -o \
    -name '*.rb' -o \
    -name '*.php' \
  \) \
  ! -name '*.gen.ts' \
  ! -name '*.gen.tsx' \
  ! -name '*.d.ts' \
  ! -name '*.generated.*' \
  -print0 |
while IFS= read -r -d '' file; do
  line_count="$(wc -l < "$file" | tr -d ' ')"
  if [ "$line_count" -gt "$MAX_LINES" ]; then
    printf '%s %s\n' "$line_count" "$file"
  fi
done |
sort -nr |
awk -v max="$MAX_LINES" '
  BEGIN { failed = 0 }
  {
    failed = 1
    print
  }
  END {
    if (failed) {
      printf "Application code files above %s lines must be refactored before completion.\n", max > "/dev/stderr"
      exit 1
    }
  }
'
