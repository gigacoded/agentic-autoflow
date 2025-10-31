# Skills Creation Guide

Complete guide to creating and managing auto-activating skills in the Claude Code Workflow.

## What Are Skills?

Skills are context-aware documentation that Claude references automatically when relevant. Think of them as:

- **Just-in-time knowledge injection** - Appears when needed, not cluttering every conversation
- **Domain-specific best practices** - Tailored patterns for your tech stack
- **Living documentation** - Updated based on what actually works
- **Automatic activation** - No manual reminders needed

## Skill Structure

Each skill lives in `.claude/skills/[skill-name]/`:

```
.claude/skills/
└── my-skill/
    ├── SKILL.md              # Main skill content (required)
    ├── skill-config.json     # Metadata (optional but recommended)
    └── resources/            # Additional files (optional)
        ├── examples.md       # Extended examples
        ├── patterns.md       # Advanced patterns
        └── reference.md      # Reference tables
```

## Creating Your First Skill

### Step 1: Identify the Domain

Ask yourself:
- What technology/framework does this cover?
- What common mistakes happen in this area?
- What patterns do I wish Claude knew about?
- Is this big enough for a skill or just a CLAUDE.md section?

**Good skill candidates**:
- Backend API development with your framework
- Frontend component patterns
- Testing strategies
- Database operations
- Authentication/authorization
- Deployment processes

**Not good for skills** (use CLAUDE.md instead):
- Project-specific constants
- Single-line reminders
- Git commit format
- Simple preferences

### Step 2: Create Directory

```bash
# Replace 'backend-api' with your skill name
mkdir -p .claude/skills/backend-api/resources
```

### Step 3: Write SKILL.md

Use this template:

```markdown
# [Skill Name]

**Auto-activates when**: [Describe triggers - keywords, file paths, scenarios]

## Overview

[One paragraph: What does this skill help with? Why is it important?]

## Core Principles

1. **Principle 1** - [Fundamental truth about this domain]
2. **Principle 2** - [Another key principle]
3. **Principle 3** - [Third principle]

## [Topic 1: Common Operation]

### When to Use

[Describe the scenario where this applies]

### Implementation Pattern

\`\`\`typescript
// Well-commented code example showing the pattern
function exampleImplementation() {
  // Step-by-step implementation
  return result;
}
\`\`\`

### Best Practices

- ✅ **Do this**: Explanation
- ❌ **Avoid this**: Why and what to do instead
- 💡 **Pro tip**: Advanced insight

### Common Gotchas

**Problem 1**: Description
- Why it happens
- How to fix
- How to prevent

## [Topic 2: Another Pattern]

[Repeat structure]

## Error Handling

[How should errors be handled in this domain?]

\`\`\`typescript
try {
  // Operation
} catch (error) {
  // Error handling pattern specific to this domain
}
\`\`\`

## Testing Strategies

**Unit Tests**:
\`\`\`typescript
// Example test
\`\`\`

**Integration Tests**:
- Approach 1
- Approach 2

## Quick Reference

**[Common Task 1]**:
\`\`\`typescript
// One-liner or minimal example
\`\`\`

**[Common Task 2]**:
\`\`\`typescript
// One-liner or minimal example
\`\`\`

## Related Documentation

- [Official Docs](https://example.com)
- Related skill: \`other-skill-name\`
```

### Step 4: Add skill-config.json

Create `.claude/skills/backend-api/skill-config.json`:

```json
{
  "name": "backend-api",
  "type": "domain",
  "priority": "high",
  "description": "Backend API development patterns with Express",
  "resourceFiles": [
    "resources/examples.md"
  ]
}
```

**Fields**:
- `name`: Skill identifier (must match directory name)
- `type`: `domain` | `testing` | `meta`
- `priority`: `high` | `medium` | `low` (affects activation order)
- `description`: One-line summary (shown in activation message)
- `resourceFiles`: Array of additional files to load

### Step 5: Register Triggers

Edit `.claude/skills/skill-rules.json`:

```json
{
  "backend-api": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "description": "Backend API development patterns with Express",
    "promptTriggers": {
      "keywords": [
        "backend",
        "api",
        "endpoint",
        "route",
        "express",
        "server",
        "middleware"
      ],
      "intentPatterns": [
        "(create|add|implement|build).*?(endpoint|route|api)",
        "(how to|best practice).*?(backend|api|server)",
        "express.*?(middleware|router)",
        "(handle|process).*?request"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "src/api/**/*.ts",
        "src/routes/**/*.ts",
        "src/controllers/**/*.ts",
        "backend/**/*.ts"
      ],
      "contentPatterns": [
        "import.*express",
        "Router\\(",
        "app\\.get\\(",
        "app\\.post\\(",
        "req\\.body",
        "res\\.json\\("
      ]
    }
  }
}
```

**Trigger Types**:

**promptTriggers.keywords**: Simple word matching (case-insensitive)
- Single words: `"api"`, `"backend"`
- Phrases: `"end to end"`, `"chrome devtools"`

**promptTriggers.intentPatterns**: Regex patterns for intent
- `"(create|add).*?endpoint"` - Matches "create a new endpoint"
- `"how to.*?test"` - Matches "how to write a test"
- Use `.*?` for non-greedy matching
- All patterns are case-insensitive (i flag)

**fileTriggers.pathPatterns**: Glob patterns for file paths
- `"src/api/**/*.ts"` - Any .ts file under src/api/
- `"**/*test*.ts"` - Any file with 'test' in name

**fileTriggers.contentPatterns**: Regex for file contents
- `"import.*express"` - Express import statement
- `"Router\\("` - Router function call (escape parens!)
- `"\\bclass\\b"` - Word boundary matching

### Step 6: Test Activation

```bash
# Start Claude Code
claude

# Test with keyword
# Type: "How do I create a backend endpoint?"
```

**Expected**: See activation message mentioning your skill.

**If not activating**:
- Check skill-rules.json for typos
- Try more specific keywords
- Check that UserPromptSubmit hook is registered
- Restart Claude Code

## Skill Types

### Domain Skills (`type: "domain"`)

**Purpose**: Technology-specific patterns and best practices

**Examples**:
- Backend development (Express, FastAPI, Spring)
- Frontend frameworks (React, Vue, Svelte)
- Database operations (PostgreSQL, MongoDB)
- Cloud services (AWS, Azure, GCP)

**Structure**:
- Core principles
- Common patterns with code examples
- Error handling approaches
- Testing strategies
- Quick reference commands

### Testing Skills (`type: "testing"`)

**Purpose**: Testing frameworks and methodologies

**Examples**:
- E2E testing with Playwright/Cypress
- Unit testing with Jest/pytest
- Integration testing patterns
- Test data management

**Structure**:
- Testing philosophy
- Test structure and organization
- Common test patterns
- Assertion strategies
- Mock/stub patterns
- Test data setup

### Meta Skills (`type: "meta"`)

**Purpose**: Workflow and process guidance

**Examples**:
- Task management workflow
- Git workflow and conventions
- Code review process
- Documentation standards

**Structure**:
- Workflow steps
- Decision trees
- Templates and examples
- Status management
- Common scenarios

## Skill Best Practices

### 1. Stay Focused

❌ **Bad**: One mega-skill covering backend, frontend, and testing

✅ **Good**: Separate skills for each domain

**Guideline**: If SKILL.md exceeds 600 lines, split into multiple skills.

### 2. Include Real Examples

❌ **Bad**: Theoretical patterns without context

✅ **Good**: Examples from your actual codebase

```typescript
// ❌ Generic example
function handleRequest() { }

// ✅ Real example from your project
async function createQuoteEndpoint(req: Request, res: Response) {
  // Actual pattern you use
  const quote = await quoteService.create(req.body);
  return res.json(quote);
}
```

### 3. Document Common Mistakes

The best skills teach by showing what NOT to do:

```typescript
// ❌ **Anti-pattern**: No error handling
const data = await fetchData();

// ✅ **Correct**: Proper error handling
try {
  const data = await fetchData();
} catch (error) {
  logger.error('Fetch failed:', error);
  throw new ServiceError('Failed to fetch data');
}
```

### 4. Provide Quick Reference

Always include a Quick Reference section with one-liners:

```markdown
## Quick Reference

**Create endpoint**:
\`\`\`typescript
router.post('/resource', authMiddleware, createResource);
\`\`\`

**Validate input**:
\`\`\`typescript
const schema = z.object({ name: z.string() });
schema.parse(req.body);
\`\`\`
```

### 5. Keep It Current

Skills should evolve:
- Update when you discover better patterns
- Add gotchas as you encounter them
- Remove outdated approaches
- Document breaking changes

### 6. Use Resource Files for Large Content

Keep SKILL.md < 600 lines by moving extended content to resources/:

```
my-skill/
├── SKILL.md                    # Core patterns (400 lines)
└── resources/
    ├── examples.md             # Extended examples (200 lines)
    ├── migration-guide.md      # Migration docs (150 lines)
    └── reference-tables.md     # API reference (300 lines)
```

## Advanced Patterns

### Skill Hierarchies

For complex domains, create related skills:

```
.claude/skills/
├── backend-core/          # Core backend principles
├── backend-auth/          # Authentication patterns
├── backend-database/      # Database operations
└── backend-testing/       # Backend testing
```

Each can activate independently based on context.

### Conditional Activation

Use intent patterns for precise activation:

```json
"intentPatterns": [
  // Only activate for CREATE operations, not read
  "(create|add|implement).*?user",

  // Only for specific error types
  "handle.*?(validation|authentication).*?error",

  // Only for optimization questions
  "(optimize|improve|performance).*?query"
]
```

### Cross-Skill References

Skills can reference each other:

```markdown
## Authentication

For authentication patterns, see the `backend-auth` skill.

This skill focuses on data operations assuming authenticated context.
```

### Version-Specific Skills

For projects with multiple versions:

```
.claude/skills/
├── api-v1/           # Legacy API patterns
└── api-v2/           # Current API patterns
```

Use file path triggers to activate the right one:

```json
"fileTriggers": {
  "pathPatterns": [
    "src/api/v2/**/*.ts"  // Only activate for v2 files
  ]
}
```

## Common Skill Recipes

### Backend API Skill

**Covers**: REST endpoints, middleware, error handling

**Key sections**:
- Route definition patterns
- Request validation
- Response formatting
- Error handling
- Authentication/authorization
- Database operations
- Testing API endpoints

### Frontend Component Skill

**Covers**: Component patterns, state management, styling

**Key sections**:
- Component structure
- Props and typing
- State management
- Event handling
- Styling approaches
- Performance optimization
- Component testing

### Testing Skill

**Covers**: Test philosophy, structure, patterns

**Key sections**:
- Test organization
- Setup and teardown
- Mocking strategies
- Assertion patterns
- Test data management
- Coverage expectations
- CI/CD integration

## Troubleshooting

### Skill Not Activating

**Check triggers**:
```bash
# View skill-rules.json
cat .claude/skills/skill-rules.json

# Look for your keywords
```

**Common issues**:
- Typo in keyword
- Pattern too specific
- UserPromptSubmit hook not registered
- Need to restart Claude Code

**Fix**:
- Add more keywords
- Broaden intent patterns
- Test with explicit keyword

### Multiple Skills Activating

This is normal! Claude can reference multiple skills.

**Control with priority**:
```json
{
  "high-priority-skill": {
    "priority": "high",  // Shows first
    ...
  },
  "low-priority-skill": {
    "priority": "low",   // Shows last
    ...
  }
}
```

### Skill Too Long

If SKILL.md > 600 lines:

1. **Split into multiple skills** by subdomain
2. **Move examples to resources/** directory
3. **Remove outdated content**
4. **Use more concise examples**

## Skill Maintenance

### Regular Reviews

Every month or quarter:
- [ ] Remove patterns you're no longer using
- [ ] Add patterns you've been repeating
- [ ] Update examples to reflect current code
- [ ] Fix outdated dependencies/APIs
- [ ] Check for new gotchas to document

### User Feedback Loop

When Claude misses a pattern:
1. Note what you had to explain
2. Add to relevant skill
3. Update triggers if needed
4. Test activation

### Version Control

Treat skills like code:
- Commit changes with clear messages
- Review updates during code review
- Document major changes
- Tag versions for significant updates

## Examples from Production

Example production skills for reference:

- **e2e-testing-framework**: 4-pillar test structure with Chrome MCP
- **backend-dev**: Backend API patterns and best practices
- **frontend-dev-guidelines**: Modern React component patterns
- **task-management-dev**: PBI/task workflow

Study skill structure and content organization for ideas when creating your own.

---

**Next**: See [CUSTOMIZATION.md](CUSTOMIZATION.md) for adapting skills to your workflow.
