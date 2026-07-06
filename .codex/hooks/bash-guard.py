#!/usr/bin/env python3
"""Codex PreToolUse hook: block destructive shell commands.

Blocks: rm -rf /, rm -rf ~, force-push to main/master, git reset --hard on protected refs.
Exit 0 allow, exit 2 deny (stderr printed to model).
"""
import json
import re
import sys

DENY_PATTERNS = [
    (re.compile(r"\brm\s+-[rf]+\s+(/|~|\$HOME)(\s|$|/)"), "Refusing rm -rf on root/home"),
    (re.compile(r"\bgit\s+push\s+.*--force\b.*\b(main|master)\b"), "Refusing force-push to main/master"),
    (re.compile(r"\bgit\s+push\s+.*-f\b.*\b(main|master)\b"), "Refusing force-push to main/master"),
    (re.compile(r"\bgit\s+reset\s+--hard\s+origin/(main|master)\b"), "Refusing hard reset on protected branch"),
    (re.compile(r"--no-verify\b"), "Refusing --no-verify (skips hooks)"),
]


def extract_command(data: dict) -> str:
    ti = data.get("tool_input") or {}
    return ti.get("command") or ti.get("cmd") or ""


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool = data.get("tool_name") or data.get("name") or ""
    if tool not in ("Bash", "shell"):
        sys.exit(0)

    cmd = extract_command(data)
    for pat, reason in DENY_PATTERNS:
        if pat.search(cmd):
            print(reason, file=sys.stderr)
            sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
