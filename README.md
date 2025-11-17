# Claude Code Workflow Template

**Production-grade Claude Code infrastructure for professional software development**

This template provides a comprehensive workflow system for Claude Code, extracted from 6+ months of hardcore production use. It transforms Claude from a passive assistant into an active development partner through auto-activating skills, quality automation hooks, and structured task management.

## What You Get

### 🎯 Auto-Activating Skills System
- Skills automatically inject based on keywords, file paths, and code patterns
- No manual reminders needed - Claude knows when to apply best practices
- Reduces CLAUDE.md size by 74% while improving consistency
- Extensible framework for your own domain-specific patterns

### ⚡ Quality Automation Hooks
- **TypeScript Error Checking**: Automatically runs after Edit/Write operations
- **Skill Activation**: Analyzes prompts before execution to activate relevant skills
- **Global Registration**: Works across all your projects
- Fail-fast philosophy prevents cascading errors

### 📋 Dev Docs Workflow
- Prevents context loss on long tasks (3+ steps)
- Structured progress tracking with `/create-dev-docs`, `/update-dev-docs`, `/dev-docs-status`
- Markdown-based checklist system
- Integrated with task-driven development workflow

### 📊 Task-Driven Development (Optional)
- PBI (Product Backlog Item) workflow with status tracking
- Hierarchical task management
- Complete audit trail with status history
- Designed for professional software delivery

## Quick Start

### Prerequisites

- Claude Code CLI installed
- Node.js and npm (for TypeScript hook)
- Git (optional, for workflow features)

### 5-Minute Setup

**Step 1: Clone Template**

```bash
# Clone main template (customizable for any stack)
git clone https://github.com/gigacoded/agentic-autoflow.git
cd agentic-autoflow

# OR: Clone example branch (Convex + Next.js + Tailwind + shadcn/ui ready)
git clone -b example/convex-nextjs-stack https://github.com/gigacoded/agentic-autoflow.git
cd agentic-autoflow

# OR: Copy into existing project
cp -r /path/to/agentic-autoflow/.claude .claude/
```

**Step 2: Install Global Hooks**

```bash
# Create global hooks directory
mkdir -p ~/.claude/hooks

# Copy hooks
cp .claude/hooks-global/* ~/.claude/hooks/

# Register hooks
claude hooks add UserPromptSubmit ~/.claude/hooks/user-prompt-submit.ts --user
claude hooks add PostToolUse ~/.claude/hooks/stop.ts --user --matcher "Edit|Write"

# Verify registration
claude hooks list
```

**Step 3: Customize CLAUDE.md**

```bash
# Copy template
cp .claude/CLAUDE.template.md CLAUDE.md

# Edit for your project
# - Update project name
# - Update quick start commands
# - Add/remove skills as needed
# - Keep under 300 lines
```

**Step 4: Configure Skills**

```bash
# Review included example skill
cat .claude/skills/example-skill/SKILL.md

# Create your own skills (see docs below)
# Or copy skills from other projects
```

**Step 5: Test Installation**

```bash
# Start Claude Code
claude

# Test skill activation
# Type: "How do I write a test?"
# Should see skill activation message

# Test TypeScript hook (if TypeScript project)
# Make an edit, introduce a type error
# Should see error message after Edit/Write
```

## Example Branch: Convex + Next.js Stack

**Want a ready-to-use setup?** Check out the `example/convex-nextjs-stack` branch:

```bash
git clone -b example/convex-nextjs-stack https://github.com/gigacoded/agentic-autoflow.git
```

**Includes**:
- ✅ `convex-backend-dev` skill - Complete Convex patterns (queries, mutations, actions, auth)
- ✅ `nextjs-frontend-dev` skill - Next.js App Router, React, Tailwind, shadcn/ui
- ✅ `e2e-testing-framework` skill - 4-pillar testing with Chrome MCP
- ✅ Stack-specific CLAUDE.md - Ready-to-use quick reference
- ✅ Production patterns - Real code examples from 6+ months use

**Perfect for**: Convex + Next.js + Tailwind + shadcn/ui + Clerk projects

See [BRANCH-README.md](https://github.com/gigacoded/agentic-autoflow/blob/example/convex-nextjs-stack/BRANCH-README.md) in that branch for complete details.

---

## What's Included

### Core Infrastructure

```
.claude/
├── skills/                          # Auto-activating skills
│   └── example-skill/               # Example skill showing structure
│       ├── SKILL.md                 # Skill content (best practices, patterns)
│       ├── skill-config.json        # Skill metadata
│       └── resources/               # Additional reference materials
│           └── examples.md
├── hooks-global/                    # Global hooks (copy to ~/.claude/hooks/)
│   ├── user-prompt-submit.ts        # Skill activation hook
│   └── stop.ts                      # TypeScript error checking hook
├── commands/                        # Slash commands
│   ├── create-dev-docs.md           # Initialize dev docs
│   ├── update-dev-docs.md           # Update progress
│   └── dev-docs-status.md           # Show overview
├── CLAUDE.template.md               # Lean CLAUDE.md template
└── README.md                        # Setup guide (this for .claude dir)

docs/delivery/                       # Optional: Task-driven development
├── backlog.md.template              # PBI tracking template
└── README.md                        # Task workflow documentation

dev/active/                          # Dev docs (created by slash commands)
└── .gitkeep

README.md                            # This file
SETUP.md                             # Detailed setup guide
CUSTOMIZATION.md                     # How to adapt for your project
SKILLS-GUIDE.md                      # Creating custom skills
HOOKS-GUIDE.md                       # Writing custom hooks
MIGRATION-GUIDE.md                   # Migrating from monolithic CLAUDE.md
```

### Documentation

- **README.md** (this file) - Overview and quick start
- **SETUP.md** - Detailed setup instructions
- **CUSTOMIZATION.md** - Adapting the template for your project
- **SKILLS-GUIDE.md** - Creating and managing skills
- **HOOKS-GUIDE.md** - Writing custom hooks
- **MIGRATION-GUIDE.md** - Moving from monolithic CLAUDE.md
- **TASK-WORKFLOW.md** - Optional task-driven development workflow

## Key Features

### Skills System

Skills are context-aware best practices that activate automatically:

```json
{
  "my-skill": {
    "promptTriggers": {
      "keywords": ["backend", "api", "database"],
      "intentPatterns": ["(create|implement).*?(endpoint|route)"]
    },
    "fileTriggers": {
      "pathPatterns": ["src/api/**/*.ts"],
      "contentPatterns": ["import.*express"]
    }
  }
}
```

When Claude detects relevant context, skills inject automatically with:
- Domain-specific best practices
- Code patterns and examples
- Common gotchas and solutions
- Testing strategies

### Hooks System

**UserPromptSubmit Hook** - Runs before execution:
- Analyzes user prompt
- Checks for skill trigger patterns
- Injects skill activation reminders
- Fast (< 100ms)

**Stop Hook (PostToolUse)** - Runs after Edit/Write:
- Checks TypeScript errors with `tsc --noEmit`
- Gracefully skips if not TypeScript project
- 10-second timeout for large projects
- Fail-fast prevents cascading errors

### Dev Docs Workflow

For tasks with 3+ steps that risk context loss:

```bash
# Initialize tracking
/create-dev-docs

# Update progress before auto-compaction
/update-dev-docs

# Check status
/dev-docs-status
```

Creates structured documentation:
- `[task-name]-plan.md` - Approved plan and success criteria
- `[task-name]-context.md` - Decisions, blockers, status
- `[task-name]-tasks.md` - Markdown checklist with timestamps

### Task-Driven Development (Optional)

Professional workflow for product development:

- **PBIs (Product Backlog Items)**: Features with requirements and acceptance criteria
- **Tasks**: Implementation steps with status tracking
- **Status Flow**: Proposed → Agreed → InProgress → Review → Done
- **Audit Trail**: Complete history of all status changes
- **Documentation**: Each PBI has dedicated directory with PRD and tasks

## Customization

### Minimal Setup (Just Hooks)

If you only want quality automation without skills:

```bash
# Copy hooks only
cp .claude/hooks-global/* ~/.claude/hooks/
claude hooks add UserPromptSubmit ~/.claude/hooks/user-prompt-submit.ts --user
claude hooks add PostToolUse ~/.claude/hooks/stop.ts --user --matcher "Edit|Write"

# Skip skills and dev docs
```

### Skill-Based Setup (Recommended)

For comprehensive workflow with auto-activation:

```bash
# Full installation (see Quick Start above)
# Customize skills for your tech stack
# Create CLAUDE.md from template
```

### Full Task-Driven Development

For professional product delivery:

```bash
# Full installation + task workflow
cp docs/delivery/backlog.md.template docs/delivery/backlog.md
# Read TASK-WORKFLOW.md for complete guide
```

## Tech Stack Compatibility

### Works With Any Stack
- The core infrastructure (hooks, dev docs) is language-agnostic
- TypeScript hook gracefully skips if TypeScript not detected
- Create skills for your specific technologies

### Example Skill Adaptations

**Python Project**:
- Create `python-dev` skill with pytest patterns
- Modify stop hook to run `mypy` or `pylint`
- Add triggers for Django/Flask/FastAPI

**Rust Project**:
- Create `rust-dev` skill with cargo patterns
- Modify stop hook to run `cargo check`
- Add triggers for common crates

**Go Project**:
- Create `go-dev` skill with testing patterns
- Modify stop hook to run `go vet`
- Add triggers for goroutines, channels

## Migration from Monolithic CLAUDE.md

If you have a large CLAUDE.md (500+ lines):

1. **Read MIGRATION-GUIDE.md** for detailed instructions
2. **Identify topics** in your current CLAUDE.md
3. **Extract to skills** - One skill per domain/topic
4. **Update triggers** in `skill-rules.json`
5. **Test activation** with relevant keywords
6. **Create lean CLAUDE.md** from template (keep < 300 lines)

**Benefits**:
- 70-80% reduction in CLAUDE.md size
- Better organization and discoverability
- Automatic activation (no manual reminders)
- Easier to maintain and update

## Examples from Production

This template is based on production infrastructure from a real-world project:

- **4 production skills**: E2E testing, backend dev, frontend dev, task management
- **11 tasks to build it**: Complete infrastructure evolution
- **74% CLAUDE.md reduction**: 916 lines → 239 lines
- **6+ months in production**: Battle-tested on real product

### Testing Philosophy from Source Project

The source project uses a comprehensive testing approach with **Chrome DevTools MCP** for E2E testing:

**E2E Testing (Browser Automation)**:
- Uses Chrome DevTools MCP for browser automation
- Mandatory 4-part structure: Step 0 auth verification, step-by-step execution, fail-fast behavior, rich reports
- Critical for user-facing features
- See source project's `e2e-testing-framework` skill for complete patterns

**Backend Testing**:
- Interactive testing with backend MCP integration
- Unit tests for business logic
- Integration tests for API endpoints

**Frontend Testing**:
- Component testing
- Integration tests
- Visual regression testing

**Note**: The template itself doesn't require MCPs, but if you want to replicate the E2E testing workflow from the source project, you'll want to:
1. Install Chrome DevTools MCP: `claude mcp add chrome-devtools "npx chrome-devtools-mcp"`
2. Create an E2E testing skill based on the 4-pillar structure
3. See CUSTOMIZATION.md for examples

## Contributing

Found a bug or have a suggestion? Please open an issue or PR!

### Areas for Contribution

- Additional example skills (Python, Rust, Go, etc.)
- Alternative hook implementations (ESLint, Prettier, etc.)
- Language-specific stop hooks
- Documentation improvements
- Migration guides for other workflows

## Credits

**Created**: 2025-10-31
**Based On**:
- [Claude Code Best Practices Thread](https://www.reddit.com/r/ClaudeAI/comments/1ik26sk/claude_code_is_a_beast_tips_from_6_months_of/)
- [Anthropic Skills Documentation](https://docs.anthropic.com/claude/docs/skills)
- 6 months of hardcore production use

**Special Thanks**:
- Anthropic for Claude Code and skills/hooks framework
- The Claude Code community for sharing best practices

## License

MIT License - Use freely in your projects!

## Support

- **Documentation**: See the guides in this repository
- **Issues**: Open an issue on GitHub
- **Discussions**: Share your adaptations and improvements

---

**Next Steps**:

1. Follow the [Quick Start](#quick-start) guide
2. Read [SETUP.md](SETUP.md) for detailed installation
3. Review [CUSTOMIZATION.md](CUSTOMIZATION.md) for adaptation
4. Create your first skill with [SKILLS-GUIDE.md](SKILLS-GUIDE.md)
5. Test with a real task and iterate!
