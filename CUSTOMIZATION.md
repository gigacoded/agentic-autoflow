# Customization Guide

How to adapt the Claude Code Workflow Template for your specific project and team.

## Overview

This template is designed to be forked and customized. This guide shows you how to adapt it for:

- Different tech stacks
- Team workflows
- Project requirements
- Personal preferences

## Quick Customization Path

1. **Install template** (see SETUP.md)
2. **Adapt CLAUDE.md** (10 minutes)
3. **Create 1-3 skills** for your stack (30-60 minutes)
4. **Customize hooks** if needed (15 minutes)
5. **Test and iterate** (ongoing)

---

## Adapting CLAUDE.md

### Step 1: Update Project Basics

Edit `CLAUDE.md` and replace placeholders:

```markdown
# [Your Project Name] Development Infrastructure
          ↓
# AcmeCorp API Development Infrastructure
```

```markdown
**Development**:
- `[your dev command]` - Start development server
          ↓
- `npm run dev` - Start development server (port 3000)
- `npm run dev:watch` - Start with hot reload
```

### Step 2: Document Your Skills

List skills you've created (or plan to create):

```markdown
## Skills System

Auto-activating skills provide consistent patterns:

1. **`express-api-dev`** - REST API patterns with Express
   - Auto-activates: "api", "endpoint", "route", working in `/src/api`

2. **`postgresql-db`** - Database operations and migrations
   - Auto-activates: "database", "query", "migration", working in `/src/db`

3. **`jest-testing`** - Unit and integration testing patterns
   - Auto-activates: "test", "testing", working in `*.test.ts` files
```

### Step 3: Add Project-Specific Rules

Every project has unique conventions. Document them:

```markdown
## Code Style

### Naming Conventions
- **Files**: `kebab-case.ts`
- **Classes**: `PascalCase`
- **Functions**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Import Order
1. External dependencies
2. Internal absolute imports
3. Internal relative imports
4. Types

### Error Handling
All errors must extend `AppError` base class with proper error codes.
```

### Step 4: Keep It Lean

Target: **200-300 lines** for CLAUDE.md

**Move to skills**:
- Detailed patterns and examples
- Technology-specific best practices
- Complex workflows
- Reference tables

**Keep in CLAUDE.md**:
- Quick start commands
- Project structure overview
- Core principles
- Links to skills

---

## Creating Skills for Your Stack

### Common Tech Stack Examples

#### Node.js + Express + PostgreSQL

**Skills to create**:

1. **express-api-dev**
   - REST endpoint patterns
   - Middleware usage
   - Request validation
   - Error handling

2. **postgresql-db**
   - Query patterns
   - Migrations
   - Transactions
   - Connection pooling

3. **jest-testing**
   - Test structure
   - Mocking patterns
   - Database test setup
   - API test patterns

**Triggers example**:
```json
{
  "express-api-dev": {
    "promptTriggers": {
      "keywords": ["api", "endpoint", "express", "route", "middleware"],
      "intentPatterns": ["(create|implement).*?(endpoint|route)"]
    },
    "fileTriggers": {
      "pathPatterns": ["src/api/**/*.ts", "src/routes/**/*.ts"],
      "contentPatterns": ["import.*express", "Router\\("]
    }
  }
}
```

#### React + Next.js + Tailwind

**Skills to create**:

1. **nextjs-app-dev**
   - App Router patterns
   - Server vs Client components
   - Data fetching
   - Routing patterns

2. **react-components**
   - Component structure
   - Hooks usage
   - Performance optimization
   - Accessibility

3. **tailwind-styling**
   - Utility classes
   - Custom components
   - Responsive design
   - Dark mode

**Triggers example**:
```json
{
  "react-components": {
    "promptTriggers": {
      "keywords": ["component", "react", "hooks", "useState", "useEffect"],
      "intentPatterns": ["(create|build).*?component"]
    },
    "fileTriggers": {
      "pathPatterns": ["components/**/*.tsx", "app/**/*.tsx"],
      "contentPatterns": ["'use client'", "export default function"]
    }
  }
}
```

#### Python + FastAPI + SQLAlchemy

**Skills to create**:

1. **fastapi-dev**
   - Endpoint definition
   - Dependency injection
   - Request/response models
   - Async patterns

2. **sqlalchemy-db**
   - Model definition
   - Query patterns
   - Relationships
   - Migrations with Alembic

3. **pytest-testing**
   - Fixture patterns
   - Async test handling
   - Database test setup
   - API testing

**Triggers example**:
```json
{
  "fastapi-dev": {
    "promptTriggers": {
      "keywords": ["fastapi", "endpoint", "api", "pydantic", "route"],
      "intentPatterns": ["(create|add).*?(endpoint|route)"]
    },
    "fileTriggers": {
      "pathPatterns": ["src/api/**/*.py", "app/**/*.py"],
      "contentPatterns": ["from fastapi", "@app\\.(get|post|put|delete)"]
    }
  }
}
```

#### E2E Testing with Chrome DevTools MCP

**Important**: The source project this template was extracted from uses Chrome DevTools MCP as a **critical component** for E2E browser automation testing.

**Setup**:

1. **Install Chrome DevTools MCP**:
```bash
claude mcp add chrome-devtools "npx chrome-devtools-mcp"
```

2. **Create E2E Testing Skill**:

Create `.claude/skills/e2e-testing-framework/SKILL.md`:

```markdown
# E2E Testing Framework

**Auto-activates when**: Writing E2E tests, browser automation, testing user workflows

## Mandatory 4-Pillar Structure

### Pillar 1: Step 0 - Authentication Context Verification
ALWAYS verify authentication state before testing features.

### Pillar 2: Step-by-Step Execution
Each action is a numbered step with:
- Action taken
- Expected outcome
- Actual outcome
- Pass/Fail status

### Pillar 3: Fail-Fast Behavior
Stop immediately on first failure, report clearly.

### Pillar 4: Rich Completion Reports
Complete summary with:
- All steps executed
- Pass/fail counts
- Screenshots/snapshots
- Next actions

## Chrome MCP Tools

**Navigation**:
- `mcp__chrome-devtools__navigate_page(url)`
- `mcp__chrome-devtools__wait_for(text)`

**Interaction**:
- `mcp__chrome-devtools__click(uid)`
- `mcp__chrome-devtools__fill(uid, value)`

**Verification**:
- `mcp__chrome-devtools__take_snapshot()`
- `mcp__chrome-devtools__list_console_messages()`

## Example Test Pattern

\`\`\`markdown
### Step 0: Verify Authentication
- Navigate to /app
- Check for user avatar
- Verify no redirect to login

### Step 1: Navigate to Feature
- Click "Feature" nav item
- Wait for page load
- Take snapshot

### Step 2: Perform Action
- Fill form field
- Click submit
- Verify success message
\`\`\`
```

3. **Add Triggers**:

```json
{
  "e2e-testing-framework": {
    "type": "testing",
    "priority": "high",
    "description": "E2E testing with Chrome DevTools MCP",
    "promptTriggers": {
      "keywords": ["e2e", "end-to-end", "browser", "chrome", "test", "testing"],
      "intentPatterns": [
        "(create|write|implement).*?(e2e|end.?to.?end).*?test",
        "test.*?(workflow|flow|journey)",
        "verify.*?(browser|ui|interface)"
      ]
    },
    "fileTriggers": {
      "pathPatterns": ["test/e2e/**/*", "**/*e2e*.md"],
      "contentPatterns": ["mcp__chrome-devtools", "Step 0.*Authentication"]
    }
  }
}
```

4. **Key Principles**:

- **Step 0 is mandatory**: Always verify auth context first
- **Fail-fast**: Stop on first error, don't continue
- **Rich reporting**: Complete summary at end
- **Screenshots**: Capture state at each step
- **Console monitoring**: Check for errors throughout

**Why Chrome MCP?**

The source project chose Chrome DevTools MCP because:
- Real browser automation (not mocks)
- Visual verification with snapshots
- Console error detection
- Interactive debugging capability
- Full user workflow simulation

**Alternative Approaches**:

If you don't want to use Chrome MCP, you can:
- Use Playwright directly (without MCP)
- Use Cypress
- Use Selenium
- Create your own testing skill with your preferred tool

But the 4-pillar structure (Step 0, step-by-step, fail-fast, rich reports) is recommended regardless of tooling.

---

## Customizing Hooks

### Adapting the Stop Hook

The TypeScript stop hook can be adapted for other languages:

#### Python (mypy)

Edit `~/.claude/hooks/stop.ts`:

```typescript
function checkTypeErrors(): string | null {
  try {
    // Run mypy instead of tsc
    execSync("python -m mypy .", {
      cwd: process.cwd(),
      stdio: "pipe",
      encoding: "utf-8",
      timeout: 10000,
    });
    return null;
  } catch (error: any) {
    // Parse mypy output
    const output = error.stdout || error.stderr || "";
    const errorLines = output.split("\n").filter((line: string) =>
      line.includes("error:")
    );

    if (errorLines.length === 0) return null;

    return `⚠️ **Mypy Errors Detected**:\n\n\`\`\`\n${errorLines.slice(0, 5).join("\n")}\n\`\`\``;
  }
}
```

#### Rust (cargo check)

```typescript
function checkCompilation(): string | null {
  try {
    execSync("cargo check --message-format=short", {
      cwd: process.cwd(),
      stdio: "pipe",
      encoding: "utf-8",
      timeout: 30000, // Rust can be slow
    });
    return null;
  } catch (error: any) {
    const output = error.stdout || error.stderr || "";
    const errorLines = output.split("\n").filter((line: string) =>
      line.includes("error[E")
    );

    if (errorLines.length === 0) return null;

    return `⚠️ **Cargo Check Errors**:\n\n\`\`\`\n${errorLines.slice(0, 5).join("\n")}\n\`\`\``;
  }
}
```

#### Multi-Language Projects

Create language-specific hooks:

```bash
~/.claude/hooks/
├── stop-typescript.ts    # TypeScript projects
├── stop-python.ts        # Python projects
└── stop-rust.ts          # Rust projects
```

Register conditionally based on project:

```bash
# In TypeScript project
claude hooks add PostToolUse ~/.claude/hooks/stop-typescript.ts --matcher "Edit|Write"

# In Python project
claude hooks add PostToolUse ~/.claude/hooks/stop-python.ts --matcher "Edit|Write"
```

### Adding Lint Checks

Extend stop hook to run linters:

```typescript
async function main() {
  // ... existing code ...

  // Check TypeScript
  const tsErrors = checkTypeScriptErrors();

  // Check ESLint
  const lintErrors = checkLint();

  const messages = [];
  if (tsErrors) messages.push(tsErrors);
  if (lintErrors) messages.push(lintErrors);

  if (messages.length > 0) {
    process.stdout.write(formatMessage(messages.join("\n\n")));
  }
}

function checkLint(): string | null {
  try {
    execSync("npx eslint . --max-warnings=0", {
      cwd: process.cwd(),
      stdio: "pipe",
      encoding: "utf-8",
      timeout: 10000,
    });
    return null;
  } catch (error: any) {
    // Parse ESLint output
    // Return formatted error message
  }
}
```

### Custom UserPromptSubmit Logic

Add project-specific skill activation logic:

```typescript
// In ~/.claude/hooks/user-prompt-submit.ts

// After skill matching, add custom logic
if (originalPrompt.toLowerCase().includes("urgent")) {
  // Inject urgency reminder
  const urgencyReminder = "\n⚠️ **URGENT REQUEST**: Prioritize correctness over speed.\n";
  modifiedPrompt += urgencyReminder;
}

if (originalPrompt.toLowerCase().includes("production")) {
  // Inject production safety reminder
  const prodReminder = "\n🔴 **PRODUCTION**: Extra caution required. Double-check all changes.\n";
  modifiedPrompt += prodReminder;
}
```

---

## Adapting Dev Docs Workflow

### Custom Dev Docs Templates

Edit `.claude/commands/create-dev-docs.md` to match your workflow:

**Example: Add "Testing" section**:

```markdown
### File 3: `[task-name]-tasks.md`

\`\`\`markdown
## Tasks

### Setup & Planning
- [x] Create dev docs structure
- [ ] [Setup task 1]

### Implementation
- [ ] [Implementation task 1]

### Testing                    ← ADD THIS
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Manual testing

### Documentation & Cleanup
- [ ] Update docs
\`\`\`
```

### Custom Slash Commands

Create project-specific commands:

```bash
# .claude/commands/run-full-check.md
```

```markdown
You are helping the user run a full quality check.

## Steps

1. Run TypeScript check: `npx tsc --noEmit`
2. Run linter: `npx eslint .`
3. Run tests: `npm test`
4. Run build: `npm run build`

Report results for each step. If any fail, stop and ask user how to proceed.
```

Usage: `/run-full-check`

---

## Team Customization

### Shared Skills Across Projects

For teams with multiple projects:

**Option 1: Global skills directory**

```bash
# Create team skills
mkdir -p ~/.claude/skills-team/

# Symlink in each project
ln -s ~/.claude/skills-team/.claude/skills/backend-standards .claude/skills/

# Share via git
git clone team-claude-skills.git ~/.claude/skills-team/
```

**Option 2: Git submodule**

```bash
# In your project
git submodule add https://github.com/acmecorp/claude-skills.git .claude/skills-shared

# In CLAUDE.md, reference both
```

### Team Conventions in CLAUDE.md

Document team-wide practices:

```markdown
## Team Conventions

### Code Review
- All changes require PR review
- At least 2 approvals for production
- Use conventional commits format

### Branch Naming
- `feature/TICKET-description`
- `fix/TICKET-description`
- `chore/description`

### Deployment
- Dev: Auto-deploy on merge to `develop`
- Staging: Manual deploy from `main`
- Production: Tagged releases only
```

### Custom Task Workflow

Adapt task-driven development for your team:

```markdown
## Our Task Workflow

**Status Flow**: Backlog → InProgress → Review → QA → Done

**Task Types**:
- **Feature**: New functionality (requires design approval)
- **Bug**: Fixes (requires reproduction steps)
- **Chore**: Maintenance (no user-facing changes)

**Required Sections**:
- Acceptance Criteria
- Testing Plan
- Rollback Plan (for production changes)
```

---

## Project Type Examples

### Microservices Architecture

**Skills per service**:
```
.claude/skills/
├── auth-service/          # Auth service patterns
├── payment-service/       # Payment service patterns
├── notification-service/  # Notification patterns
└── shared-patterns/       # Cross-service patterns
```

**File triggers**:
```json
{
  "auth-service": {
    "fileTriggers": {
      "pathPatterns": ["services/auth/**/*"]
    }
  }
}
```

### Monorepo

**Skills per package**:
```
.claude/skills/
├── web-app/               # Web app patterns
├── mobile-app/            # Mobile patterns
├── shared-lib/            # Shared library patterns
└── backend-api/           # Backend patterns
```

### Full-Stack Application

**Skills by layer**:
```
.claude/skills/
├── frontend/              # React patterns
├── backend/               # Express patterns
├── database/              # PostgreSQL patterns
└── deployment/            # Docker/K8s patterns
```

---

## Continuous Improvement

### Metrics to Track

Monitor these to gauge effectiveness:

1. **CLAUDE.md length** - Target: < 300 lines
2. **Skill activation rate** - How often skills trigger
3. **TypeScript errors caught** - Hook effectiveness
4. **Context loss incidents** - Dev docs effectiveness
5. **Repeated explanations** - Opportunities for new skills

### Feedback Loop

Every sprint or month:

1. **Review conversations** - What did you explain repeatedly?
2. **Update skills** - Add patterns you discovered
3. **Prune outdated content** - Remove what you're not using
4. **Refine triggers** - Improve activation accuracy
5. **Team retrospective** - Gather feedback

### Template Updates

When this template gets updates:

```bash
# Add template as remote
git remote add template https://github.com/gigacoded/agentic-autoflow.git

# Fetch updates
git fetch template

# Merge updates (resolve conflicts)
git merge template/main

# Review changes
git diff HEAD~1
```

---

## Common Customization Patterns

### Startup-Specific

Fast iteration, high autonomy:

- **Minimal skills** (1-2 core ones)
- **Lightweight task tracking** (dev docs only, skip PBI workflow)
- **Aggressive hooks** (fail-fast on any error)
- **Quick reference** CLAUDE.md

### Enterprise-Specific

Process compliance, audit trails:

- **Comprehensive skills** (one per major system)
- **Full task workflow** (PBI → tasks → approvals)
- **Detailed dev docs** (include compliance checklists)
- **Audit-friendly** commit/PR format

### Open Source Project

Community contributions, consistency:

- **Public skills** (contribution guidelines)
- **Contributor-focused** CLAUDE.md
- **Testing skills** (required for PRs)
- **Documentation skills** (README, API docs)

---

## Troubleshooting Customizations

### Skill Isn't Activating After Customization

**Check**:
```bash
# Validate JSON
cat .claude/skills/skill-rules.json | jq .

# Check skill name matches
ls .claude/skills/
cat .claude/skills/skill-rules.json | jq 'keys'
```

### Hook Breaking After Edit

**Test individually**:
```bash
echo '{"tool_name":"Edit"}' | ~/.claude/hooks/stop.ts
```

**Check syntax**:
```bash
npx tsc --noEmit ~/.claude/hooks/stop.ts
```

### Dev Docs Command Not Working

**Verify files**:
```bash
ls .claude/commands/
cat .claude/commands/create-dev-docs.md
```

**Restart Claude Code**

---

## Next Steps

After customization:

1. **Test thoroughly** - Try skills, hooks, commands
2. **Document changes** - Update your CLAUDE.md
3. **Share with team** - Gather feedback
4. **Iterate** - Refine based on actual usage

See [SKILLS-GUIDE.md](SKILLS-GUIDE.md) for detailed skill creation.
