# Gemini CLI Adaptation Guide

This document explains the adaptations made to the original Claude Code workflow template for Google Gemini CLI.

## Key Differences

### Directory Structure

| Claude Code | Gemini CLI | Purpose |
|-------------|------------|---------|
| `.claude/` | `.gemini/` | Main infrastructure directory |
| `CLAUDE.md` | `GEMINI.md` | Project context file |
| `.claude/hooks-global/` | `.gemini/mcp-servers/` | Extension mechanism |
| Hooks (TypeScript) | MCP Servers (Node.js) | Quality automation |

### Extension Mechanism

**Claude Code**: Uses hooks that run at specific lifecycle points
- `UserPromptSubmit`: Runs before each prompt
- `PostToolUse`: Runs after Edit/Write operations

**Gemini CLI**: Uses Model Context Protocol (MCP) servers
- MCP servers are independent processes
- Communicate via standard protocol
- Configured in `~/.gemini/settings.json`

### Skill Activation

**Claude Code**:
- Hooks inject skill reminders into prompts automatically
- Runs synchronously before Claude sees the prompt

**Gemini CLI**:
- MCP server provides skill recommendation tools
- Gemini CLI can query for relevant skills
- More flexible but requires manual invocation

## What Was Adapted

### 1. Skills System ✅ Fully Compatible

The skills system (`skill-rules.json`, `SKILL.md` files) works identically in both versions:
- Same file structure
- Same content format
- Same trigger patterns (keywords, intents, file paths)

**Location**: `.gemini/skills/` (same as `.claude/skills/`)

### 2. Commands System ✅ Fully Compatible

Custom commands for dev docs workflow work the same:
- `/create-dev-docs`
- `/update-dev-docs`
- `/dev-docs-status`

**Location**: `.gemini/commands/` (same as `.claude/commands/`)

### 3. MCP Servers 🚧 Stubs Provided

The automation features require MCP server implementations:

**Skill Activation MCP**: `.gemini/mcp-servers/skill-activation/`
- Provides `list_skills`, `get_skill`, `recommend_skills` tools
- Gemini CLI can query for relevant skills based on context
- Reference implementation: Original `user-prompt-submit.ts` hook

**Quality Check MCP**: `.gemini/mcp-servers/quality-check/`
- Provides `check_typescript`, `check_eslint`, `run_quality_checks` tools
- Runs after code modifications
- Reference implementation: Original `stop.ts` hook

## Setup Instructions

### 1. Copy .gemini Directory

```bash
cp -r /path/to/agentic-autoflow/.gemini your-project/
```

### 2. Create GEMINI.md

```bash
cp your-project/.gemini/GEMINI.template.md your-project/GEMINI.md
# Edit GEMINI.md for your project
```

### 3. Configure MCP Servers (Optional)

Create `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "skill-activation": {
      "command": "node",
      "args": ["/absolute/path/to/project/.gemini/mcp-servers/skill-activation/server.js"],
      "env": {
        "PROJECT_ROOT": "/absolute/path/to/project"
      }
    },
    "quality-check": {
      "command": "node",
      "args": ["/absolute/path/to/project/.gemini/mcp-servers/quality-check/server.js"]
    }
  }
}
```

### 4. Use with Gemini CLI

```bash
cd your-project
gemini
```

Reference skills manually or use MCP tools to get recommendations.

## Implementing MCP Servers

The MCP servers are provided as stubs with detailed specifications. To implement:

### Skill Activation MCP

1. Install MCP SDK: `npm install @modelcontextprotocol/sdk`
2. Adapt logic from `.gemini/mcp-servers/user-prompt-submit.ts`
3. Implement MCP server in `server.js`
4. Test with: `gemini /tools` (should list skill activation tools)

### Quality Check MCP

1. Install MCP SDK
2. Adapt logic from `.gemini/mcp-servers/stop.ts`
3. Implement language-specific checkers
4. Configure auto-run behavior

See individual MCP server README files for detailed specifications.

## Migration from Claude Code

If you're already using the Claude Code version:

1. **Keep both**: Use `.claude/` and `.gemini/` in the same project
2. **Same skills**: Skills work in both (symlink or copy)
3. **Gradual migration**: Test Gemini CLI without removing Claude setup

```bash
# In your project with .claude/ already:
cp -r .claude .gemini
mv .gemini/hooks-global .gemini/mcp-servers
# Implement MCP servers as needed
```

## What Works Out of the Box

✅ **Skills**: All skill content and patterns
✅ **Commands**: Dev docs workflow commands
✅ **Documentation**: GEMINI.md template
✅ **File structure**: Project organization

🚧 **Requires Implementation**:
- MCP servers for automatic skill activation
- MCP servers for quality checking
- Custom MCP integrations (optional)

## Comparison Table

| Feature | Claude Code | Gemini CLI | Status |
|---------|-------------|------------|--------|
| Skills system | ✅ Auto-inject | ✅ On-demand | Working |
| Quality checks | ✅ Automatic | 🚧 MCP needed | Stub |
| Dev docs | ✅ Commands | ✅ Commands | Working |
| Task workflow | ✅ Full | ✅ Full | Working |
| Setup complexity | Medium | Medium-High | - |
| Automation level | High | Medium (without MCP) | - |

## Community Contributions

**Want to help?** Implement the MCP servers!

1. Fork this branch
2. Implement `skill-activation/server.js`
3. Implement `quality-check/server.js`
4. Test with real projects
5. Submit PR

See MCP server README files for specifications.

## References

- [Gemini CLI Documentation](https://developers.google.com/gemini-code-assist/docs/gemini-cli)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Original Claude Code Template](https://github.com/gigacoded/agentic-autoflow/tree/main)

## Questions?

- **For Gemini CLI usage**: [Gemini CLI Issues](https://github.com/google-gemini/gemini-cli/issues)
- **For template questions**: [Template Issues](https://github.com/gigacoded/agentic-autoflow/issues)
- **For MCP implementation help**: [MCP Discord](https://discord.gg/mcp)
