# Project Root Context

**IMPORTANT**: Before responding to any request, read and follow: @AGENTS.md

This project uses a skill-based architecture with on-demand loading.

## Quick Reference

**Tech Stack**: Next.js 14 + Convex + React + Tailwind + shadcn/ui

**Development**:
- `npm run dev` - Start development servers
- `npm run build` - Build for production
- `npm run lint` - Run linter

**Custom Commands**:
- `/skill {name}` - Load a specific skill
- `/check` - Run quality checks
- `/dev-docs` - Create/update dev docs
- `/context` - Show current context

## Skills Available

Load these on-demand from `.agents/skills/` based on what you're working on:

- `convex-backend` - For backend/database work
- `nextjs-frontend` - For frontend/UI work
- `e2e-testing` - For testing work
- `task-management` - For planning/documentation work

## How This Works

1. Gemini CLI loads this file automatically (you're in project root)
2. You read @AGENTS.md to understand the protocol
3. You determine which skills are relevant for the current task
4. You load those skills using `@.agents/skills/{name}.md`
5. You apply all rules from `.agents/rules/`
6. You declare what you loaded in your response

**Example**: If working on a Convex query, you would:
- Load: `@.agents/skills/convex-backend.md`
- Load: All files from `.agents/rules/`
- Declare: `**Skills**: convex-backend | **Rules**: api-patterns, ...`
