#!/usr/bin/env python3
"""
PostToolUse Hook - TypeScript Error Checking

Claude Code Interface (per official docs):
- Input: JSON via stdin with { tool_name, tool_input, tool_response, ... }
- Output: JSON with { additionalContext: string } for feedback
- Exit code 0: Success
- Exit code 2: Block (with reason) - provides feedback to Claude

Runs after Edit|Write tools to check for TypeScript errors.
Faster than the TypeScript version (no npx tsx startup overhead).

@see https://code.claude.com/docs/en/hooks
"""
import json
import sys
import os
import subprocess


def check_typescript_errors(project_dir: str) -> str | None:
    """Run tsc --noEmit and return error summary if any."""
    try:
        result = subprocess.run(
            ["npx", "tsc", "--noEmit"],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            return None

        # Parse error lines
        output = result.stdout or result.stderr or ""
        error_lines = [
            line for line in output.split("\n")
            if "error TS" in line
        ]

        if not error_lines:
            return None

        # Format error message
        if len(error_lines) < 5:
            errors_display = "\n".join(error_lines)
            return f"""
⚠️  **TypeScript Errors Detected**:

```
{errors_display}
```

Please fix these errors before continuing.
"""
        else:
            first_errors = "\n".join(error_lines[:3])
            return f"""
⚠️  **{len(error_lines)} TypeScript Errors Detected**

Too many errors to display here. Consider:
1. Running `npm run build` to see full error list
2. Fixing errors systematically

First few errors:
```
{first_errors}
```
"""
    except subprocess.TimeoutExpired:
        return None
    except Exception:
        return None


def format_quality_message(error_message: str) -> str:
    """Format quality check message."""
    return f"""
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 QUALITY CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{error_message}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""


def get_project_dir() -> str:
    """Get project directory from env or fall back to cwd."""
    return os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())


def main():
    try:
        # Read JSON input from stdin
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", input_data.get("name", ""))

        # Only run after Edit or Write
        if tool_name not in ("Edit", "Write"):
            sys.exit(0)

        # Get project directory
        project_dir = get_project_dir()

        # Check if TypeScript project
        if not os.path.exists(os.path.join(project_dir, "package.json")):
            sys.exit(0)
        if not os.path.exists(os.path.join(project_dir, "node_modules", ".bin", "tsc")):
            sys.exit(0)

        # Check for errors (run from project directory)
        errors = check_typescript_errors(project_dir)

        if errors:
            output = json.dumps({"additionalContext": format_quality_message(errors)})
            print(output)

        sys.exit(0)

    except json.JSONDecodeError:
        # No stdin or invalid JSON - just exit silently
        sys.exit(0)
    except Exception as e:
        # Log to stderr but don't block
        print(f"TypeScript check hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
