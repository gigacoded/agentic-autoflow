# [Your Project Name]

[Brief description of your project and what it does.]

## Working Agreements

- Run `[build command]` after modifying TypeScript files to check for errors
- Run `[lint command]` before committing
- [Add your project-specific working agreements]

## Development

- `[dev command]` - Start development server
- `[other command]` - Description

## Build & Quality

- `[build command]` - Build for production
- `[lint command]` - Lint code
- `[typecheck command]` - TypeScript checks

## Project Structure

```
/
├── [your directories]/    # Description
├── [structure]/           # Description
├── docs/delivery/         # PBIs and task tracking
└── .codex/skills/         # Codex skills for domain-specific guidance
```

## Architecture

- **Frontend**: [Your frontend stack]
- **Backend**: [Your backend stack]
- **Auth**: [Your auth approach]

## Coding Standards

- [Your key coding standards]
- [Framework-specific conventions]
- [Testing requirements]

## Skills

Skills in `.codex/skills/` provide domain-specific guidance:

- **convex-backend-dev** - Convex patterns, indexing, performance optimization
- **frontend-dev** - React, TanStack Start, Tailwind CSS, shadcn/ui patterns
- **task-management-dev** - PBI/task workflow, dev docs system
- **code-simplifier** - Code clarity, consistency, maintainability

## Task Workflow

All work follows the PBI workflow: `Proposed -> Agreed -> InProgress -> InReview -> Done`

- PBIs tracked in `docs/delivery/backlog.md`
- Each PBI has a directory: `docs/delivery/[PBI-ID]/`
- Tasks tracked in `docs/delivery/[PBI-ID]/tasks.md`
- Dev docs for complex tasks: `dev/active/[task-name]/`
