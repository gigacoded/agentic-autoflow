#!/usr/bin/env -S npx tsx

/**
 * UserPromptSubmit Hook - Skill Auto-Activation
 *
 * Claude Code Interface:
 * - Input: JSON via stdin with { prompt: string }
 * - Output: Modified prompt via stdout
 * - Exit code 0: Success (stdout shown to Claude)
 * - Exit code 2: Block processing
 * - Other: Error (stderr shown to user)
 */

import * as fs from "fs";
import * as path from "path";

interface SkillRule {
  type: string;
  enforcement: string;
  priority: string;
  description: string;
  promptTriggers: {
    keywords: string[];
    intentPatterns: string[];
  };
  fileTriggers?: {
    pathPatterns: string[];
    contentPatterns: string[];
  };
}

interface SkillRules {
  [skillName: string]: SkillRule;
}

/**
 * Main hook execution
 */
async function main() {
  try {
    // Read JSON input from stdin
    const input = await readStdin();
    const data = JSON.parse(input);
    const originalPrompt = data.prompt || "";

    // Load skill rules
    const skillRulesPath = path.join(process.cwd(), ".claude/skills/skill-rules.json");

    if (!fs.existsSync(skillRulesPath)) {
      // No skill rules, output original prompt
      process.stdout.write(originalPrompt);
      process.exit(0);
    }

    const skillRulesContent = fs.readFileSync(skillRulesPath, "utf-8");
    const skillRules: SkillRules = JSON.parse(skillRulesContent);

    // Analyze prompt for skill triggers
    const activatedSkills: string[] = [];

    for (const [skillName, rule] of Object.entries(skillRules)) {
      if (shouldActivateSkill(originalPrompt, rule)) {
        activatedSkills.push(skillName);
      }
    }

    // If no skills matched, return original prompt
    if (activatedSkills.length === 0) {
      process.stdout.write(originalPrompt);
      process.exit(0);
    }

    // Build skill activation reminder
    const skillReminder = buildSkillActivationReminder(activatedSkills, skillRules);

    // Output modified prompt (reminder + original)
    const modifiedPrompt = `${skillReminder}\n\n---\n\n${originalPrompt}`;
    process.stdout.write(modifiedPrompt);
    process.exit(0);

  } catch (error) {
    // Log error to stderr and output original prompt
    console.error("Skill activation hook error:", error);
    process.exit(1);
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
 * Determine if a skill should activate based on prompt content
 */
function shouldActivateSkill(prompt: string, rule: SkillRule): boolean {
  const lowerPrompt = prompt.toLowerCase();

  // Check keyword triggers
  const hasKeyword = rule.promptTriggers.keywords.some((keyword) =>
    lowerPrompt.includes(keyword.toLowerCase())
  );

  if (hasKeyword) {
    return true;
  }

  // Check intent pattern triggers (regex)
  const hasIntent = rule.promptTriggers.intentPatterns.some((pattern) => {
    try {
      const regex = new RegExp(pattern, "i");
      return regex.test(lowerPrompt);
    } catch {
      return false;
    }
  });

  return hasIntent;
}

/**
 * Build formatted skill activation reminder message
 */
function buildSkillActivationReminder(
  skillNames: string[],
  skillRules: SkillRules
): string {
  const lines = [
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "🎯 SKILL ACTIVATION CHECK",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "",
  ];

  if (skillNames.length === 1) {
    const skillName = skillNames[0];
    const rule = skillRules[skillName];
    lines.push(`📋 Detected context: ${rule.description}`);
    lines.push("");
    lines.push(`💡 Recommended Skill: **${skillName}**`);
    lines.push("");
    lines.push(
      "Please reference this skill's guidelines for best practices and patterns."
    );
  } else {
    lines.push(`📋 Detected ${skillNames.length} relevant skill contexts:`);
    lines.push("");

    // Sort by priority (high > medium > low)
    const sorted = skillNames.sort((a, b) => {
      const priorityA = skillRules[a].priority;
      const priorityB = skillRules[b].priority;
      const priorityOrder = { high: 3, medium: 2, low: 1 };
      return (
        (priorityOrder[priorityB as keyof typeof priorityOrder] || 0) -
        (priorityOrder[priorityA as keyof typeof priorityOrder] || 0)
      );
    });

    sorted.forEach((skillName) => {
      const rule = skillRules[skillName];
      const priorityEmoji =
        rule.priority === "high"
          ? "🔴"
          : rule.priority === "medium"
          ? "🟡"
          : "🟢";
      lines.push(`${priorityEmoji} **${skillName}** - ${rule.description}`);
    });

    lines.push("");
    lines.push(
      "Please reference these skills' guidelines for best practices and patterns."
    );
  }

  lines.push("");
  lines.push("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

  return lines.join("\n");
}

// Run the hook
main();
