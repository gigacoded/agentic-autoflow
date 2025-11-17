# Product Backlog

This document contains all Product Backlog Items (PBIs) for your project, ordered by priority.

## Backlog Table

| ID | Actor | User Story | Status | Conditions of Satisfaction (CoS) |
|----|-------|------------|--------|----------------------------------|
| [1](./1/prd.md) | {{ACTOR}} | As a {{ACTOR}}, I want to {{ACTION}} so that {{BENEFIT}} | Proposed | - Acceptance criterion 1<br>- Acceptance criterion 2<br>- Acceptance criterion 3 |

<!--
Add more PBIs here following the same format.

Each PBI should have:
- Unique ID (sequential number)
- Actor (who benefits: User, Developer, Admin, etc.)
- User story in the format: "As a [actor], I want to [action] so that [benefit]"
- Status: Proposed, Agreed, InProgress, InReview, Done, Not Needed
- Conditions of Satisfaction (clear, testable acceptance criteria)

For detailed format, see examples in ./examples/
-->

---

## Changelog

Track major backlog events here:

| Date | PBI | Action | Notes | Author |
|------|-----|--------|-------|--------|
| {{DATE}} | 1 | create_pbi | Initial PBI created | {{AUTHOR}} |

<!--
Changelog Actions:
- create_pbi: New PBI added to backlog
- propose_for_backlog: PBI moved from idea to Proposed status
- approve: PBI moved to Agreed status
- start_implementation: PBI moved to InProgress status
- complete: PBI moved to Done status
- archive: PBI moved to Not Needed status
-->

---

## Status Definitions

- **Proposed**: PBI drafted, awaiting approval
- **Agreed**: PBI approved, ready for implementation
- **InProgress**: Work actively underway
- **InReview**: Implementation complete, under review
- **Done**: Shipped to production, verified
- **Not Needed**: PBI cancelled or deemed unnecessary

---

## Usage Notes

### Creating a New PBI

1. Add entry to Backlog Table with unique ID
2. Create directory: `docs/delivery/[PBI-ID]/`
3. Create PRD: `docs/delivery/[PBI-ID]/prd.md`
4. Create tasks: `docs/delivery/[PBI-ID]/tasks.md`
5. Update status to Proposed
6. Add changelog entry

### Moving PBI Through Workflow

1. **Proposed → Agreed**: User/stakeholder approval
2. **Agreed → InProgress**: Begin implementation
3. **InProgress → InReview**: Implementation complete
4. **InReview → Done**: Reviewed and deployed
5. Update changelog for each status change

### PBI Best Practices

- Keep user stories focused (one feature per PBI)
- Make Conditions of Satisfaction testable
- Break large PBIs into smaller ones
- Update status promptly as work progresses
- Document decisions in PBI directory

---

For detailed PBI and task workflow, see `.claude/skills/task-management-dev/SKILL.md`
