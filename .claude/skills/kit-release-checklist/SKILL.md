---
name: kit-release-checklist
description: Verify this kit end-to-end before committing or releasing changes to it — static parse checks, mirror-sync diff, hook smoke tests with file-redirected stdin, and a scratch-project install test of setup.sh. Use after changing skills, hooks, templates, settings, or setup.sh, or when asked whether the kit still installs cleanly. For verifying app code changes use the verify-* skills instead.
---

# Kit Release Checklist

The kit has no test suite; this checklist is the test suite. Run the tiers
in order — each is cheaper than the next. Tier 1 runs on every kit change;
run Tier 2 when hooks or settings changed; run Tier 3 before a release or
after touching `setup.sh` or the templates.

## Tier 1 — static checks (every kit change)

```bash
python3 -c "import json; json.load(open('.claude/skills/skill-rules.json')); json.load(open('.claude/settings.json')); json.load(open('.mcp.json'))"
python3 -c "import tomllib; tomllib.load(open('.codex/config.toml','rb'))"
bash -n setup.sh dev/check-line-limits.sh
python3 -m py_compile .claude/hooks/*.py .codex/hooks/*.py
```

Mirror sync:

```bash
diff -rq .claude/skills .codex/skills
```

Expected divergence ONLY: `skill-rules.json` (Claude side only), and the
`agentic-loops` / `usage-guide` SKILL.md bodies (runtime-specific primitives
and paths). Any other difference is drift — fix it before proceeding.

Registration sweep — every skill registered everywhere:

```bash
for d in .claude/skills/*/; do
  s=$(basename "$d")
  for f in CLAUDE.md AGENTS.md README.md .claude/CLAUDE.template.md \
           .codex/AGENTS.template.md .claude/skills/skill-rules.json; do
    grep -q "$s" "$f" || echo "MISSING: $s in $f"
  done
done
```

Pass: no `MISSING` lines.

## Tier 2 — hook smoke tests (after hook/settings changes)

Feed each hook a JSON event file with stdin redirected from the file (see
Sandbox constraints below for why not a pipe):

```bash
printf '{"prompt":"fix this bug in the login page"}' > /tmp/p.json
npx tsx .claude/hooks/user-prompt-submit.ts < /tmp/p.json
# Pass: banner JSON recommending fable-mindset (and any other matching skills)

printf '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' > /tmp/deny.json
python3 .codex/hooks/bash-guard.py < /tmp/deny.json; echo "exit=$?"
# Pass: reason on stderr, exit=2

printf '{"tool_name":"Bash","tool_input":{"command":"git status"}}' > /tmp/allow.json
python3 .codex/hooks/bash-guard.py < /tmp/allow.json; echo "exit=$?"
# Pass: silent, exit=0

printf '{"tool_name":"Edit","tool_input":{"file_path":"src/x.ts"},"cwd":"."}' > /tmp/edit.json
python3 .claude/hooks/typescript-check.py < /tmp/edit.json; echo "exit=$?"
# Pass in this repo (no tsc installed): silent, exit=0
```

For `line-limit.py`, generate a 501-line file under `src/` in a temp dir and
confirm the warning JSON appears; confirm a 499-line file stays silent.

Kit guard (`kit-guard.py`, both hook dirs — note kit maintenance itself
requires the user to `touch .claude/kit-unlock` first, since the guard
blocks edits to the kit including its own installation):

```bash
printf '{"tool_name":"Edit","tool_input":{"file_path":".claude/skills/x/SKILL.md"},"cwd":"."}' > /tmp/kg.json
python3 .claude/hooks/kit-guard.py < /tmp/kg.json; echo "exit=$?"
# Pass while locked: reason on stderr, exit=2. With .claude/kit-unlock present: exit=0.

printf '{"tool_name":"Edit","tool_input":{"file_path":"src/x.ts"},"cwd":"."}' > /tmp/kg.json
python3 .claude/hooks/kit-guard.py < /tmp/kg.json; echo "exit=$?"
# Pass: silent, exit=0 (app code always writable)
```

## Tier 3 — install test (before release; after setup.sh/template changes)

```bash
TARGET=$(mktemp -d) && git -C "$TARGET" init -q && ./setup.sh "$TARGET"
```

Verify in `$TARGET`, each with a real command, not by assumption:

1. Skill dirs match the kit on both sides:
   `diff <(ls .claude/skills) <(ls "$TARGET/.claude/skills")` and same for
   `.codex/skills` — empty.
2. `CLAUDE.md`, `AGENTS.md`, `.mcp.json` seeded; `.claude/settings.json` and
   `.codex/config.toml` copied.
3. `docs/delivery/` and `dev/active/` exist; `dev/check-line-limits.sh` copied.
4. `.gitignore` gained the local-state block (settings.local.json,
   CLAUDE.local.md, dev/active/*, __pycache__, test-credentials).
5. No `__pycache__` directories were copied:
   `find "$TARGET/.codex" -name __pycache__` — empty. (This was a real
   shipped bug; keep the check.)
6. Idempotency — pre-seed a custom `CLAUDE.md`, re-run `./setup.sh "$TARGET"`:
   the custom file survives (a `KEPT:` notice prints) and `.gitignore` lines
   are not duplicated (`sort "$TARGET/.gitignore" | uniq -d` — empty).
7. Override-with-backup — pre-seed a differing `$TARGET/.claude/settings.json`
   and `$TARGET/.codex/config.toml`, re-run the installer: both are replaced
   by kit versions, `<file>.pre-autoflow` backups hold the originals
   byte-for-byte, and an `OVERRIDDEN:` notice prints for each. Re-run once
   more: no new notice (kit file already in place).
7. Run the suggester hook from inside `$TARGET` (file-redirect stdin) and
   confirm it reads the installed `skill-rules.json`.

Clean up: `rm -rf "$TARGET"`.

## Sandbox constraints (Claude Code sandbox, macOS)

- `node`, `npx`, and `npm` may exit 126 with a `compdef` error when the
  shell profile lazy-loads nvm (`node` is a shell function, not a binary).
  Call the real binary by absolute path — `/opt/homebrew/bin/node` or
  `~/.nvm/versions/node/<version>/bin/node` — and run scripts from files
  with stdin redirected from a file, never `node -e` or piped stdin.
- If `npx tsx` cannot run the TypeScript hook, replicate its matching logic
  in a plain-JS harness file and run that with the absolute node path.
- Not testable in a scratch project: the tsc error-detection path (needs an
  installed TS project) and live MCP servers (need a running app). List
  these explicitly in the report as `Unverified`, never skip them silently.

## Report

End with `Verified:` naming the tiers run and what each showed, plus an
explicit list of anything from the not-testable set, or `Unverified:` naming
the tier that could not run and why.
