# [Your Project Name] Development Infrastructure

Quick reference for [project name] development. See `.gemini/skills/` for detailed patterns and best practices.

## Quick Start

**Development**:
- `[your dev command]` - Start development server
- `[other key command]` - Description

**Build & Quality**:
- `[build command]` - Build for production
- `[lint command]` - Lint code
- `[typecheck command]` - Type checking

**Testing**:
- `[test command]` - Run tests
- `[e2e command]` - E2E tests (if applicable)

---

## Skills System

Auto-activating skills provide consistent patterns without manual reminders:

1. **`[skill-name-1]`** - [Brief description]
   - Auto-activates: [triggers like "backend", "api", working in `/src/api`]

2. **`[skill-name-2]`** - [Brief description]
   - Auto-activates: [triggers]

3. **`[skill-name-3]`** - [Brief description]
   - Auto-activates: [triggers]

**Skills activate automatically** based on keywords, file paths, and intent patterns defined in `.gemini/skills/skill-rules.json`.

---

## Dev Docs System

For large tasks (3+ steps), use dev docs to prevent context loss during auto-compaction:

**Commands**:
- `/create-dev-docs` - Initialize dev docs for new task
- `/update-dev-docs` - Update progress before auto-compaction
- `/dev-docs-status` - Show progress overview

**Location**: `dev/active/[task-name]/`

**Files Created**:
- `[task-name]-plan.md` - Approved plan
- `[task-name]-context.md` - Decisions, blockers, status
- `[task-name]-tasks.md` - Checklist (markdown checkboxes)

**Rule**: Mark tasks complete IMMEDIATELY after finishing, not in batches!

---

## Core Development Principles

### [Your Workflow - Examples Below]

1. **Principle 1** - Description
2. **Principle 2** - Description
3. **Principle 3** - Description

### [Optional: Task-Driven Development]

If using the task workflow:

**Status Flow**: Proposed → Agreed → InProgress → Review → Done

**Key Rules**:
- No code changes without a task
- User is sole decider for scope and design
- Complete audit trail in task files

See `task-management` skill for complete workflow (if applicable).

---

## Build & Quality MCP Servers

MCP servers extend Gemini CLI with custom tools and automation:

**Skill Activation MCP** (Available):
- Analyzes prompts for skill triggers
- Provides skill recommendations based on context

**Quality Check MCP** (Available):
- Checks [TypeScript/your language] errors after edits
- Fail-fast prevents cascading errors

Configure in `~/.gemini/settings.json` to enable these extensions.

---

## Project Structure

```
/
├── [your directories]      # Description
├── [structure]             # Description
├── docs/
│   └── delivery/           # (Optional) Task-driven development
├── dev/active/             # Active dev docs (for long tasks)
├── .gemini/
│   ├── skills/             # Auto-activating skills
│   ├── mcp-servers/        # Custom MCP servers
│   └── commands/           # Custom commands
└── GEMINI.md              # This file
```

---

## [Your Project-Specific Sections]

### Example: Important Constants Rule

Any value used more than once must be defined as a named constant:

**Bad**:
```typescript
for (let i = 0; i < 10; i++) { ... }
```

**Good**:
```typescript
const MAX_ITEMS = 10;
for (let i = 0; i < MAX_ITEMS; i++) { ... }
```

### Example: Error Handling Pattern

[Your error handling approach]

```typescript
try {
  // operation
} catch (error) {
  // your error handling pattern
  throw error;
}
```

---

## Important Links

- **[Link Name]**: [`path/to/file.md`](./path/to/file.md)
- **Skills**: [`.gemini/skills/`](./.gemini/skills/)
- **Active Dev Docs**: `dev/active/` (if exists)

---

## Quick Reference

### Git Workflow (If Applicable)

**Commit Message Format**:
```
[scope] Brief description

Details if needed
```

**Pull Request Title**:
```
[Feature/Fix] Description
```

### File Creation Policy

- **NEVER create files** unless absolutely necessary
- **ALWAYS prefer editing** existing files
- **NEVER create** documentation files (`.md`) proactively
- Exception: Files explicitly defined in task requirements

---

## Getting Help

- **[Topic 1]**: Activate `[skill-name]` skill
- **[Topic 2]**: Activate `[skill-name]` skill
- **Dev Docs**: Use `/create-dev-docs`, `/update-dev-docs`, `/dev-docs-status`

Skills activate automatically - no need to invoke manually!

---

**Version**: 1.0 (Initial Setup - [DATE])
**Based On**: [Agentic AutoFlow - Gemini CLI Edition](https://github.com/yourusername/agentic-autoflow/tree/gemini-cli)
