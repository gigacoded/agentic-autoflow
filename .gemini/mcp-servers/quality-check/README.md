# Quality Check MCP Server

This MCP server provides automated quality checking for code operations in Gemini CLI.

## Overview

The Quality Check MCP runs TypeScript (or other language) checks after code modifications to catch errors early. It implements a fail-fast philosophy to prevent cascading errors.

## How It Works

1. **Monitors Code Changes**: Triggered after file modifications
2. **Runs Type Checks**: Executes `tsc --noEmit` or equivalent
3. **Reports Errors**: Provides clear error messages via MCP protocol
4. **Blocks on Failure**: Can prevent further operations until fixed (optional)

## MCP Tools Provided

### `check_typescript`
Runs TypeScript type checking on the project.

**Parameters**:
- `files` (array, optional): Specific files to check

**Returns**: TypeScript errors or success confirmation

### `check_eslint`
Runs ESLint on modified files.

**Parameters**:
- `files` (array): Files to lint

**Returns**: Linting errors or success

### `run_quality_checks`
Runs all configured quality checks.

**Parameters**:
- `checks` (array, optional): Specific checks to run (default: all)

**Returns**: Combined results from all checks

## Configuration

Add to `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "quality-check": {
      "command": "node",
      "args": ["/absolute/path/to/project/.gemini/mcp-servers/quality-check/server.js"],
      "env": {
        "PROJECT_ROOT": "/absolute/path/to/project"
      }
    }
  }
}
```

## Supported Languages

- **TypeScript**: `tsc --noEmit`
- **Python**: `mypy` or `pyright`
- **Rust**: `cargo check`
- **Go**: `go vet`

Configure in `.gemini/mcp-servers/quality-check/config.json`

## Implementation Status

**Status**: 🚧 Stub - Implementation needed

This is a stub that describes the intended functionality. To implement:

1. Create `server.js` using the MCP SDK
2. Implement language-specific checkers
3. Add error parsing and formatting
4. Test with Gemini CLI

## Usage Example

Once configured, after code modifications:

```
Gemini: [Edits TypeScript file]
MCP: Runs tsc --noEmit
MCP: Reports "Error: Type 'string' is not assignable to type 'number' at line 42"
Gemini: Fixes the error automatically
```

## Customization

Create `.gemini/mcp-servers/quality-check/config.json`:

```json
{
  "typescript": {
    "enabled": true,
    "command": "tsc --noEmit"
  },
  "eslint": {
    "enabled": true,
    "command": "eslint --format json"
  },
  "autofix": false,
  "blockOnError": true
}
```

## References

- [MCP SDK Documentation](https://modelcontextprotocol.io/)
- [Gemini CLI MCP Integration](https://developers.google.com/gemini-code-assist/docs/gemini-cli)
- Original stop.ts hook implementation from Claude Code
