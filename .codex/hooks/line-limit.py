#!/usr/bin/env python3
"""Codex PostToolUse hook: enforce 500-line limit on app code.

Warns (non-blocking) when an edited file exceeds limit. Matches CLAUDE.md rule.
"""
import json
import os
import sys

LIMIT = 500
APP_ROOTS = ("src/", "components/", "convex/", "lib/", "hooks/")
EDIT_TOOLS = {"Edit", "Write", "apply_patch", "MultiEdit"}


def is_generated(rel: str) -> bool:
    return (
        "_generated/" in rel
        or ".generated." in rel
        or rel.endswith((".gen.ts", ".gen.tsx", ".d.ts"))
    )


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
    if is_generated(rel) or not rel.startswith(APP_ROOTS):
        sys.exit(0)
    if not rel.endswith((".ts", ".tsx", ".js", ".jsx")):
        sys.exit(0)

    abs_path = path if os.path.isabs(path) else os.path.join(cwd, path)
    try:
        with open(abs_path, encoding="utf-8") as f:
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
