#!/usr/bin/env -S npx tsx

/**
 * PostToolUse Hook - Quality Checks After Tool Use
 *
 * Claude Code Interface:
 * - Input: JSON via stdin with tool usage details
 * - Output: Message via stdout (shown to Claude after tool result)
 * - Exit code 0: Success
 *
 * This implements the "#NoMessLeftBehind" philosophy
 */

import * as fs from "fs";
import * as path from "path";
import { execSync } from "child_process";

/**
 * Main hook execution
 */
async function main() {
  try {
    // Read JSON input from stdin
    const input = await readStdin();
    const data = JSON.parse(input);

    // Extract tool information
    const toolName = data.tool_name || data.name || "";
    const toolInput = data.tool_input || {};

    // Only run quality checks after Edit or Write tools
    if (toolName !== "Edit" && toolName !== "Write") {
      process.exit(0);
    }

    // Check if we're in a TypeScript project
    const cwd = process.cwd();
    const hasPackageJson = fs.existsSync(path.join(cwd, "package.json"));
    const hasTsc = fs.existsSync(path.join(cwd, "node_modules", ".bin", "tsc"));

    if (!hasPackageJson || !hasTsc) {
      process.exit(0); // Not a TypeScript project
    }

    // Check for TypeScript errors
    const tsErrors = checkTypeScriptErrors();

    if (tsErrors) {
      const message = formatQualityCheckMessage(tsErrors);
      process.stdout.write(message);
    }

    process.exit(0);

  } catch (error) {
    // Fail silently - don't break the workflow
    console.error("Stop hook error:", error);
    process.exit(0);
  }
}

/**
 * Read all data from stdin
 */
function readStdin(): Promise<string> {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => {
      data += chunk;
    });
    process.stdin.on("end", () => {
      resolve(data);
    });
  });
}

/**
 * Check for TypeScript compilation errors
 */
function checkTypeScriptErrors(): string | null {
  try {
    // Run tsc --noEmit to check for errors (don't generate files)
    execSync("npx tsc --noEmit", {
      cwd: process.cwd(),
      stdio: "pipe",
      encoding: "utf-8",
      timeout: 10000, // 10 second timeout
    });

    // No errors!
    return null;

  } catch (error: any) {
    // TSC found errors or timed out
    if (error.killed) {
      return null; // Timeout - skip check
    }

    const output = error.stdout || error.stderr || "";

    // Count errors
    const errorLines = output.split("\n").filter((line: string) =>
      line.includes("error TS")
    );

    if (errorLines.length === 0) {
      return null; // No errors
    }

    // Format error summary
    if (errorLines.length < 5) {
      // Show all errors if < 5
      return `
⚠️  **TypeScript Errors Detected**:

\`\`\`
${errorLines.join("\n")}
\`\`\`

Please fix these errors before continuing.
`;
    } else {
      // Too many errors - recommend systematic fixing
      return `
⚠️  **${errorLines.length} TypeScript Errors Detected**

Too many errors to display here. Consider:
1. Running \`npm run build\` to see full error list
2. Fixing errors systematically

First few errors:
\`\`\`
${errorLines.slice(0, 3).join("\n")}
\`\`\`
`;
    }
  }
}

/**
 * Format quality check message
 */
function formatQualityCheckMessage(errorMessage: string): string {
  const lines = [
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "📋 QUALITY CHECK",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "",
    errorMessage,
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "",
  ];

  return lines.join("\n");
}

// Run the hook
main();
