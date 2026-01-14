# Agentic AutoFlow - Claude Code Workflow Automation

**Production-grade Claude Code infrastructure for professional software development**

Drop this into any existing codebase to get auto-activating skills, quality automation hooks, and structured task management - all working with Claude Code out of the box.

## 30-Second Integration

**Prerequisites:**
- [Claude Code](https://claude.ai/install.sh) installed (`curl -fsSL https://claude.ai/install.sh | bash`)
- Node.js 18+ (for TypeScript hooks)

### Option A: Quick Copy (Recommended)

```bash
# Clone this repo temporarily
git clone https://github.com/gigacoded/agentic-autoflow.git /tmp/agentic-autoflow

# Copy to your project (both .claude/ and .mcp.json are required)
cp -r /tmp/agentic-autoflow/.claude /path/to/your/project/
cp /tmp/agentic-autoflow/.mcp.json /path/to/your/project/

# Navigate to your project and start Claude Code
cd /path/to/your/project
claude
```

### Option B: Setup Script

```bash
# Clone and run installer
git clone https://github.com/gigacoded/agentic-autoflow.git
cd agentic-autoflow

# Install to your project (interactive setup)
./setup.sh /path/to/your/project
```

### What Gets Copied

| Required | Path | Purpose |
|----------|------|---------|
| **Yes** | `.claude/` | Skills, hooks, commands, settings |
| **Yes** | `.mcp.json` | MCP server configuration (Convex, Chrome DevTools) |
| Optional | `docs/delivery/` | Task management templates |
| Optional | `dev/active/` | Dev docs working directory |

## What Gets Activated

Once you copy `.claude/` and `.mcp.json` to your project, Claude Code automatically gains:

| Feature | What It Does | Activated By |
|---------|--------------|--------------|
| **Skills** | Domain-specific best practices auto-inject | Keywords in your prompts |
| **TypeScript Checks** | Runs `tsc --noEmit` after edits | Any Edit/Write tool use |
| **Slash Commands** | `/create-dev-docs`, `/update-dev-docs` | Type the command |
| **Task Management** | PBI workflow with status tracking | Work in `docs/delivery/` |
| **Convex MCP** | Query database, view schemas, run functions | First session approval |
| **Chrome DevTools MCP** | Browser automation, screenshots, debugging | First session approval |

## Included Skills

| Skill | Triggers On | Best Practices For |
|-------|-------------|-------------------|
| `frontend-dev` | "component", "react", "tanstack", "tailwind", "route" | TanStack Start, React, Tailwind CSS, shadcn/ui |
| `convex-backend-dev` | "convex", "query", "mutation", "schema" | Convex backend development |
| `task-management-dev` | "task", "pbi", "backlog", "planning" | Task-driven development workflow |
| `example-skill` | "example", "demo" | Template for your own skills |

## How It Works

### Skill Auto-Activation

When you ask Claude something like:
```
> create a new route for user profiles
```

The system detects keywords (`route`, `component`) and injects:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SKILL ACTIVATION CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Detected context: React, TanStack Start, and Tailwind CSS frontend development

💡 Recommended Skill: **frontend-dev**

Please reference this skill's guidelines for best practices and patterns.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Claude then follows the patterns defined in `.claude/skills/frontend-dev/SKILL.md`.

### TypeScript Quality Checks

After every file edit, the stop hook automatically runs `tsc --noEmit`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 QUALITY CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  **TypeScript Errors Detected**:

src/routes/index.tsx(15,3): error TS2322: Type 'string' is not assignable to type 'number'.

Please fix these errors before continuing.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Configuration (settings.json)

The hooks are configured via `.claude/settings.json` using Claude Code's official [hooks system](https://code.claude.com/docs/en/hooks):

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx .claude/hooks-global/user-prompt-submit.ts"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx .claude/hooks-global/stop.ts"
          }
        ]
      }
    ]
  }
}
```

**Note**: `UserPromptSubmit` does not support matchers (per official docs). `PostToolUse` uses regex matchers to filter by tool name.

### Global vs Project Hooks

**Project hooks** (`.claude/settings.json`) - Included in this repo, work immediately:
- Scoped to this project only
- Shared with your team via git
- No additional setup required

**Global hooks** (`~/.claude/settings.json`) - For all your projects:
```bash
# Create user settings if it doesn't exist
mkdir -p ~/.claude

# Add hooks to your global settings
cat >> ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx ~/.claude/hooks/user-prompt-submit.ts"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx ~/.claude/hooks/stop.ts"
          }
        ]
      }
    ]
  }
}
EOF

# Copy hook scripts
mkdir -p ~/.claude/hooks
cp .claude/hooks-global/* ~/.claude/hooks/
```

## Project Structure

```
your-project/
├── .claude/
│   ├── settings.json              # Hook configuration (auto-loaded by Claude Code)
│   ├── skills/
│   │   ├── skill-rules.json       # Activation triggers for all skills
│   │   ├── frontend-dev/
│   │   │   ├── SKILL.md           # TanStack Start, React, Tailwind patterns
│   │   │   ├── skill-config.json
│   │   │   └── resources/
│   │   │       ├── components.md
│   │   │       └── react-performance.md
│   │   ├── convex-backend-dev/
│   │   │   └── ...
│   │   ├── task-management-dev/
│   │   │   └── ...
│   │   └── example-skill/
│   │       └── ...
│   ├── hooks-global/
│   │   ├── user-prompt-submit.ts  # Skill activation hook
│   │   └── stop.ts                # TypeScript error checking hook
│   ├── commands/
│   │   ├── create-dev-docs.md     # /create-dev-docs command
│   │   ├── update-dev-docs.md     # /update-dev-docs command
│   │   └── dev-docs-status.md     # /dev-docs-status command
│   └── agents/                    # (Optional) Custom subagents
├── .mcp.json                      # MCP server configuration (Convex, Chrome DevTools)
├── docs/delivery/                 # (Optional) PBI workflow
│   ├── backlog.md
│   └── examples/
└── dev/active/                    # (Optional) Dev docs workspace
```

## Creating Your Own Skills

### 1. Create Skill Directory

```bash
mkdir -p .claude/skills/my-skill/resources
```

### 2. Write SKILL.md

```markdown
# My Custom Skill

**Auto-activates when**: Working with [your technology]

## Patterns

### Pattern 1: [Name]
\`\`\`typescript
// Code example
\`\`\`

## Best Practices
- Practice 1
- Practice 2
```

### 3. Add to skill-rules.json

```json
{
  "my-skill": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "description": "My custom skill description",
    "promptTriggers": {
      "keywords": ["keyword1", "keyword2"],
      "intentPatterns": ["(create|build).*?(thing)"]
    },
    "fileTriggers": {
      "pathPatterns": ["src/my-domain/**/*.ts"],
      "contentPatterns": ["import.*my-library"]
    }
  }
}
```

### 4. Create skill-config.json

```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "description": "My custom skill",
  "resources": ["resources/patterns.md"]
}
```

## Slash Commands

| Command | Description |
|---------|-------------|
| `/create-dev-docs` | Initialize dev docs for long tasks (3+ steps) |
| `/update-dev-docs` | Update progress before context compaction |
| `/dev-docs-status` | Show progress overview |

## Environment Variables

Set these in `.claude/settings.json` under `env`:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  }
}
```

Or set globally before starting Claude:

```bash
export BASH_DEFAULT_TIMEOUT_MS=60000  # Longer timeout for slow commands
claude
```

## Customization Examples

### Python Projects

Create `.claude/skills/python-dev/SKILL.md` and modify the stop hook to run `mypy`:

```typescript
// In stop.ts, add:
const hasPython = fs.existsSync(path.join(cwd, "pyproject.toml"));
if (hasPython) {
  execSync("mypy .", { ... });
}
```

### Go Projects

```typescript
// In stop.ts:
const hasGo = fs.existsSync(path.join(cwd, "go.mod"));
if (hasGo) {
  execSync("go vet ./...", { ... });
}
```

### Rust Projects

```typescript
// In stop.ts:
const hasRust = fs.existsSync(path.join(cwd, "Cargo.toml"));
if (hasRust) {
  execSync("cargo check", { ... });
}
```

## Troubleshooting

### Skills Not Activating

1. Check `.claude/skills/skill-rules.json` exists
2. Verify keywords match your prompt (case-insensitive)
3. Check Claude Code is reading the hooks:
   ```bash
   claude config get hooks
   ```

### TypeScript Hook Not Running

1. Ensure `node_modules/.bin/tsc` exists (run `npm install`)
2. Check for `package.json` in project root
3. Verify hook is registered:
   ```bash
   cat .claude/settings.json | grep -A 20 hooks
   ```

### Hooks Timeout

Increase timeout in settings:
```json
{
  "env": {
    "BASH_DEFAULT_TIMEOUT_MS": "30000"
  }
}
```

## MCP Server Integration

This repo includes a pre-configured `.mcp.json` with two essential MCP servers:

### Included MCP Servers

| Server | Purpose | Documentation |
|--------|---------|---------------|
| **convex** | Query/mutate Convex database, view schemas, execute functions | [Convex MCP Docs](https://docs.convex.dev/ai/convex-mcp-server) |
| **chrome-devtools** | Browser automation, debugging, screenshots, performance | [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) |

### Pre-configured `.mcp.json`

```json
{
  "mcpServers": {
    "convex": {
      "command": "npx",
      "args": ["-y", "convex", "mcp", "start"]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--isolated"]
    }
  }
}
```

**Note:** Chrome DevTools runs in `--isolated` mode by default, which uses a temporary clean browser profile for each session. This prevents the AI from accessing your personal browsing data (passwords, cookies, history) and ensures secure, reproducible automation sessions.

### First-Time Setup

When you first run `claude` in your project, you'll be prompted to approve the MCP servers:

```bash
cd your-project
claude

# Claude will ask: "Allow MCP server 'convex'?" → Yes
# Claude will ask: "Allow MCP server 'chrome-devtools'?" → Yes
```

Verify servers are connected:
```bash
# Inside Claude Code
/mcp
```

### Alternative: CLI Installation

If you prefer to add servers via CLI instead of `.mcp.json`:

```bash
# Add Convex MCP (project scope - saved to .mcp.json)
claude mcp add-json convex '{"command":"npx","args":["-y","convex","mcp","start"]}'

# Add Chrome DevTools MCP with isolated mode (project scope)
claude mcp add-json chrome-devtools '{"command":"npx","args":["-y","chrome-devtools-mcp@latest","--isolated"]}'

# Verify installation
claude mcp list
```

### Using MCP Tools

Once connected, Claude can use MCP tools directly:

**Convex Examples:**
```
> Show me the schema for the users table
> Query all posts created in the last 24 hours
> What functions are available in the posts module?
```

**Chrome DevTools Examples:**
```
> Navigate to http://localhost:3000 and take a screenshot
> Check the console for any errors on the page
> Click the login button and fill in the form
```

### Advanced Chrome DevTools Options

| Flag | Purpose |
|------|---------|
| `--isolated` | Uses temporary browser profile (recommended for security) |
| `--headless` | Run without visible browser window (for CI/automation) |
| `--user-data-dir` | Use persistent profile for auth sessions |

**Default (isolated mode - recommended):**
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--isolated"]
    }
  }
}
```

**For E2E testing with persistent authentication:**
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y", "chrome-devtools-mcp@latest",
        "--user-data-dir", "${HOME}/.chrome-mcp-profile"
      ]
    }
  }
}
```

**For headless CI environments:**
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y", "chrome-devtools-mcp@latest",
        "--headless",
        "--isolated"
      ]
    }
  }
}
```

### Environment Variables

Set these in your shell or `.claude/settings.json`:

```bash
# Increase MCP startup timeout (default: varies)
export MCP_TIMEOUT=30000

# Increase tool execution timeout
export MCP_TOOL_TIMEOUT=60000

# Increase max output tokens from MCP tools
export MAX_MCP_OUTPUT_TOKENS=50000
```

### Auto-Approve MCP Servers

To skip approval prompts, add to `.claude/settings.json`:

```json
{
  "enableAllProjectMcpServers": true
}
```

Or approve specific servers only:

```json
{
  "enabledMcpjsonServers": ["convex", "chrome-devtools"]
}
```

## Quick Reference

| Task | Command |
|------|---------|
| Start Claude Code | `claude` |
| Continue last session | `claude -c` |
| Resume any session | `claude -r` |
| One-off query | `claude -p "question"` |
| Check config | `/config` |
| List hooks | View `.claude/settings.json` |
| Create dev docs | `/create-dev-docs` |

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Settings Reference](https://code.claude.com/docs/en/settings)
- [MCP Servers](https://code.claude.com/docs/en/mcp)

## License

MIT License - Use freely in your projects!

---

**Next Steps:**

1. Copy `.claude/` to your project
2. Run `claude` in your project directory
3. Ask Claude to do something - watch skills activate
4. Create your own skills for your tech stack
