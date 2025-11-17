# Setup Guide

Detailed installation instructions for the Gemini CLI Workflow Template.

## Prerequisites

Before you begin:

- [ ] Gemini CLI CLI installed (`claude --version` works)
- [ ] Node.js and npm installed (for TypeScript hook)
- [ ] Git installed (optional, for workflow features)
- [ ] Existing project OR ready to start new one

## Installation Options

Choose the setup that matches your needs:

### Option 1: Full Installation (Recommended)

Complete workflow with skills, hooks, and dev docs.

### Option 2: Hooks Only

Just quality automation without skills.

### Option 3: Skills Only

Auto-activation without global hooks.

---

## Full Installation

### Step 1: Copy Template Files

**For New Project**:
```bash
# Clone template
git clone https://github.com/yourusername/agentic-autoflow.git my-project
cd my-project

# Remove template git history
rm -rf .git
git init

# Clean up
rm -rf .gemini/hooks-global  # We'll install these globally
```

**For Existing Project**:
```bash
# Navigate to your project
cd your-existing-project

# Copy .gemini directory
cp -r /path/to/agentic-autoflow/.gemini .

# Optional: Copy docs structure
cp -r /path/to/agentic-autoflow/docs/delivery ./docs/
```

### Step 2: Install Global Hooks

```bash
# Create global hooks directory (if doesn't exist)
mkdir -p ~/.gemini/hooks

# Copy hooks from template
cp .gemini/hooks-global/user-prompt-submit.ts ~/.gemini/hooks/
cp .gemini/hooks-global/stop.ts ~/.gemini/hooks/

# Register hooks globally
gemini add UserPromptSubmit ~/.gemini/hooks/user-prompt-submit.ts --user
gemini add PostToolUse ~/.gemini/hooks/stop.ts --user --matcher "Edit|Write"

# Verify registration
gemini list
```

**Expected output**:
```
UserPromptSubmit: ~/.gemini/hooks/user-prompt-submit.ts (user-level)
PostToolUse: ~/.gemini/hooks/stop.ts (user-level, matcher: Edit|Write)
```

### Step 3: Make Hooks Executable

```bash
chmod +x ~/.gemini/hooks/user-prompt-submit.ts
chmod +x ~/.gemini/hooks/stop.ts
```

### Step 4: Verify Hook Dependencies

The hooks require Node.js and tsx. Test them:

```bash
# Test user-prompt-submit hook
echo '{"prompt":"test backend query"}' | ~/.gemini/hooks/user-prompt-submit.ts

# Test stop hook (will gracefully skip if not TypeScript project)
echo '{"tool_name":"Edit"}' | ~/.gemini/hooks/stop.ts
```

### Step 5: Create Your GEMINI.md

```bash
# Copy template to project root
cp .gemini/CLAUDE.template.md GEMINI.md

# Edit for your project
# Replace:
# - [Your Project Name]
# - [your dev command]
# - [skill descriptions]
# - [project structure]
```

**Customization checklist**:
- [ ] Update project name
- [ ] Update Quick Start commands
- [ ] List your skills (or remove example-skill)
- [ ] Update project structure diagram
- [ ] Add project-specific sections
- [ ] Remove unused sections
- [ ] Keep under 300 lines

### Step 6: Configure Skills for Your Stack

**Option A: Start with Example Skill**

The template includes `example-skill` as a reference. You can:
- Keep it and modify for your first real skill
- Delete it and create your own
- Copy skills from other projects

**Option B: Create Your First Skill**

```bash
# Create skill directory
mkdir -p .gemini/skills/my-tech-stack
mkdir -p .gemini/skills/my-tech-stack/resources

# Create SKILL.md (see SKILLS-GUIDE.md for details)
touch .gemini/skills/my-tech-stack/SKILL.md

# Create skill-config.json
touch .gemini/skills/my-tech-stack/skill-config.json
```

Example `skill-config.json`:
```json
{
  "name": "my-tech-stack",
  "type": "domain",
  "priority": "high",
  "description": "Best practices for [your technology]",
  "resourceFiles": []
}
```

### Step 7: Update skill-rules.json

Edit `.gemini/skills/skill-rules.json` to add triggers for your skills:

```json
{
  "my-tech-stack": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "description": "Best practices for [your technology]",
    "promptTriggers": {
      "keywords": [
        "keyword1",
        "keyword2",
        "your-framework"
      ],
      "intentPatterns": [
        "(create|implement).*?component",
        "(how to|best practice).*?testing"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "src/**/*.your-extension",
        "lib/**/*.ts"
      ],
      "contentPatterns": [
        "import.*your-framework",
        "YourClass\\("
      ]
    }
  }
}
```

### Step 8: Test Installation

**Test 1: Skill Activation**
```bash
# Start Gemini CLI
claude

# Type a message with your skill keyword
# Example: "How do I create a backend endpoint?"
```

Expected: See skill activation message before Claude responds.

**Test 2: TypeScript Hook (if applicable)**
```bash
# In Gemini CLI session
# Ask Claude to edit a TypeScript file
# Introduce a type error (e.g., assign string to number)
```

Expected: See TypeScript error message after Edit/Write.

**Test 3: Dev Docs Commands**
```bash
# In Gemini CLI session
# Type: /create-dev-docs
```

Expected: Prompt for task name, creates dev docs structure.

### Step 9: Initial Git Commit

```bash
git add .
git commit -m "Initial setup with Gemini CLI workflow template"
```

---

## Hooks Only Installation

If you only want quality automation:

```bash
# Create global hooks directory
mkdir -p ~/.gemini/hooks

# Copy hooks
cp /path/to/template/.gemini/hooks-global/* ~/.gemini/hooks/

# Register
gemini add UserPromptSubmit ~/.gemini/hooks/user-prompt-submit.ts --user
gemini add PostToolUse ~/.gemini/hooks/stop.ts --user --matcher "Edit|Write"

# Make executable
chmod +x ~/.gemini/hooks/*.ts

# Verify
gemini list
```

**You can skip**: Skills, dev docs, GEMINI.md template

---

## Skills Only Installation

If you want auto-activation without global hooks:

```bash
# Copy skills directory
cp -r /path/to/template/.gemini/skills .gemini/

# Copy commands directory
cp -r /path/to/template/.gemini/commands .gemini/

# Create GEMINI.md
cp /path/to/template/.gemini/CLAUDE.template.md GEMINI.md

# Edit GEMINI.md and skill-rules.json for your project
```

**You can skip**: Global hooks installation

**Note**: Without UserPromptSubmit hook, skills won't auto-activate. You'll need to reference them manually.

---

## Verification Checklist

After installation:

- [ ] `gemini list` shows registered hooks
- [ ] Skill activation triggers on relevant keywords
- [ ] TypeScript errors appear after edits (if TypeScript project)
- [ ] `/create-dev-docs` command works
- [ ] `/dev-docs-status` command works
- [ ] GEMINI.md reflects your project
- [ ] skill-rules.json has your skill triggers

---

## Troubleshooting

### Hooks Not Running

**Problem**: No skill activation messages or TypeScript checks

**Checks**:
```bash
# Are hooks registered?
gemini list

# Are hooks executable?
ls -la ~/.gemini/hooks/

# Can hooks run?
echo '{"prompt":"test"}' | ~/.gemini/hooks/user-prompt-submit.ts
```

**Fixes**:
```bash
# Make executable
chmod +x ~/.gemini/hooks/*.ts

# Re-register
gemini remove UserPromptSubmit
gemini add UserPromptSubmit ~/.gemini/hooks/user-prompt-submit.ts --user
```

### Skill Not Activating

**Problem**: Skill doesn't inject when expected

**Checks**:
- Is skill-rules.json in `.gemini/skills/`?
- Does your keyword match what's in `skill-rules.json`?
- Is UserPromptSubmit hook registered?

**Fixes**:
- Add more keywords/patterns to skill-rules.json
- Check for typos in skill names
- Restart Gemini CLI

### TypeScript Hook Errors

**Problem**: Hook fails or shows errors

**Checks**:
```bash
# Is TypeScript installed?
npx tsc --version

# Does tsc work?
npx tsc --noEmit
```

**Fixes**:
```bash
# Install TypeScript
npm install --save-dev typescript

# Or modify hook to use your language's checker
```

### Commands Not Found

**Problem**: `/create-dev-docs` not recognized

**Checks**:
- Are command files in `.gemini/commands/`?
- Do they have `.md` extension?
- Did you restart Gemini CLI?

**Fix**:
```bash
# Copy commands
cp /path/to/template/.gemini/commands/*.md .gemini/commands/

# Restart Gemini CLI
```

---

## Next Steps

After successful setup:

1. **Read CUSTOMIZATION.md** - Adapt template to your workflow
2. **Read SKILLS-GUIDE.md** - Create domain-specific skills
3. **Try a real task** - Use `/create-dev-docs` for multi-step work
4. **Iterate** - Update skills and triggers as you learn what works

---

## Uninstalling

To remove the workflow:

```bash
# Remove global hooks
gemini remove UserPromptSubmit
gemini remove PostToolUse
rm -rf ~/.gemini/hooks/

# Remove from project
rm -rf .gemini/
rm GEMINI.md

# Clean up dev docs (if desired)
rm -rf dev/active/
```

---

## Support

- Check [README.md](README.md) for overview
- See [CUSTOMIZATION.md](CUSTOMIZATION.md) for adaptation
- Review [SKILLS-GUIDE.md](SKILLS-GUIDE.md) for skill creation
- Open issue on GitHub for bugs
