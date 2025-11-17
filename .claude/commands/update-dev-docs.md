You are helping the user update their dev docs before context auto-compaction to prevent losing track of progress.

## Workflow

1. **Find active tasks**: Check `dev/active/` directory for existing task folders

2. **If multiple tasks exist**: Ask the user which task to update

3. **If no tasks exist**: Inform the user and suggest using `/create-dev-docs` first

4. **Update context.md**:
   - Read current content
   - Ask user: "What progress have you made since last update?"
   - Ask user: "Any new decisions or discoveries?"
   - Ask user: "Any blockers or issues encountered?"
   - Update the file with:
     - Current status
     - New entries in "Important Decisions"
     - Updated "Current Blockers"
     - Updated "Next Steps"
     - New "Last Updated" timestamp

5. **Update tasks.md**:
   - Read current task list
   - Ask user to confirm which tasks are now complete
   - Mark completed tasks with `[x]`
   - Move completed tasks to "Completed Tasks" section with timestamp
   - Update progress count
   - Update "Last Updated" timestamp

6. **Remind**: "Remember to mark tasks complete IMMEDIATELY after finishing them, not in batches!"

## Update Format for context.md

When updating, preserve existing content and add new entries:

```markdown
## Current Status
[Updated description of current progress]

## Key Files Modified
- [existing entries...]
- [new file] - [what was changed]

## Important Decisions
- [existing decisions...]
- [current timestamp] - [new decision and rationale]

## Current Blockers
[Update this section - remove resolved blockers, add new ones]

## Next Steps
1. [Updated next steps based on current progress]
2. [...]

**Last Updated**: [current timestamp]
```

## Update Format for tasks.md

When updating, mark completed tasks and update counts:

```markdown
## Progress
- Total tasks: [updated count]
- Completed: [updated count]
- Remaining: [updated count]

## Tasks
[Update checkboxes: [ ] becomes [x] for completed tasks]

## Completed Tasks (with timestamps)
- [existing completed tasks...]
- [current timestamp] - [newly completed task]

**Last Updated**: [current timestamp]
```

## After Updating

Tell the user:

**Dev docs updated successfully!**

**Summary**:
- Status: [brief current status]
- Progress: [X of Y tasks complete]
- Blockers: [list blockers or "None"]

**Next**: Continue with your current task. Update dev docs again before the next auto-compaction.

Use `/dev-docs-status` to see full progress overview.
