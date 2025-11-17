# Agent Configuration Directory

This directory contains the skill-based architecture for Gemini CLI, inspired by [universal-agents](https://github.com/leochiu-a/universal-agents).

## Structure

```
.agents/
├── skills/          # On-demand skill loading
├── rules/           # Always-active code conventions
├── commands/        # TOML custom commands
└── README.md        # This file
```

## How It Works

1. **AGENTS.md** (project root) defines the execution protocol
2. **Skills** load on-demand when relevant to the current task
3. **Rules** are always active for every response
4. **Commands** provide shortcuts for common workflows

## Files

### Skills (`.agents/skills/`)

Load these on-demand based on what you're working on:

- `convex-backend.md` - Convex backend development patterns
- `nextjs-frontend.md` - Next.js + React + Tailwind + shadcn/ui patterns
- `e2e-testing.md` - E2E testing with Chrome DevTools MCP
- `task-management.md` - PBI workflow and dev docs system

**How to use**: Gemini determines relevance and loads with `@.agents/skills/{name}.md`

### Rules (`.agents/rules/`)

These apply to EVERY response - always loaded:

- `api-patterns.md` - API design conventions
- `component-structure.md` - Component organization rules
- `commit-format.md` - Git commit message format
- `error-handling.md` - Error handling patterns

**How to use**: Gemini automatically loads all files from this directory

### Commands (`.agents/commands/`)

TOML files providing custom slash commands:

- `/skill {name}` - Explicitly load a specific skill
- `/check` - Run TypeScript and linting checks
- `/dev-docs` - Create/update dev documentation
- `/context` - Show currently loaded context

**How to use**: Type `/command-name` in Gemini CLI

## Gemini CLI Integration

This works with Gemini CLI's native features:

**Hierarchical GEMINI.md** (auto-loaded):
```
.gemini/GEMINI.md          # Always loaded
.gemini/convex/GEMINI.md   # Loads when in convex/
.gemini/app/GEMINI.md      # Loads when in app/
```

**Custom Commands** (`.agents/commands/*.toml`):
- Symlink or copy to `~/.gemini/commands/` for global access
- Or keep in `.gemini/commands/` for project-specific

## Usage Flow

**Example: Creating a Convex Query**

1. You type: "Create a query to fetch users"
2. Gemini loads:
   - `.gemini/GEMINI.md` (project root)
   - `.gemini/convex/GEMINI.md` (auto - you're in convex/)
   - `AGENTS.md` (reads protocol)
3. Gemini determines: "convex" trigger → load convex-backend skill
4. Gemini loads:
   - `@.agents/skills/convex-backend.md`
   - All files from `.agents/rules/`
5. Gemini responds with:
   ```
   **Skills**: convex-backend | **Rules**: api-patterns, error-handling

   Here's your Convex query following project patterns...
   ```

## Why This Approach?

**Gemini CLI doesn't have hooks** like Claude Code, so we can't auto-inject skills based on triggers. Instead:

1. **AGENTS.md teaches** Gemini to recognize when skills are relevant
2. **Hierarchical GEMINI.md** provides context-specific reminders
3. **Explicit loading** using `@` syntax works WITH Gemini CLI
4. **TOML commands** integrate properly with Gemini CLI

This mimics Claude Code's auto-activating skills while respecting Gemini CLI's architecture.

## Adding New Skills

1. Create `.agents/skills/my-skill.md` with your patterns
2. Add skill to `AGENTS.md` with triggers and description
3. (Optional) Create `.gemini/{directory}/GEMINI.md` to remind loading

## Adding New Rules

1. Create `.agents/rules/my-rule.md` with conventions
2. Document in this README
3. Rules auto-load - no configuration needed

## Adding New Commands

1. Create `.agents/commands/my-command.toml`:
   ```toml
   description = "What this command does"
   prompt = """
   Your prompt template here
   Use {{args}} for user input
   Use !{command} for shell execution
   Use @{file.md} for file content
   """
   ```
2. Test with `/my-command` in Gemini CLI

## References

- [AGENTS.md Protocol](../AGENTS.md)
- [Universal Agents](https://github.com/leochiu-a/universal-agents)
- [Gemini CLI Custom Commands](https://geminicli.com/docs/cli/custom-commands/)
- [Gemini CLI GEMINI.md Files](https://geminicli.com/docs/cli/gemini-md/)
