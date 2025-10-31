You are helping the user create dev docs for a new task to prevent context loss during long implementations.

## Workflow

1. **Ask for task name**: Prompt the user for a task identifier (e.g., "implement-quote-system", "pbi-240-enrichment")

2. **Create directory structure**:
   ```
   dev/active/[task-name]/
   ```

3. **Create three files** using the templates below

4. **Confirm creation** and explain the dev docs workflow

## Templates

### File 1: `[task-name]-plan.md`

```markdown
# [Task Name] - Implementation Plan

**Created**: [current timestamp]

## Objective
[One-sentence description of what this task achieves]

## Approved Plan
[The plan that was approved by the user - paste from conversation or PBI]

## Key Design Decisions
- [Decision 1 and rationale]
- [Decision 2 and rationale]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Related Documentation
- PBI: [link to docs/delivery/[pbi-id]/prd.md if applicable]
- Tasks: [link to docs/delivery/[pbi-id]/tasks.md if applicable]
```

### File 2: `[task-name]-context.md`

```markdown
# [Task Name] - Context

**Last Updated**: [current timestamp]

## Current Status
Just started - dev docs created

## Key Files Modified
[Will be populated as work progresses]

## Important Decisions
- [timestamp] - Created dev docs structure

## Current Blockers
None

## Next Steps
1. [First immediate step from the plan]
2. [Second step]
3. [Third step]

## Notes
[Any additional context, gotchas, or important information]
```

### File 3: `[task-name]-tasks.md`

```markdown
# [Task Name] - Task Checklist

**Last Updated**: [current timestamp]

## Progress
- Total tasks: [count from below]
- Completed: 0
- Remaining: [count]

## Tasks

### Setup & Planning
- [x] Create dev docs structure
- [ ] [Setup task 1]
- [ ] [Setup task 2]

### Implementation
- [ ] [Implementation task 1]
- [ ] [Implementation task 2]
- [ ] [Implementation task 3]

### Testing & Verification
- [ ] [Test task 1]
- [ ] [Test task 2]

### Documentation & Cleanup
- [ ] Update relevant documentation
- [ ] Code review and cleanup
- [ ] Mark PBI/task as complete

## Completed Tasks (with timestamps)
- [timestamp] - Created dev docs structure

---

**Important**: Mark tasks as complete IMMEDIATELY after finishing them, not in batches!
Use `/update-dev-docs` to update this file before context auto-compaction.
```

## After Creating Files

Tell the user:

**Dev docs created successfully!**

Your dev docs are in: `dev/active/[task-name]/`

**Workflow**:
- Update `[task-name]-context.md` regularly as you work
- Mark tasks complete in `[task-name]-tasks.md` IMMEDIATELY (not batched!)
- Use `/update-dev-docs` before context auto-compaction
- Use `/dev-docs-status` to see progress

**Next**: Start working on your first task and update the dev docs as you progress.
