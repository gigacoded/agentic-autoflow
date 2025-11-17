# Optimal Gemini CLI Implementation Design

## Problem Statement

How to mirror Claude Code's auto-activating skills workflow in Gemini CLI, which:
- Has NO hooks system
- Uses hierarchical GEMINI.md files (all auto-loaded)
- Supports custom commands (TOML files)
- Can't conditionally inject context based on triggers

## Solution: Hybrid Architecture

Combine **Universal Agents** approach with **Gemini CLI native features**.

### Architecture Components

```
project/
├── AGENTS.md                    # Control manifest (Gemini reads this)
├── .agents/
│   ├── skills/                  # Skill definitions
│   │   ├── convex-backend.md
│   │   ├── nextjs-frontend.md
│   │   └── e2e-testing.md
│   ├── rules/                   # Code conventions
│   │   ├── api-patterns.md
│   │   ├── component-rules.md
│   │   └── commit-format.md
│   └── commands/                # TOML custom commands
│       ├── activate-skill.toml
│       ├── dev-docs.toml
│       └── check-quality.toml
└── .gemini/
    ├── GEMINI.md               # Links to AGENTS.md
    ├── app/GEMINI.md           # Auto-loads in frontend
    ├── convex/GEMINI.md        # Auto-loads in backend
    └── commands/               # Symlink to .agents/commands/
```

## How It Works

### 1. AGENTS.md - Control Manifest

```markdown
# Scaffold Development Agent Configuration

**IMPORTANT**: This project uses a skill-based architecture. Before responding to any request:

1. Read this entire file to understand available skills and rules
2. Determine which skills are relevant to the current task
3. Load ONLY the relevant skills from `.agents/skills/`
4. Apply all rules from `.agents/rules/`
5. Declare which skills/rules you're using in your response

## Available Skills

Load these on-demand from `.agents/skills/`:

- **convex-backend** - Triggers: "convex", "backend", "query", "mutation", working in `convex/`
- **nextjs-frontend** - Triggers: "frontend", "component", "page", working in `app/`, `components/`
- **e2e-testing** - Triggers: "e2e", "test", "chrome", working in `test/`

## Rules (Always Active)

Load all files from `.agents/rules/` - these apply to ALL work:
- API patterns and conventions
- Component structure rules
- Commit message format

## Workflow

1. User asks a question
2. You determine relevant skills based on triggers
3. You load: `@.agents/skills/{relevant-skill}.md`
4. You apply: All rules from `.agents/rules/`
5. You respond, prefixing: "**Skills**: convex-backend | **Rules**: api-patterns, component-rules"
```

### 2. Hierarchical GEMINI.md (Auto-Context)

**.gemini/GEMINI.md** (Project root - always loaded):
```markdown
# Quick Reference

Development: `npm run dev`
Tech Stack: Next.js 14 + Convex + React + Tailwind

**For detailed patterns**: Read AGENTS.md and load skills on-demand from `.agents/skills/`
```

**.gemini/convex/GEMINI.md** (Auto-loads when in convex/):
```markdown
# Backend Context

You are working in the Convex backend.

**Load**: `@.agents/skills/convex-backend.md` for detailed patterns.
**Apply**: All rules from `.agents/rules/`
```

**.gemini/app/GEMINI.md** (Auto-loads when in app/):
```markdown
# Frontend Context

You are working in the Next.js frontend.

**Load**: `@.agents/skills/nextjs-frontend.md` for detailed patterns.
**Apply**: All rules from `.agents/rules/`
```

### 3. Custom Commands (TOML)

**.agents/commands/skill.toml**:
```toml
description = "Load a specific skill"
prompt = """
Load and activate the skill from: @.agents/skills/{{args}}.md

Apply this skill's patterns to the current task.
"""
```

**.agents/commands/dev-docs.toml**:
```toml
description = "Create dev docs for current task"
prompt = """
Create a dev doc in dev/active/ with:
- Task breakdown
- Current status
- Blockers

Current context: !{git status}
Project structure: !{ls -la}
"""
```

## Key Differences from Claude Code

| Feature | Claude Code | Gemini CLI Solution |
|---------|-------------|---------------------|
| Auto-activation | Hooks inject skills | AGENTS.md instructs to load |
| Skill loading | Automatic via triggers | Manual via `@` or `/skill` command |
| Context | Hook-injected | Hierarchical GEMINI.md |
| Commands | Markdown files | TOML files |
| Quality checks | Post-hook automation | Custom command to run checks |

## Usage Examples

### Example 1: Working in Convex Backend

**User**: "Create a new query for fetching users"

**Gemini loads**:
1. `.gemini/GEMINI.md` (project root)
2. `.gemini/convex/GEMINI.md` (auto-loaded)
3. `AGENTS.md` (sees it should load convex-backend skill)
4. `@.agents/skills/convex-backend.md` (loads the skill)
5. All files from `.agents/rules/`

**Gemini responds**:
> **Skills**: convex-backend | **Rules**: api-patterns
>
> Here's the query following Convex patterns...

### Example 2: Using Custom Command

**User**: `/skill convex-backend`

**Command executes**:
```
Load and activate: @.agents/skills/convex-backend.md
```

### Example 3: Quality Check

**User**: `/check`

**Command executes** (from check.toml):
```toml
prompt = """
Run quality checks:
1. TypeScript: !{npx tsc --noEmit}
2. Linting: !{npm run lint}
3. Report any errors
"""
```

## Advantages

✅ **Works with Gemini CLI's native features**
✅ **Mimics Claude Code's workflow** (skills, rules, commands)
✅ **Explicit skill loading** (Gemini CLI's philosophy)
✅ **Hierarchical context** (leverages GEMINI.md auto-loading)
✅ **No hacks or workarounds** needed
✅ **Shareable and version-controlled**

## Implementation Steps

1. Create `AGENTS.md` control manifest
2. Move skills to `.agents/skills/` as markdown files
3. Extract rules to `.agents/rules/`
4. Convert commands to TOML in `.agents/commands/`
5. Create minimal hierarchical GEMINI.md files
6. Test with scaffold codebase

## Why This Works Better Than Direct Port

- Gemini CLI can't conditionally inject context (no hooks)
- Universal Agents approach teaches Gemini TO load skills on-demand
- AGENTS.md + hierarchical GEMINI.md = explicit + automatic context
- TOML commands = proper Gemini CLI integration
- Respects Gemini CLI's "explicit is better than implicit" philosophy

This design gets us **90% of Claude Code's workflow** while working WITH Gemini CLI's architecture, not against it.
