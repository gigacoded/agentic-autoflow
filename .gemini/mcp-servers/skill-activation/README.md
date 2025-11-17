# Skill Activation MCP Server

This MCP server provides skill recommendation capabilities for Gemini CLI based on prompt analysis.

## Overview

The Skill Activation MCP analyzes user prompts and recommends relevant skills from `.gemini/skills/skill-rules.json`. It helps Gemini CLI understand which project-specific patterns and best practices to apply.

## How It Works

1. **Reads skill-rules.json**: Loads all defined skills and their triggers
2. **Analyzes Prompts**: Checks for keyword matches and intent patterns
3. **Recommends Skills**: Provides ranked skill recommendations via MCP protocol
4. **Context-Aware**: Considers file paths and code patterns when available

## MCP Tools Provided

### `list_skills`
Lists all available skills in the project.

**Returns**: Array of skill names with descriptions

### `get_skill`
Gets the full content of a specific skill.

**Parameters**:
- `skillName` (string): Name of the skill to retrieve

**Returns**: Skill content from SKILL.md file

### `recommend_skills`
Analyzes a prompt and recommends relevant skills.

**Parameters**:
- `prompt` (string): User's prompt to analyze
- `filePaths` (array, optional): Files being worked on

**Returns**: Ranked list of recommended skills

## Configuration

Add to `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "skill-activation": {
      "command": "node",
      "args": ["/absolute/path/to/project/.gemini/mcp-servers/skill-activation/server.js"],
      "env": {
        "PROJECT_ROOT": "/absolute/path/to/project"
      }
    }
  }
}
```

## Implementation Status

**Status**: 🚧 Stub - Implementation needed

This is a stub that describes the intended functionality. To implement:

1. Create `server.js` using the MCP SDK
2. Implement the skill analysis logic (can adapt from Claude Code hooks)
3. Test with Gemini CLI

## Usage Example

Once configured, Gemini CLI can use this MCP to automatically:
- Suggest relevant skills when starting a task
- Load skill guidelines into context
- Maintain consistency with project patterns

```
User: "Create a new Convex query for posts"
MCP: Recommends "convex-backend-dev" skill
Gemini: References skill guidelines while implementing
```

## References

- [MCP SDK Documentation](https://modelcontextprotocol.io/)
- [Gemini CLI MCP Integration](https://developers.google.com/gemini-code-assist/docs/gemini-cli)
- Original skill-rules.json implementation from Claude Code
