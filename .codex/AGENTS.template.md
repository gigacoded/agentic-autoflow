# Development Infrastructure

Codex instructions for this repository. Customize project-specific commands after install.

## Working Agreements

- Inspect existing scripts before running build, lint, typecheck, or test commands.
- After TypeScript changes, run the available typecheck or build script.
- Before committing, run the available lint and test scripts when present.
- Do not overwrite user changes or local settings.

## Common Commands

- Development server: use the package script that starts the app, commonly `npm run dev`, `pnpm dev`, or `yarn dev`.
- Build: use the project build script when present.
- Lint: use the project lint script when present.
- Typecheck: use the project typecheck script when present, or `npx tsc --noEmit` for TypeScript projects.
- Tests: use the project test script when present.

## Skills

Skills in `.codex/skills/` provide focused guidance:

- `convex-backend-dev` - Convex queries, mutations, schema, indexes, validators, actions, and MCP checks.
- `tanstack-start-dev` - TanStack Start server functions, file routes, loaders, middleware, and SSR.
- `frontend-dev` - React, Tailwind CSS, shadcn/ui, components, forms, layout, and styling.
- `task-management-dev` - PBI workflow, task docs, backlog, and dev docs.
- `code-simplifier` - Code clarity, refactoring, maintainability, and review cleanup.

## Task Workflow

Use the PBI workflow when this repository has `docs/delivery/` enabled:

`Proposed -> Agreed -> InProgress -> InReview -> Done`

- Backlog: `docs/delivery/backlog.md`
- PBI directory: `docs/delivery/[PBI-ID]/`
- Task index: `docs/delivery/[PBI-ID]/tasks.md`
- Long-running dev docs: `dev/active/[task-name]/`

For small changes, keep documentation lightweight unless the user asks for full PBI tracking.

## Local State

- Keep `.claude/settings.local.json` untracked.
- Keep secrets in environment-specific files, not in shared templates.
- Review `.mcp.json` before first use and remove MCP servers that do not apply.
