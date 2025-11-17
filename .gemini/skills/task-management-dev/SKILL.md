# Task Management & Development Workflow

**Auto-activates when**: Working in `/docs/delivery`, discussing PBIs/tasks, planning features, creating dev docs

## Overview

Meta-skill for managing Product Backlog Items (PBIs) and tasks in the CargoBuddy project. Defines workflows, validation rules, dev docs system, and best practices for task-driven development.

## Core Principles

1. **Task-Driven Development** - No code changes without an approved task
2. **PBI Association** - All tasks link to a PBI
3. **One InProgress Task** - Focus on one task at a time per PBI
4. **Dev Docs for Long Tasks** - Use dev docs for 3+ step tasks
5. **Status Synchronization** - Task status must match in both file and index

## PBI Workflow

### PBI Status Lifecycle

```
Proposed → Agreed → InProgress → InReview → Done
                ↓                    ↓
              Rejected          Rejected
```

### Starting a New PBI

1. **Create PBI Directory**:
   ```bash
   mkdir -p docs/delivery/{PBI-ID}
   ```

2. **Create PBI Detail Document** (`prd.md`):
   - Problem statement
   - User stories
   - Technical approach
   - Conditions of Satisfaction
   - Dependencies

3. **Create Tasks List** (`tasks.md`):
   - Break down PBI into small tasks
   - Each task = cohesive, testable unit
   - E2E test task at the end (if user-facing)

4. **Update Backlog**:
   - Add PBI to `docs/delivery/backlog.md`
   - Status: "Proposed"
   - Link to detail document

### PBI Status Transitions

**Proposed → Agreed**:
- User approves PBI scope
- All Conditions of Satisfaction clear
- Tasks broken down and approved

**Agreed → InProgress**:
- First task marked InProgress
- Dev docs created (if applicable)

**InProgress → InReview**:
- All tasks completed
- **E2E test passing** (if applicable)
- Documentation updated

**InReview → Done**:
- User reviewed and approved
- **E2E test completion report reviewed**
- All recommendations addressed
- Code merged to main

---

## Task Workflow

### Task Status Lifecycle

```
Proposed → Agreed → InProgress → Review → Done
                        ↓
                     Blocked
```

### Task File Structure

Every task MUST have:

```markdown
# [Task-ID] [Task-Name]

## Description
What this task accomplishes

## Status History
| Timestamp | Event Type | From Status | To Status | Details | User |
|-----------|------------|-------------|-----------|---------|------|
| ...       | ...        | ...         | ...       | ...     | ...  |

## Requirements
- Functional requirements
- Non-functional requirements
- Dependencies

## Implementation Plan
Step-by-step plan for implementation

## Test Plan
How this task will be tested

## Verification
Success criteria for task completion

## Files Modified
List of all files changed
```

### Creating a New Task

1. **Add to Tasks Index** (`docs/delivery/{PBI-ID}/tasks.md`):
   ```markdown
   | {PBI-ID}-{N} | [Task Name](./{PBI-ID}-{N}.md) | Proposed | Description |
   ```

2. **Create Task File** (`{PBI-ID}-{N}.md`):
   - Use template structure above
   - Fill in Description, Requirements
   - Create Implementation Plan
   - Define Test Plan

3. **Link Back to Index**:
   ```markdown
   [Back to task list](./tasks.md)
   ```

### Task Status Transitions

**Proposed → Agreed**:
- User approves task
- Implementation plan reviewed
- Test plan approved

**Agreed → InProgress**:
- No other InProgress tasks for this PBI
- All dependencies met
- Task file fully documented

**InProgress → Review**:
- All requirements met
- Tests passing
- Code changes complete
- Documentation updated

**Review → Done**:
- User approved changes
- Build succeeds
- No TypeScript errors
- Task documentation complete
- **Review next task relevance** - Check if subsequent tasks still needed

### Task Validation Rules

Before starting work:
1. ✅ Task exists in both index and file
2. ✅ Task status is "Agreed"
3. ✅ No other InProgress tasks for PBI
4. ✅ All dependencies resolved
5. ✅ Task file fully documented

During implementation:
1. ✅ Reference task ID in commit messages
2. ✅ Update "Files Modified" section
3. ✅ Keep task file updated with progress

Before marking Done:
1. ✅ All requirements met
2. ✅ Tests passing
3. ✅ Build succeeds (no TypeScript errors)
4. ✅ Documentation complete
5. ✅ Review next task relevance

---

## Dev Docs System

**Purpose**: Prevent "Claude amnesia" during long tasks with 3+ steps.

### When to Use Dev Docs

Use dev docs for:
- ✅ Large features (3+ steps)
- ✅ Complex refactors
- ✅ Multi-file changes
- ✅ Tasks spanning multiple sessions

Don't use for:
- ❌ Single-file changes
- ❌ Simple bug fixes
- ❌ 1-2 step tasks

### Dev Docs Structure

Create three files in `/dev/active/{task-name}/`:

1. **`{task-name}-plan.md`** - The approved plan
   - High-level approach
   - Architecture decisions
   - Implementation phases

2. **`{task-name}-context.md`** - Key context and decisions
   - Important files and their roles
   - Design decisions made
   - Blockers encountered
   - Next steps
   - **Last Updated**: timestamp

3. **`{task-name}-tasks.md`** - Checklist
   - [ ] Task 1
   - [x] Task 2 (completed)
   - [ ] Task 3
   - **Progress**: 1/3 tasks complete

### Dev Docs Workflow

**Starting Large Task**:
1. Enter planning mode
2. Create comprehensive plan
3. Exit planning mode with approved plan
4. Run `/create-dev-docs` command
5. Creates all three files in `/dev/active/`

**During Implementation**:
1. Update `context.md` with decisions and blockers
2. Mark tasks in `tasks.md` as completed immediately
3. Update "Last Updated" timestamp

**Before Auto-Compaction**:
1. Run `/update-dev-docs` command
2. Claude updates context with current progress
3. Marks completed tasks
4. Documents next steps

**Continuing After Compaction**:
1. Check `/dev/active/` for existing tasks
2. Read all three files
3. Continue from "Next Steps"

### Dev Docs Commands

**`/create-dev-docs`**:
- Converts approved plan to dev doc files
- Creates directory structure
- Initializes task checklist

**`/update-dev-docs`**:
- Updates context with current state
- Marks completed tasks
- Documents next steps
- Run before auto-compaction

**`/dev-docs-status`**:
- Shows progress overview
- Lists active dev docs
- Displays completion percentage

---

## Best Practices

### Task Granularity

**Good Task Size**:
- Takes 1-4 hours to complete
- Represents cohesive unit of work
- Has clear success criteria
- Can be tested independently

**Too Large** (break it down):
- "Implement entire quote system" ❌
- "Add all authentication" ❌
- "Refactor everything" ❌

**Good Examples**:
- "Create quote submission form UI" ✅
- "Add authentication check to quotes API" ✅
- "Refactor JobCard component to use new layout" ✅

### Commit Messages

Format: `{task-id} {task-description}`

Examples:
```
260-1 Create e2e-testing-framework skill
240-4 Driver 1 submits quote on matched job
218-3 Implement badge hierarchy for job status
```

### Documentation

**Always Document**:
- Why (rationale for decisions)
- Tradeoffs considered
- Dependencies between tasks
- Assumptions made

**Don't Document**:
- How code works (code should be self-documenting)
- Obvious implementation details
- Redundant information

### Planning

**Before Starting PBI**:
1. Enter planning mode
2. Research codebase
3. Create comprehensive task breakdown
4. Review plan with user
5. Get approval before implementing

**During Planning**:
- Ask questions about unclear requirements
- Propose multiple approaches if applicable
- Identify dependencies early
- Break down into small tasks

---

## Common Patterns

### Pattern: Feature Implementation

```
1. Research existing patterns
2. Create UI components
3. Create backend queries/mutations
4. Wire up frontend to backend
5. Add error handling
6. Add loading states
7. E2E test workflow
```

### Pattern: Bug Fix

```
1. Reproduce bug
2. Identify root cause
3. Write failing test
4. Fix code
5. Verify test passes
6. Document fix
```

### Pattern: Refactoring

```
1. Identify code smell
2. Write tests for existing behavior
3. Refactor code
4. Verify tests still pass
5. Document improvements
```

---

## File Organization

```
docs/
└── delivery/
    ├── backlog.md           # All PBIs
    ├── {PBI-ID}/
    │   ├── prd.md          # PBI detail document
    │   ├── tasks.md        # Task index
    │   └── {PBI-ID}-{N}.md # Individual tasks
    └── ...

dev/
└── active/                  # Active dev docs
    └── {task-name}/
        ├── {task-name}-plan.md
        ├── {task-name}-context.md
        └── {task-name}-tasks.md
```

---

## Resources

For detailed workflows, see:
- **[Task Templates](./resources/task-templates.md)** - Templates for task files
- **[Dev Docs Templates](./resources/dev-docs-templates.md)** - Dev docs file templates
- **[Planning Checklist](./resources/planning-checklist.md)** - Pre-implementation checklist

---

## Quick Reference

**Create PBI**:
1. Create directory: `docs/delivery/{PBI-ID}/`
2. Create `prd.md` and `tasks.md`
3. Add to backlog.md

**Create Task**:
1. Add to tasks.md index
2. Create `{PBI-ID}-{N}.md` file
3. Fill in all required sections

**Start Task**:
1. Mark status "InProgress"
2. Create dev docs if 3+ steps
3. Update status in both file and index

**Complete Task**:
1. All tests passing
2. Build succeeds
3. Documentation complete
4. Mark status "Done" in both locations
5. Commit: `{task-id} {description}`

**Dev Docs**:
- Create: `/create-dev-docs`
- Update: `/update-dev-docs`
- Status: `/dev-docs-status`
