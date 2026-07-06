#!/usr/bin/env python3
"""Codex PostToolUse hook: enforce 500-line limit on app code.

Warns (non-blocking) when an edited file exceeds limit. Matches CLAUDE.md rule.
"""
import json
import os
import sys

LIMIT = 500
APP_ROOTS = ("src/", "components/", "convex/", "lib/", "hooks/")
SKIP_PREFIXES = ("convex/_generated/",)
EDIT_TOOLS = {"Edit", "Write", "apply_patch", "MultiEdit"}


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    if (data.get("tool_name") or data.get("name") or "") not in EDIT_TOOLS:
        sys.exit(0)

    cwd = data.get("cwd") or os.getcwd()
    path = (data.get("tool_input") or {}).get("file_path") or ""
    if not path:
        sys.exit(0)

    rel = os.path.relpath(path, cwd) if os.path.isabs(path) else path
    if rel.startswith(SKIP_PREFIXES) or not rel.startswith(APP_ROOTS):
        sys.exit(0)
    if not rel.endswith((".ts", ".tsx", ".js", ".jsx")):
        sys.exit(0)

    try:
        with open(path, encoding="utf-8") as f:
            n = sum(1 for _ in f)
    except OSError:
        sys.exit(0)

    if n > LIMIT:
        print(json.dumps({
            "systemMessage": f"{rel}: {n} lines (>500). Refactor into smaller modules per CLAUDE.md."
        }))
    sys.exit(0)


if __name__ == "__main__":
    main()
