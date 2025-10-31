# Claude Code Infrastructure

This directory contains the Claude Code workflow infrastructure for this project.

## Directory Structure

```
.claude/
├── skills/              # Auto-activating skills
│   ├── skill-rules.json # Activation triggers for all skills
│   └── [skill-name]/    # Individual skill directories
│       ├── SKILL.md     # Skill content
│       ├── skill-config.json  # Skill metadata
│       └── resources/   # Additional reference files
├── hooks-global/        # Global hooks (copy to ~/.claude/hooks/)
│   ├── user-prompt-submit.ts  # Skill activation hook
│   └── stop.ts          # Quality checking hook
├── commands/            # Slash commands
│   ├── create-dev-docs.md
│   ├── update-dev-docs.md
│   └── dev-docs-status.md
└── README.md           # This file
```

## What's Here

### Skills (`skills/`)

Context-aware best practices that auto-activate based on:
- Keywords in your prompts
- File paths you're working on
- Code patterns Claude detects

**skill-rules.json** defines when each skill activates.

### Global Hooks (`hooks-global/`)

Quality automation that runs automatically:

- **user-prompt-submit.ts**: Analyzes your prompts and activates relevant skills
- **stop.ts**: Checks for errors after Edit/Write operations

These should be copied to `~/.claude/hooks/` and registered globally.

### Commands (`commands/`)

Slash commands for common workflows:

- `/create-dev-docs` - Initialize dev docs for long tasks
- `/update-dev-docs` - Update progress and context
- `/dev-docs-status` - Show current status

## Quick Links

- **Main docs**: See [../README.md](../README.md)
- **Setup guide**: [../SETUP.md](../SETUP.md)
- **Skills guide**: [../SKILLS-GUIDE.md](../SKILLS-GUIDE.md)
- **CLAUDE.md template**: [CLAUDE.template.md](CLAUDE.template.md)

## For New Team Members

1. Install global hooks (see [../SETUP.md](../SETUP.md))
2. Read the project's CLAUDE.md (in repo root)
3. Browse skills relevant to what you're working on
4. Use `/create-dev-docs` for multi-step tasks

## Creating New Skills

See [../SKILLS-GUIDE.md](../SKILLS-GUIDE.md) for detailed instructions.

Quick steps:
1. Create directory in `skills/[skill-name]/`
2. Write `SKILL.md` with your patterns
3. Add entry to `skill-rules.json`
4. Test activation

## Modifying Hooks

Global hooks live in `~/.claude/hooks/` after installation.

To modify:
1. Edit the hook file in `~/.claude/hooks/`
2. Test with: `echo '{"tool_name":"Edit"}' | ~/.claude/hooks/stop.ts`
3. Changes take effect immediately (no re-registration needed)

## Version

This infrastructure is based on the Claude Code Workflow Template.

- **Template version**: 1.0
- **Customized for**: [Your Project Name]
- **Last updated**: [Date]
