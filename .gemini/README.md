# Gemini CLI Infrastructure

This directory contains the Gemini CLI workflow infrastructure for this project.

## Directory Structure

```
.gemini/
├── skills/              # Auto-activating skills
│   ├── skill-rules.json # Activation triggers for all skills
│   └── [skill-name]/    # Individual skill directories
│       ├── SKILL.md     # Skill content
│       ├── skill-config.json  # Skill metadata
│       └── resources/   # Additional reference files
├── mcp-servers/         # Custom MCP servers
│   ├── skill-activation/  # Skill activation MCP server
│   └── quality-check/     # Quality checking MCP server
├── commands/            # Custom commands
│   ├── create-dev-docs.md
│   ├── update-dev-docs.md
│   └── dev-docs-status.md
└── README.md           # This file
```

## What's Here

### Skills (`skills/`)

Context-aware best practices that can be referenced based on:
- Keywords in your prompts
- File paths you're working on
- Code patterns Gemini detects

**skill-rules.json** defines patterns for skill activation.

### MCP Servers (`mcp-servers/`)

Custom Model Context Protocol servers that extend Gemini CLI:

- **skill-activation/**: Analyzes your prompts and recommends relevant skills
- **quality-check/**: Checks for errors after code operations

Configure these in `~/.gemini/settings.json` to enable automatic activation.

### Commands (`commands/`)

Custom reusable commands for common workflows:

- `create-dev-docs` - Initialize dev docs for long tasks
- `update-dev-docs` - Update progress and context
- `dev-docs-status` - Show current status

## Quick Links

- **Main docs**: See [../README.md](../README.md)
- **Setup guide**: [../SETUP.md](../SETUP.md)
- **Skills guide**: [../SKILLS-GUIDE.md](../SKILLS-GUIDE.md)
- **GEMINI.md template**: [GEMINI.template.md](GEMINI.template.md)

## For New Team Members

1. Install MCP servers (see [../SETUP.md](../SETUP.md))
2. Read the project's GEMINI.md (in repo root)
3. Browse skills relevant to what you're working on
4. Use custom commands for multi-step tasks

## Creating New Skills

See [../SKILLS-GUIDE.md](../SKILLS-GUIDE.md) for detailed instructions.

Quick steps:
1. Create directory in `skills/[skill-name]/`
2. Write `SKILL.md` with your patterns
3. Add entry to `skill-rules.json`
4. Test by asking Gemini CLI questions in that domain

## Configuring MCP Servers

MCP servers are configured in `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "skill-activation": {
      "command": "node",
      "args": ["/path/to/project/.gemini/mcp-servers/skill-activation/server.js"],
      "env": {
        "PROJECT_ROOT": "/path/to/project"
      }
    },
    "quality-check": {
      "command": "node",
      "args": ["/path/to/project/.gemini/mcp-servers/quality-check/server.js"]
    }
  }
}
```

## Version

This infrastructure is based on the Agentic AutoFlow template for Gemini CLI.

- **Template version**: 1.0 (Gemini Edition)
- **Customized for**: [Your Project Name]
- **Last updated**: [Date]
