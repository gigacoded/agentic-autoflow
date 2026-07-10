#!/usr/bin/env python3
"""PreToolUse hook: protect the agent-infrastructure kit from model edits.

Blocks Edit/Write/MultiEdit/NotebookEdit/apply_patch targeting kit content,
and Bash commands that write to a protected path.

Protected everywhere: .claude/, .codex/, CLAUDE.md, AGENTS.md,
dev/check-line-limits.sh. Protected only in the kit source repo (detected by
.claude/CLAUDE.template.md, which setup.sh never copies to targets):
README.md and setup.sh — target projects own those names themselves.
Exception: .claude/settings.local.json (local state) stays writable.

Unlock (user decision only): the user creates `.claude/kit-unlock` themselves
(e.g. by typing `! touch .claude/kit-unlock` in the prompt) and deletes it
when maintenance is done. Creating that file is itself a write into .claude/,
so a model asking to run `touch .claude/kit-unlock` is blocked by this guard.

The Bash check is a heuristic scoped per shell segment (split on ;, |, &&,
||, newline). A command is denied only when a single segment both mentions a
protected path and runs a write command, when a redirect targets a protected
path, or when an earlier segment cd'd into a protected directory and a later
one writes. Reading kit files, piping their contents elsewhere, and running
dev/check-line-limits.sh all pass — even inside compound commands that write
to application files. Exit 0 allow, exit 2 deny (stderr to model).
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

SEGMENTS = re.compile(r"\|\||&&|;|\||\n")
WRITE_CMDS = re.compile(
    r"\btee\b|\brm\b|\bmv\b|\bcp\b|\bsed\s+-i|\btouch\b"
    r"|\btruncate\b|\bchmod\b|\bchown\b|\bln\b|\brsync\b|\bdd\b|\bpatch\b"
    r"|\bmkdir\b|\bgit\s+checkout\b|\bgit\s+restore\b|\bgit\s+clean\b"
)
# File redirection; 2>, >&2 do not count. Captures the redirect target.
REDIRECT_TARGETS = re.compile(r"(?<![0-9&<>])>{1,2}(?!&)\s*([^\s;|&<>]*)")
CD = re.compile(r"\b(?:cd|pushd)\s+(\S+)")
PROTECTED_DIR = re.compile(r"(^|/)\.(claude|codex)(/|$)")
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


def bash_writes_protected(cmd: str, mention: re.Pattern) -> bool:
    protected_cwd = False
    for seg in SEGMENTS.split(cmd):
        mentions = bool(mention.search(seg))
        if WRITE_CMDS.search(seg) and (mentions or protected_cwd):
            return True
        for m in REDIRECT_TARGETS.finditer(seg):
            target = m.group(1)
            if mention.search(target):
                return True
            if protected_cwd and not target.startswith(("/", "~", "$")):
                return True
        cd = CD.search(seg)
        if cd:
            target = cd.group(1).strip("\"'")
            protected_cwd = bool(PROTECTED_DIR.search(target))
    return False


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
        if bash_writes_protected(cmd, mention):
            deny("Refusing shell write to protected kit paths")
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
