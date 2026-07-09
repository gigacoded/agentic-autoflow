---
name: usage-guide
description: Map of this agent infrastructure kit — which skill, MCP tool, hook, or loop to reach for in any situation, where everything lives, and how to maintain or install the kit. Use when unsure which skill applies, when adding or editing skills/hooks/rules, when installing the kit into another codebase, or when asked how this infrastructure works.
---

# Agent Infrastructure Usage Guide

This kit (Agentic AutoFlow) ships mirrored agent infrastructure for Claude
Code (`.claude/`) and OpenAI Codex (`.codex/`). This guide is the map; each
skill is the territory.

## Which skill, when

| Situation | Load |
|-----------|------|
| Starting any non-trivial task (debug, implement, migrate) | `fable-mindset` — operating principles |
| Work that outlives one turn (recurring, "until it passes", CI babysitting) | `agentic-loops` — pick the loop primitive and stop condition |
| Just edited UI (component, route, style) | `verify-frontend-change` — browser-verify before reporting done |
| Just edited backend (Convex function, schema) | `verify-backend-change` — run against live dev data before reporting done |
| Testing a full user journey (auth → feature → result) | `e2e-testing-framework` — Step 0 auth, fail-fast, completion report |
| Writing Convex queries/mutations/schema/indexes | `convex-backend-dev` |
| Server functions, file routes, loaders, SSR | `tanstack-start-dev` |
| Payments: checkout, subscriptions, Stripe webhooks | `stripe-payments` |
| React components, Tailwind, shadcn/ui, forms | `frontend-dev` |
| UI polish: micro-interactions, animation, radius, shadows, typography | `make-interfaces-feel-better` |
| Planning features, PBIs, backlog, long-task notes | `task-management-dev` |
| Post-write cleanup, refactoring for clarity | `code-simplifier` |
| Templated SEO pages at scale | `programmatic-seo` |
| Adding/editing a skill, or a skill never fires | `skill-authoring` |
| Adding/editing a hook, or a hook misbehaves | `hook-development` |
| Changed the kit itself (skills/hooks/setup.sh) — verify before commit | `kit-release-checklist` |

## Verification ladder (strongest first)

1. Exercise real behavior — browser via Chrome DevTools MCP, live data via
   Convex MCP (the two `verify-*` skills).
2. Relevant test suite → single test.
3. Typecheck / lint (`npx tsc --noEmit` — also runs automatically via hooks).
4. Careful re-read (weakest; say so).

Every task report ends with `Verified: <what ran, what it showed>` or
`Unverified: edited but not verified because <reason>`.

## MCP quick reference

**Chrome DevTools** (`mcp__chrome-devtools__*`): `new_page` / `navigate_page`,
`take_snapshot` (get element UIDs — never guess selectors), `click`, `fill`,
`fill_form`, `wait_for`, `take_screenshot`, `list_console_messages`,
`list_network_requests`, `performance_start_trace` / `stop_trace`,
`lighthouse_audit`. Full reference:
`.claude/skills/e2e-testing-framework/resources/chrome-mcp-tools.md`.

**Convex** (`mcp__convex__*`): `status` (confirm dev deployment first),
`tables`, `data`, `functionSpec`, `run` (mutates — dev only),
`runOneoffQuery` (read-only, safe), `logs`, `insights`, `envList` / `envGet`.

Read-only tools from both servers are pre-allowed in
`.claude/settings.json`; mutating ones prompt.

## Where everything lives

| Path | What |
|------|------|
| `CLAUDE.md` / `AGENTS.md` | Auto-loaded instructions (Claude Code / Codex) |
| `.claude/skills/<name>/SKILL.md` | Skill bodies, loaded on demand |
| `.claude/skills/skill-rules.json` | Prompt/file triggers for the suggestion hook |
| `.claude/settings.json` | Hooks (UserPromptSubmit skill suggester, PostToolUse tsc) + permissions |
| `.claude/hooks/` | Hook scripts |
| `.claude/rules/`, `.claude/agents/`, `.claude/commands/` | Rules, subagents, slash commands |
| `.codex/config.toml` | Codex model, hooks (bash-guard / typecheck / line-limit), MCP servers |
| `.codex/skills/`, `.codex/hooks/` | Codex mirrors of skills and hook scripts |
| `.mcp.json` | Claude Code MCP servers (convex, chrome-devtools isolated) |
| `dev/active/<task>/` | Long-task working notes (survive compaction) |
| `dev/check-line-limits.sh` | 500-line app-code check |
| `docs/delivery/` | Optional PBI workflow |

## Maintaining the kit

The full procedures live in dedicated skills: `skill-authoring` (writing a
skill that fires and that smaller models can execute), `hook-development`
(the hook contract and testing), and `kit-release-checklist` (verifying the
kit before commit/release). Summary of the invariant:

When you add or change a skill, all of these must move together:

1. `.claude/skills/<name>/SKILL.md` — frontmatter `name` + `description`
   (the description drives model invocation; put the key use case first).
2. `.codex/skills/<name>/SKILL.md` — mirror it (adapt Claude-Code-only
   primitives like `/goal`, `/loop`, `/schedule` to Codex equivalents).
3. `.claude/skills/skill-rules.json` — keywords + intentPatterns for the
   suggestion hook.
4. Skills lists in `CLAUDE.md`, `AGENTS.md`, and both templates
   (`.claude/CLAUDE.template.md`, `.codex/AGENTS.template.md`).
5. `README.md` skills table (human-facing).

Same mirroring rule for hooks: `.claude/settings.json` + `.claude/hooks/`
on one side, `.codex/config.toml` + `.codex/hooks/` on the other.

When a loop or review turns up a recurring mistake, encode the lesson here —
a skill, rule, or hook — not just in the one fix. Fix the system.

## Installing into another codebase

```bash
./setup.sh /path/to/project
```

Merge semantics: skills/hooks/agents/commands merge (same-named files update
to kit versions, the project's own files survive). Harness config
(`.claude/settings.json`, `.codex/config.toml`, `.mcp.json`) is OVERRIDDEN
by the kit — existing differing files are backed up as `<file>.pre-autoflow`
and each override is printed. `CLAUDE.md`/`AGENTS.md` are seeded only if
missing; when kept, a notice points at the kit template to merge from.
Creates `docs/delivery/` and `dev/active/`, appends local-state entries to
`.gitignore`. After install: customize the Common Commands section in
`CLAUDE.md`/`AGENTS.md`, merge anything needed from the `.pre-autoflow`
backups, and copy `dev/test-credentials.example.json` →
`dev/test-credentials.json` if E2E testing is wanted. `README.md` at the kit
root has the full human-facing walkthrough.
