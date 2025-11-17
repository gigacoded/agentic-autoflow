# Agent Configuration Protocol

**IMPORTANT**: This project uses a skill-based architecture inspired by [universal-agents](https://github.com/leochiu-a/universal-agents). Before responding to ANY request, you MUST follow this protocol:

## Execution Protocol

1. **Read this entire file** to understand available skills and rules
2. **Determine relevance** - Which skills match the current task?
3. **Load skills** - Use `@.agents/skills/{skill-name}.md` to load relevant skills
4. **Apply rules** - Load ALL files from `.agents/rules/` (these always apply)
5. **Declare usage** - Start your response with: `**Skills**: {list} | **Rules**: {list}`

## Available Skills

Load these **on-demand** from `.agents/skills/` based on triggers:

### `convex-backend`
**Triggers**: "convex", "backend", "query", "mutation", "action", "database", "schema", working in `convex/`
**Purpose**: Convex backend development patterns with MCP integration
**Load**: `@.agents/skills/convex-backend.md`

### `nextjs-frontend`
**Triggers**: "next", "frontend", "component", "page", "route", "ui", working in `app/`, `components/`
**Purpose**: Next.js 14 App Router + React + Tailwind + shadcn/ui patterns
**Load**: `@.agents/skills/nextjs-frontend.md`

### `e2e-testing`
**Triggers**: "e2e", "test", "testing", "chrome", "browser", working in `test/`
**Purpose**: E2E testing framework with Chrome DevTools MCP
**Load**: `@.agents/skills/e2e-testing.md`

### `task-management`
**Triggers**: "pbi", "task", "backlog", "dev docs", working in `docs/delivery/`
**Purpose**: PBI workflow and dev docs system for long tasks
**Load**: `@.agents/skills/task-management.md`

## Rules (Always Active)

Load **ALL** files from `.agents/rules/` - these apply to EVERY response:

- `api-patterns.md` - API design conventions
- `component-structure.md` - Component organization rules
- `commit-format.md` - Git commit message format
- `error-handling.md` - Error handling patterns

## Response Format

Always start your response with:

```
**Skills**: convex-backend, nextjs-frontend | **Rules**: api-patterns, component-structure

[Your response here...]
```

## Skill Loading Examples

### Example 1: Convex Query Request

**User**: "Create a Convex query to fetch users"

**You should**:
1. Recognize triggers: "convex", "query"
2. Load: `@.agents/skills/convex-backend.md`
3. Load all rules from `.agents/rules/`
4. Respond with declaration

### Example 2: Frontend Component Request

**User**: "Add a new user profile component"

**You should**:
1. Recognize triggers: "component"
2. Load: `@.agents/skills/nextjs-frontend.md`
3. Load all rules from `.agents/rules/`
4. Respond with declaration

### Example 3: Multiple Skills

**User**: "Create a new feature with backend query and frontend component"

**You should**:
1. Recognize triggers: "backend query", "frontend component"
2. Load: `@.agents/skills/convex-backend.md` AND `@.agents/skills/nextjs-frontend.md`
3. Load all rules from `.agents/rules/`
4. Respond with both skills declared

## Custom Commands

Use custom commands for common workflows:

- `/skill {name}` - Explicitly load a specific skill
- `/check` - Run quality checks (TypeScript, linting)
- `/dev-docs` - Create/update dev docs for current task

These commands are defined in `.agents/commands/` as TOML files.

## Why This Protocol?

**Gemini CLI doesn't have hooks** like Claude Code, so we can't auto-inject context based on triggers. Instead, this protocol:

1. **Teaches you** to recognize when skills are relevant
2. **Explicitly loads** skills using Gemini CLI's `@` syntax
3. **Maintains transparency** by declaring what was loaded
4. **Mimics Claude Code workflow** while working WITH Gemini CLI's architecture

## Hierarchical Context

In addition to skills, Gemini CLI automatically loads GEMINI.md files:

- **Global**: `~/.gemini/GEMINI.md` (your personal defaults)
- **Project**: `.gemini/GEMINI.md` (project root - always loaded)
- **Directory**: `.gemini/app/GEMINI.md`, `.gemini/convex/GEMINI.md` (context-specific)

These files remind you to load relevant skills from `.agents/skills/`.

## Verification

Before responding, verify:
- [ ] Did I read AGENTS.md?
- [ ] Did I determine which skills are relevant?
- [ ] Did I load those skills using `@.agents/skills/{name}.md`?
- [ ] Did I load all rules from `.agents/rules/`?
- [ ] Did I declare what I loaded in my response?

**This protocol ensures consistent, high-quality responses using project-specific patterns.**

---

*Version: 1.0 - Gemini CLI Edition*
*Based on: [universal-agents](https://github.com/leochiu-a/universal-agents) + Agentic AutoFlow template*
