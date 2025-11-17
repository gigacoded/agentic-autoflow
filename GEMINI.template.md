# {{PROJECT_NAME}} Development Infrastructure

Quick reference for {{PROJECT_NAME}} development. See `.gemini/skills/` for detailed patterns and best practices.

> **Template Note**: Replace `{{PROJECT_NAME}}` with your actual project name. Customize the Quick Start commands and Project Structure sections for your stack.

## Quick Start

**Development**:
- `{{DEV_SERVER_COMMAND}}` - Start development server (e.g., `npm run dev`, `yarn dev`)
- `{{BACKEND_COMMAND}}` - Start backend if separate (e.g., `npx convex dev`, optional)

**Build & Quality**:
- `{{BUILD_COMMAND}}` - Build for production (e.g., `npm run build`)
- `{{LINT_COMMAND}}` - Lint code (e.g., `npm run lint`)
- `{{TYPECHECK_COMMAND}}` - Type checking (e.g., `npm run typecheck`, optional)

**Testing**:
- Configure testing strategy in skills (see Skills System below)
- E2E tests can use Chrome DevTools MCP (optional `e2e-testing-framework` skill)

---

## Skills System

Auto-activating skills provide consistent patterns without manual reminders.

**Core Skill (Always Included)**:

1. **`task-management-dev`** - PBI/task workflow, dev docs system
   - Auto-activates: "pbi", "task", "backlog", working in `/docs/delivery`
   - Provides structured project management workflow

**Optional Project-Specific Skills** (Add as needed):

2. **`e2e-testing-framework`** - E2E testing with Chrome DevTools MCP
   - Mandatory 4-part structure: Step 0 auth, step-by-step, fail-fast, rich reports
   - Auto-activates: "e2e", "test", "chrome", "browser"

3. **`backend-dev`** - Backend patterns (customize for your stack)
   - Auth patterns, error handling, monitoring integration
   - Auto-activates: "backend", working in backend directories

4. **`frontend-dev-guidelines`** - Frontend patterns (customize for your stack)
   - Component patterns, styling, performance
   - Auto-activates: "frontend", working in frontend directories

**Skills activate automatically** based on keywords, file paths, and intent patterns defined in `.gemini/skills/skill-rules.json`.

### Customizing Skills

1. **Keep** `task-management-dev` (core workflow skill)
2. **Delete** skills not relevant to your stack
3. **Customize** existing skills for your tech stack
4. **Create** new skills for your project-specific patterns

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

### Task-Driven Development

1. **No code changes without a task** - All work must have an approved task
2. **No tasks without a PBI** - Tasks must link to Product Backlog Items
3. **User authority** - User is sole decider for scope and design
4. **No unapproved changes** - Changes outside task scope are prohibited

### PBI Workflow

**Status Flow**: Proposed → Agreed → InProgress → InReview → Done

**Key Rules**:
- Each PBI has dedicated directory: `docs/delivery/[PBI-ID]/`
- PBI detail document: `[PBI-ID]/prd.md`
- Task list: `[PBI-ID]/tasks.md`
- Test task required for user-facing features (E2E, integration, or manual)

See `task-management-dev` skill for complete workflow.

### Task Workflow

**Status Flow**: Proposed → Agreed → InProgress → Review → Done

**Key Rules**:
- Each task has file: `docs/delivery/[PBI-ID]/[PBI-ID]-[TASK-ID].md`
- Task status must match in both index and task file
- Only ONE task InProgress per PBI (unless approved)
- Status changes logged in task history

**Required Task Sections**:
- Description
- Status History
- Requirements
- Implementation Plan
- Verification
- Files Modified

See `task-management-dev` skill for complete workflow.

---

## Testing Strategy

Configure your testing approach based on your stack:

### Option 1: E2E Testing (Browser)
- Uses Chrome DevTools MCP (if available)
- Mandatory for user-facing web applications
- See `e2e-testing-framework` skill for complete framework

### Option 2: Backend Testing
- Unit tests for business logic
- Integration tests for APIs
- Configure patterns in backend skill

### Option 3: Frontend Testing
- Component testing
- Integration tests
- Configure patterns in frontend skill

**Customize this section** based on your project's testing needs.

---

## Project Structure

```
/
├── {{SOURCE_DIR}}/         # Source code (e.g., app/, src/, lib/)
├── {{COMPONENTS_DIR}}/     # Components (if applicable)
├── {{BACKEND_DIR}}/        # Backend code (if applicable)
├── docs/
│   ├── delivery/           # PBIs and tasks (REQUIRED)
│   └── architecture/       # Architecture docs (optional)
├── dev/active/             # Active dev docs (for long tasks)
├── .gemini/
│   ├── skills/             # Auto-activating skills
│   └── commands/           # Slash commands
└── GEMINI.md              # This file
```

**Customize** the directory names above to match your project structure.

---

## Project-Specific Rules

> **Template Note**: Add project-specific conventions, patterns, and rules here. Examples:

### Example: Constants Rule

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

### Example: Error Handling

All errors must be logged to monitoring service:

```typescript
try {
  // operation
} catch (error) {
  logger.error(error, { context: "relevant info" });
  throw error;
}
```

**Customize** this section with your project's specific patterns and conventions.

---

## Important Links

- **Backlog**: [`docs/delivery/backlog.md`](./docs/delivery/backlog.md)
- **Skills**: [`.gemini/skills/`](./.gemini/skills/)
- **Active Dev Docs**: `dev/active/` (if exists)

---

## Quick Reference

### Git Workflow

**Commit Message Format** (when task moves to Done):
```
[task-id] [task-description]
```

**Pull Request Title**:
```
[PBI-ID] [PBI-description]
```

### File Creation Policy

- **NEVER create files** unless absolutely necessary
- **ALWAYS prefer editing** existing files
- **NEVER create** documentation files (`.md`) proactively
- Exception: Files explicitly defined in task requirements (PBIs, tasks, skills, etc.)

---

## Getting Help

- **PBI/Task Workflow**: Reference `task-management-dev` skill
- **Dev Docs**: Use `/create-dev-docs`, `/update-dev-docs`, `/dev-docs-status`
- **Project-Specific**: Reference your custom skills

Skills activate automatically based on context!

---

## Customization Checklist

After copying this template to your project:

- [ ] Replace all `{{PLACEHOLDERS}}` with actual values
- [ ] Update Quick Start commands for your stack
- [ ] Customize Project Structure section
- [ ] Delete irrelevant skills from `.gemini/skills/`
- [ ] Add project-specific rules and patterns
- [ ] Update testing strategy for your needs
- [ ] Verify all links point to correct locations
- [ ] Remove this customization checklist
- [ ] Rename to `GEMINI.md` (remove `.template`)

---

**Version**: 3.0 (Universal Template - 2025-11-17)
**Source**: Based on QuoteWithAI working infrastructure
**License**: MIT - Feel free to adapt for your projects
