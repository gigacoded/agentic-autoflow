---
name: hook-development
description: Write, register, and test harness hooks for Claude Code (.claude/settings.json + .claude/hooks/) and Codex (.codex/config.toml + .codex/hooks/). Use when adding an automated check that must run every time — typecheck, safety guard, context injection — when a hook doesn't fire or misbehaves, or when porting a hook between the two runtimes. For guidance the model follows by judgment, write a skill instead (see skill-authoring).
---

# Hook Development

Hooks are the deterministic layer: the harness executes them on every
matching event whether or not the model remembers to. Any requirement
phrased "always / every time / never allow" belongs here, not in a skill —
memory and skills cannot fulfill "whenever X" guarantees; hooks can.

## Contract (both runtimes)

- Input: one JSON object on stdin.
- Output: optional JSON on stdout.
- Exit `0` = success; exit `2` = block (stderr is shown to / fed back to the
  model); any other code = non-blocking error (stderr in verbose mode only).
- Structured feedback for the model:

  ```json
  {"hookSpecificOutput": {"hookEventName": "<Event>", "additionalContext": "..."}}
  ```

Events used in this kit (33 exist in total — full list at
https://code.claude.com/docs/en/hooks):

| Event | Fires | stdin carries | Used here for |
|---|---|---|---|
| UserPromptSubmit | before each user prompt | `prompt`, `session_id`, `cwd` | skill suggester |
| PreToolUse | before a tool call | `tool_name`, `tool_input` | bash-guard (exit 2 denies the call) |
| PostToolUse | after a tool call | `tool_name`, `tool_input`, `tool_response` | typecheck, line-limit |

## Registering

**Claude Code** — `.claude/settings.json`:

```json
"hooks": {
  "UserPromptSubmit": [{ "hooks": [{ "type": "command",
    "command": "npx tsx \"$CLAUDE_PROJECT_DIR/.claude/hooks/user-prompt-submit.ts\"" }] }],
  "PostToolUse": [{ "matcher": "Edit|Write", "hooks": [{ "type": "command",
    "command": "python3 \"$CLAUDE_PROJECT_DIR/.claude/hooks/typescript-check.py\"" }] }]
}
```

`UserPromptSubmit` takes no matcher; `PreToolUse`/`PostToolUse` matchers are
regexes over tool names.

**Codex** — `.codex/config.toml` (requires `hooks = true` under `[features]`):

```toml
[[hooks.PostToolUse]]
matcher = "Edit|Write|apply_patch|MultiEdit"

[[hooks.PostToolUse.hooks]]
type = "command"
command = "python3 ${CODEX_PROJECT_DIR:-.}/.codex/hooks/typecheck.py"
timeout = 45
statusMessage = "Typechecking"
```

Codex edit matchers must also cover `apply_patch|MultiEdit`.

## Design rules

1. **Fail open.** Wrap everything; on unexpected error print to stderr and
   exit 0. A broken quality hook must never block work — only safety guards
   exit 2, and only deliberately.
2. **Silent happy path.** No stdout when there is nothing to say.
3. **Bound the work.** Give subprocesses a timeout below the hook's own
   (`typescript-check.py` runs tsc with `timeout=10`; the Codex hook entry
   allows 45).
4. **Detect before running.** Check the project actually applies —
   `typescript-check.py` exits silently unless `package.json` and
   `node_modules/.bin/tsc` exist, so installs into non-TS repos stay quiet.
5. **Resolve paths from the env**: `CLAUDE_PROJECT_DIR` / `CODEX_PROJECT_DIR`,
   falling back to cwd. Never hardcode absolute paths.
6. **Prefer Python** for hooks that fire often (no `npx tsx` startup cost);
   TypeScript only when Node libraries are genuinely needed.
7. **Mirror every behavior**: `.claude/settings.json` + `.claude/hooks/` on
   one side, `.codex/config.toml` + `.codex/hooks/` on the other. Scripts
   may differ per runtime's input shape (Codex tools include `apply_patch`;
   guard against both `tool_name` and `name` keys as the shipped hooks do).

## Testing a hook locally

Write the event JSON to a file and redirect stdin **from the file** — in the
Claude Code sandbox, `node -e`, piped stdin, and bare `npx` can exit 126;
file redirection is the reliable form:

```bash
cat > /tmp/hook-input.json <<'EOF'
{"tool_name": "Edit", "tool_input": {"file_path": "src/x.ts"}, "cwd": "."}
EOF
python3 .claude/hooks/typescript-check.py < /tmp/hook-input.json; echo "exit=$?"
```

Checklist — run every case, not just the happy one:

- Happy path → exit 0, no stdout.
- Triggering input → the expected JSON on stdout.
- Empty or malformed stdin → exit 0, no traceback.
- Wrong project type (e.g. no package.json) → silent exit 0.
- Guard hooks: one denied command → exit 2 with the reason on stderr, AND
  one allowed command → exit 0. Test both directions.

## Worked examples in this repo

| Hook | Event | Pattern it demonstrates |
|---|---|---|
| `.claude/hooks/user-prompt-submit.ts` | UserPromptSubmit | context injection driven by a rules file (`skill-rules.json`) |
| `.claude/hooks/typescript-check.py` | PostToolUse | project detection, bounded subprocess, `additionalContext` feedback |
| `.codex/hooks/bash-guard.py` | PreToolUse | deliberate exit-2 deny with regex deny-list |
| `.claude/hooks/kit-guard.py` (mirrored) | PreToolUse | multi-tool guard (edit tools + Bash heuristic) with a user-only unlock file (`.claude/kit-unlock`) |
| `.codex/hooks/line-limit.py` | PostToolUse | non-blocking warning scoped to app-code paths |

The registrations in `.claude/settings.json` and `.codex/config.toml` are
the source of truth — read the live files, not doc snippets, before editing.

Report `Verified:` naming the cases exercised and their exit codes, or
`Unverified:` with the reason.
