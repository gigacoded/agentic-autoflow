# Development Infrastructure

Codex instructions for this repository.

## Operating Principles

Read `.codex/skills/fable-mindset/SKILL.md` at the start of any non-trivial
task. Non-negotiables from it:

- Act only on what you observed in this session (file read, command run) —
  never on "how these things usually work". Never edit code you haven't read.
- Fix root causes, not symptoms. A null-check, retry, or timeout bump requires
  first answering "why does this state occur at all?"
- Minimal diffs in the codebase's own style. No drive-by refactors.
- Never end a turn on a plan or promise — do the work or report the blocker.

## Working Agreements

- Inspect existing scripts before running build, lint, typecheck, or test commands.
- After TypeScript changes, run the available typecheck or build script.
- Before committing, run the available lint and test scripts when present.
- Do not overwrite user changes or local settings.
- Keep application code files at 500 lines or fewer. If an app code file exceeds 500 lines, refactor it into smaller modules before finishing the task.

## Verification (mandatory before "done")

A successful edit is not verification. Run the strongest available check and
end every task report with exactly one of
`Verified: <what you ran and what it showed>` or
`Unverified: edited but not verified because <reason>`.

- UI change → follow `verify-frontend-change`: open the page with the Chrome
  DevTools MCP, interact with the change, zero new console errors, screenshot.
- Backend/Convex change → follow `verify-backend-change`: run the function
  against the dev deployment with the Convex MCP, read the affected live data,
  check logs.
- Full user journeys → follow `e2e-testing-framework` (Step 0 auth,
  step-by-step, fail-fast, completion report).

## Loops

For work that outlives a single turn, design a loop instead of re-prompting —
see `.codex/skills/agentic-loops/`. Defaults: deterministic done-criteria, an
explicit attempt cap ("stop after 5 attempts"), scheduled `codex exec` runs
matched to how fast the watched thing changes, and a `dev/active/<task>/`
note file so progress survives long sessions.

## Common Commands

- Development server: use the package script that starts the app, commonly `npm run dev`, `pnpm dev`, or `yarn dev`.
- Build: use the project build script when present.
- Lint: use the project lint script when present.
- Typecheck: use the project typecheck script when present, or `npx tsc --noEmit` for TypeScript projects.
- Tests: use the project test script when present.
- App code line limit: run `dev/check-line-limits.sh` when this repo is present, or apply the same 500-line maximum manually.

## Skills

Skills in `.codex/skills/` provide focused guidance:

- `usage-guide` - Map of the kit: which skill/tool/loop to use when, where everything lives, how to maintain or install it.
- `fable-mindset` - Operating principles for agentic coding: evidence, root cause, verification, honest reporting.
- `agentic-loops` - Loop design for long-running/recurring work: goals, scheduled runs, stop conditions.
- `verify-frontend-change` - Browser verification of UI changes via Chrome DevTools MCP.
- `verify-backend-change` - Live-data verification of backend changes via Convex MCP.
- `e2e-testing-framework` - End-to-end browser testing: Step 0 auth, fail-fast, completion reports.
- `convex-backend-dev` - Convex queries, mutations, schema, indexes, validators, actions, and MCP checks.
- `tanstack-start-dev` - TanStack Start server functions, file routes, loaders, middleware, and SSR.
- `stripe-payments` - Stripe in this stack: checkout via Convex actions, webhooks in convex/http.ts, idempotency, test-mode verification.
- `frontend-dev` - React, Tailwind CSS, shadcn/ui, components, forms, layout, and styling.
- `make-interfaces-feel-better` - UI polish details: micro-interactions, animations, radius, shadows, typography, optical alignment.
- `emil-design-eng` - Emil Kowalski's design engineering philosophy: UI polish, component design, animation decisions.
- `apple-design` - Apple-style fluid interfaces for the web: springs, gestures, momentum, interruptibility, depth.
- `animation-vocabulary` - Reverse-lookup glossary: turn a vague motion description into the exact animation term.
- `improve-animations` - Codebase-wide animation audit producing prioritized, self-contained improvement plans.
- `review-animations` - Strict review of animation/motion code against a high craft bar (user-invoked).
- `task-management-dev` - PBI workflow, task docs, backlog, and dev docs.
- `code-simplifier` - Code clarity, refactoring, maintainability, and review cleanup.
- `programmatic-seo` - Data-driven, templated SEO pages at scale.
- `skill-authoring` - Writing and registering skills: descriptions that activate, bodies smaller models can execute, Codex mirroring.
- `hook-development` - Writing, registering, and testing Claude Code and Codex hooks: event contract, exit codes, fail-open design.
- `kit-release-checklist` - Pre-release verification of the kit: static checks, mirror sync, hook smoke tests, install test.

## Hooks

`.codex/config.toml` wires three hooks (scripts in `.codex/hooks/`):

- `bash-guard.py` (PreToolUse) - blocks destructive commands (rm -rf on root/home, force-push to main, `--no-verify`).
- `typecheck.py` (PostToolUse) - runs `tsc --noEmit` after TypeScript edits.
- `line-limit.py` (PostToolUse) - warns when an app code file exceeds 500 lines.

## Task Workflow

Use the PBI workflow when this repository has `docs/delivery/` enabled:

`Proposed -> Agreed -> InProgress -> InReview -> Done`

- Backlog: `docs/delivery/backlog.md`
- PBI directory: `docs/delivery/[PBI-ID]/`
- Task index: `docs/delivery/[PBI-ID]/tasks.md`
- Long-running dev docs: `dev/active/[task-name]/`

For small changes, keep documentation lightweight unless the user asks for full PBI tracking.

## Project Structure

```text
/
├── .claude/          # Claude Code settings, hooks, commands, agents, skills
├── .codex/           # Codex config, hooks, and skills
├── docs/delivery/    # Optional PBI/task workflow
├── dev/active/       # Optional long-task working notes
├── CLAUDE.md         # Claude Code instructions
└── AGENTS.md         # Codex instructions
```

## Kit Protection

Kit content (`.claude/`, `.codex/`, `CLAUDE.md`, `AGENTS.md`,
`dev/check-line-limits.sh`, plus `README.md`/`setup.sh` in the kit source
repo) is locked by the `kit-guard` hook:
models cannot edit or overwrite it. Do not attempt to bypass the guard. If
the user explicitly wants kit maintenance, they unlock it themselves by
running `touch .claude/kit-unlock` (and delete that file when done).
`.claude/settings.local.json`, `dev/active/`, `docs/delivery/`, and all
application code remain writable.

## Local State

- Keep `.claude/settings.local.json` untracked.
- Keep secrets in environment-specific files, not in shared templates.
- Review `.mcp.json` before first use and remove MCP servers that do not apply.
- Codex loads `AGENTS.md` hierarchically. Put broad rules at the repository root and narrow overrides in nested `AGENTS.override.md` files only when needed.
