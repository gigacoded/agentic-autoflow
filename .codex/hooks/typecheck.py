#!/usr/bin/env python3
"""Codex PostToolUse hook: TypeScript check after Edit/Write/apply_patch.

Stdin: JSON with session_id, cwd, hook_event_name, model, turn_id, tool_name, tool_input, tool_response.
Stdout: JSON {"systemMessage": "..."} for non-blocking feedback.
Exit 0 success, exit 2 block with stderr reason.
"""
import json
import os
import subprocess
import sys

EDIT_TOOLS = {"Edit", "Write", "apply_patch", "MultiEdit"}


def is_ts_edit(tool_input: dict) -> bool:
    path = tool_input.get("file_path") or tool_input.get("path") or ""
    return path.endswith((".ts", ".tsx"))


def run_typecheck(cwd: str) -> str | None:
    if not os.path.exists(os.path.join(cwd, "node_modules", ".bin", "tsc")):
        return None
    try:
        r = subprocess.run(
            ["npx", "tsc", "--noEmit"],
            cwd=cwd, capture_output=True, text=True, timeout=30,
        )
        if r.returncode == 0:
            return None
        out = r.stdout or r.stderr or ""
        errs = [ln for ln in out.splitlines() if "error TS" in ln]
        if not errs:
            return None
        head = "\n".join(errs[:5])
        more = f"\n… +{len(errs)-5} more" if len(errs) > 5 else ""
        return f"TypeScript errors ({len(errs)}):\n{head}{more}"
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool = data.get("tool_name") or data.get("name") or ""
    if tool not in EDIT_TOOLS:
        sys.exit(0)

    if not is_ts_edit(data.get("tool_input", {})):
        sys.exit(0)

    cwd = data.get("cwd") or os.getcwd()
    err = run_typecheck(cwd)
    if err:
        print(json.dumps({"systemMessage": err}))
    sys.exit(0)


if __name__ == "__main__":
    main()
