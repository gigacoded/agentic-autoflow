# Quick Start - Get Running in 5 Minutes

The fastest path to using the Claude Code Workflow Template.

## TL;DR

```bash
# 1. Copy to your project
cp -r /path/to/agentic-autoflow/.claude your-project/

# 2. Install global hooks
mkdir -p ~/.claude/hooks
cp your-project/.claude/hooks-global/* ~/.claude/hooks/
claude hooks add UserPromptSubmit ~/.claude/hooks/user-prompt-submit.ts --user
claude hooks add PostToolUse ~/.claude/hooks/stop.ts --user --matcher "Edit|Write"

# 3. Create CLAUDE.md
cp your-project/.claude/CLAUDE.template.md your-project/CLAUDE.md
# Edit CLAUDE.md for your project

# 4. Test
cd your-project && claude
# Type: "test" - should see example-skill activation
```

## What You Get

After 5 minutes:

✅ **Auto-activating skills** - Skills inject based on context
✅ **TypeScript error checking** - Catches errors after edits
✅ **Dev docs workflow** - `/create-dev-docs` for long tasks
✅ **Example skill** - Template for creating your own

## Next Steps (15-30 minutes)

### 1. Create Your First Real Skill

```bash
# Create directory
mkdir -p .claude/skills/your-tech-stack

# Copy example skill as template
cp -r .claude/skills/example-skill/SKILL.md .claude/skills/your-tech-stack/

# Edit SKILL.md
# - Replace [Skill Name] with your technology
# - Add your patterns and best practices
# - Include code examples from your project
```

### 2. Add Triggers

Edit `.claude/skills/skill-rules.json`:

```json
{
  "your-tech-stack": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "description": "Best practices for [your technology]",
    "promptTriggers": {
      "keywords": ["keyword1", "keyword2", "your-framework"],
      "intentPatterns": ["(create|implement).*?pattern"]
    },
    "fileTriggers": {
      "pathPatterns": ["src/**/*.ext"],
      "contentPatterns": ["import.*your-framework"]
    }
  }
}
```

### 3. Test Your Skill

```bash
# Start Claude
claude

# Use one of your keywords
# Example: "How do I create a [keyword1]?"

# Should see: "🎯 SKILL ACTIVATION CHECK"
# With your skill name
```

### 4. Customize CLAUDE.md

Edit your CLAUDE.md:

- Update project name
- Add your quick start commands
- List your skills
- Add project-specific rules
- Keep under 300 lines

## Common First Skills

### Backend API (Express, FastAPI, etc.)

**Keywords**: `api`, `endpoint`, `route`, `backend`

**Content**:
- Route definition patterns
- Request validation
- Error handling
- Database operations
- Testing API endpoints

### Frontend Components (React, Vue, etc.)

**Keywords**: `component`, `react`, `frontend`, `ui`

**Content**:
- Component structure
- State management
- Props and typing
- Styling approach
- Testing components

### Testing

**Keywords**: `test`, `testing`, `unit test`, `e2e`

**Content**:
- Test structure
- Mocking patterns
- Setup and teardown
- Assertion strategies
- Running tests

## Verification Checklist

After setup:

- [ ] `claude hooks list` shows 2 hooks
- [ ] Typing "test" shows skill activation message
- [ ] `/create-dev-docs` command works
- [ ] CLAUDE.md reflects your project
- [ ] At least 1 real skill created

## Troubleshooting

**Hooks not running?**
```bash
chmod +x ~/.claude/hooks/*.ts
claude hooks list
```

**Skills not activating?**
```bash
cat .claude/skills/skill-rules.json | jq .
# Check for JSON errors
```

**TypeScript hook errors?**
```bash
# Install TypeScript if needed
npm install --save-dev typescript
```

## Full Documentation

This is the express path. For complete documentation:

- **Overview**: [README.md](README.md)
- **Detailed setup**: [SETUP.md](SETUP.md)
- **Creating skills**: [SKILLS-GUIDE.md](SKILLS-GUIDE.md)
- **Customization**: [CUSTOMIZATION.md](CUSTOMIZATION.md)

## Help

- Issues: Open a GitHub issue
- Questions: Check the documentation guides
- Examples: See the example-skill directory

---

**Happy coding with Claude!** 🚀
