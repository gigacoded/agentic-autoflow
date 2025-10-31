You are showing the user an overview of their current dev docs status and progress.

## Workflow

1. **Check for active tasks**: Look in `dev/active/` directory

2. **If no tasks exist**: Inform the user that no dev docs are currently active. Suggest using `/create-dev-docs` to start tracking a new task.

3. **For each active task**, read the three files and extract:
   - Task name (from directory name)
   - Progress from `[task-name]-tasks.md` (completed vs total)
   - Last updated timestamp from `[task-name]-context.md`
   - Current blockers from `[task-name]-context.md`
   - Current status from `[task-name]-context.md`

4. **Display formatted status report**

## Status Report Format

### Single Active Task

```
📋 Dev Docs Status

**Task**: [task-name]
**Status**: [current status from context.md]
**Progress**: [X] of [Y] tasks complete ([Z]%)
**Last Updated**: [timestamp from context.md]

**Current Blockers**:
[list blockers or "None"]

**Next Steps**:
1. [next step from context.md]
2. [...]

---

💡 **Tips**:
- Use `/update-dev-docs` to update progress
- Mark tasks complete IMMEDIATELY after finishing
- Update before context auto-compaction events
```

### Multiple Active Tasks

```
📋 Dev Docs Status

**Active Tasks**: [count]

1. **[task-name-1]**
   - Progress: [X] of [Y] complete ([Z]%)
   - Last Updated: [timestamp]
   - Blockers: [list or "None"]

2. **[task-name-2]**
   - Progress: [X] of [Y] complete ([Z]%)
   - Last Updated: [timestamp]
   - Blockers: [list or "None"]

---

💡 **Tips**:
- Use `/update-dev-docs` to update a specific task
- Consider finishing one task before starting another
```

### Stale Warning

If any task hasn't been updated in more than 2 hours, add:

```
⚠️ **Stale Dev Docs Detected**:
- [task-name] was last updated [X hours] ago
- Consider running `/update-dev-docs` to capture recent progress
```

## Detailed View

If user wants more detail, also show:

```
📝 **Recent Activity** (from completed tasks):
- [timestamp] - [completed task 1]
- [timestamp] - [completed task 2]
- [timestamp] - [completed task 3]

📁 **Key Files Modified**:
[list from context.md]

🎯 **Success Criteria**:
[show checkboxes from plan.md]
```

## No Active Tasks

If no tasks found:

```
📋 Dev Docs Status

**No active dev docs found.**

You haven't created dev docs for any tasks yet.

💡 **Get started**:
- Use `/create-dev-docs` to start tracking a new task
- Dev docs help prevent context loss during long implementations
- Especially useful for tasks with 3+ steps
```

## After Showing Status

Offer relevant actions:

- If task is near completion (>80%): "You're almost done! [X] tasks remaining."
- If blockers exist: "Current blockers may need attention before proceeding."
- If stale (>2 hours): "Consider updating dev docs with recent progress."
- If multiple tasks: "Focus on completing one task before starting another."
