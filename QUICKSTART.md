# Quick Start - Get Running in 5 Minutes

The fastest path to using the Gemini CLI Workflow Template.

## TL;DR

```bash
# 1. Copy to your project
cp -r /path/to/agentic-autoflow/.gemini your-project/

# 2. Install global hooks
mkdir -p ~/.gemini/hooks
cp your-project/.gemini/hooks-global/* ~/.gemini/hooks/
gemini add UserPromptSubmit ~/.gemini/hooks/user-prompt-submit.ts --user
gemini add PostToolUse ~/.gemini/hooks/stop.ts --user --matcher "Edit|Write"

# 3. Create GEMINI.md
cp your-project/.gemini/CLAUDE.template.md your-project/GEMINI.md
# Edit GEMINI.md for your project

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
mkdir -p .gemini/skills/your-tech-stack

# Copy example skill as template
cp -r .gemini/skills/example-skill/SKILL.md .gemini/skills/your-tech-stack/

# Edit SKILL.md
# - Replace [Skill Name] with your technology
# - Add your patterns and best practices
# - Include code examples from your project
```

### 2. Add Triggers

Edit `.gemini/skills/skill-rules.json`:

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

### 4. Customize GEMINI.md

Edit your GEMINI.md:

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

- [ ] `gemini list` shows 2 hooks
- [ ] Typing "test" shows skill activation message
- [ ] `/create-dev-docs` command works
- [ ] GEMINI.md reflects your project
- [ ] At least 1 real skill created

## Troubleshooting

**Hooks not running?**
```bash
chmod +x ~/.gemini/hooks/*.ts
gemini list
```

**Skills not activating?**
```bash
cat .gemini/skills/skill-rules.json | jq .
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
