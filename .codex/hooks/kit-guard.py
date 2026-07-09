#!/usr/bin/env python3
"""PreToolUse hook: protect the agent-infrastructure kit from model edits.

Blocks Edit/Write/MultiEdit/NotebookEdit/apply_patch targeting kit content,
and Bash commands that both mention a protected path and contain a write
indicator (file redirection, rm, mv, sed -i, tee, touch, git checkout/restore...).

Protected everywhere: .claude/, .codex/, CLAUDE.md, AGENTS.md,
dev/check-line-limits.sh. Protected only in the kit source repo (detected by
.claude/CLAUDE.template.md, which setup.sh never copies to targets):
README.md and setup.sh — target projects own those names themselves.
Exception: .claude/settings.local.json (local state) stays writable.

Unlock (user decision only): the user creates `.claude/kit-unlock` themselves
(e.g. by typing `! touch .claude/kit-unlock` in the prompt) and deletes it
when maintenance is done. Creating that file is itself a write into .claude/,
so a model asking to run `touch .claude/kit-unlock` is blocked by this guard.

The Bash check is a heuristic and errs toward blocking. Redirects to /dev/*
and fd-number redirects (2>, 2>&1) do not count as write indicators. A
blocked read-only command should be reformulated with Read/Grep tools.
Exit 0 allow, exit 2 deny (stderr to model).
"""
import json
import os
import re
import sys

PROTECTED_PREFIXES = (".claude/", ".codex/")
PROTECTED_FILES = {"CLAUDE.md", "AGENTS.md", "dev/check-line-limits.sh"}
KIT_SOURCE_ONLY_FILES = {"README.md", "setup.sh"}
ALLOWED_EXACT = {".claude/settings.local.json"}
EDIT_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit", "apply_patch"}

# File redirection counts as a write; 2>, >&2, and >/dev/* do not.
REDIRECT = r"(?<![0-9&<>])>{1,2}(?!&)\s*(?!/dev/)"
WRITE_INDICATORS = re.compile(
    REDIRECT + r"|\btee\b|\brm\b|\bmv\b|\bcp\b|\bsed\s+-i|\btouch\b"
    r"|\btruncate\b|\bchmod\b|\bchown\b|\bln\b|\brsync\b|\bdd\b|\bpatch\b"
    r"|\bmkdir\b|\bgit\s+checkout\b|\bgit\s+restore\b|\bgit\s+clean\b"
)
MENTION_BASE = (
    r"\.claude/|\.codex/|\bCLAUDE\.md\b|\bAGENTS\.md\b|\bcheck-line-limits\.sh\b"
)
MENTION_KIT_SOURCE = r"|\bREADME\.md\b|\bsetup\.sh\b"


def project_dir(data: dict) -> str:
    return (
        os.environ.get("CLAUDE_PROJECT_DIR")
        or os.environ.get("CODEX_PROJECT_DIR")
        or data.get("cwd")
        or os.getcwd()
    )


def unlocked(root: str) -> bool:
    return os.path.exists(os.path.join(root, ".claude", "kit-unlock"))


def is_kit_source(root: str) -> bool:
    return os.path.exists(os.path.join(root, ".claude", "CLAUDE.template.md"))


def is_protected_path(rel: str, kit_source: bool) -> bool:
    while rel.startswith("./"):
        rel = rel[2:]
    if rel in ALLOWED_EXACT:
        return False
    if rel.startswith(PROTECTED_PREFIXES) or rel in PROTECTED_FILES:
        return True
    return kit_source and rel in KIT_SOURCE_ONLY_FILES


def deny(reason: str) -> None:
    print(
        f"{reason} — this kit's content is protected; models must not "
        "overwrite it. If the user explicitly wants this change, they can "
        "unlock maintenance by running `touch .claude/kit-unlock` themselves "
        "(and deleting it afterwards).",
        file=sys.stderr,
    )
    sys.exit(2)


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool = data.get("tool_name") or data.get("name") or ""
    ti = data.get("tool_input") or {}
    root = project_dir(data)

    if unlocked(root):
        sys.exit(0)

    kit_source = is_kit_source(root)
    mention = re.compile(
        MENTION_BASE + (MENTION_KIT_SOURCE if kit_source else "")
    )

    if tool in EDIT_TOOLS:
        path = ti.get("file_path") or ti.get("path") or ""
        if path:
            rel = os.path.relpath(path, root) if os.path.isabs(path) else path
            if is_protected_path(rel, kit_source):
                deny(f"Refusing {tool} to protected kit file: {rel}")
        else:
            # apply_patch-style input: scan the patch text for protected paths
            if mention.search(json.dumps(ti)):
                deny(f"Refusing {tool} touching protected kit paths")
        sys.exit(0)

    if tool in ("Bash", "shell"):
        cmd = ti.get("command") or ti.get("cmd") or ""
        if mention.search(cmd) and WRITE_INDICATORS.search(cmd):
            deny("Refusing shell write to protected kit paths")
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
