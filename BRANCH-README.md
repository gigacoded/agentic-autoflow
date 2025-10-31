# Convex + Next.js + Tailwind + shadcn/ui Example

**Branch**: `example/convex-nextjs-stack`

This branch contains a **complete, production-ready** Claude Code workflow configuration for projects using:

- **Next.js 14+** with App Router
- **React** with Server and Client Components
- **Convex** for backend (queries, mutations, actions)
- **Tailwind CSS** for styling
- **shadcn/ui** for UI components
- **Clerk** for authentication
- **TypeScript** throughout

## What's Different from Main Branch

### Main Branch (Generic Template)
- 1 example skill showing structure
- Generic documentation
- Adaptable for any tech stack

### This Branch (Convex/Next.js)
- 3 production-ready skills
- Stack-specific CLAUDE.md
- Comprehensive patterns for this exact stack
- Ready to drop into your project

---

## What's Included

### 1. Convex Backend Skill (`convex-backend-dev`)

**Complete patterns for**:
- Queries (read-only operations)
- Mutations (write operations)
- Actions (external APIs)
- Authentication with Clerk
- Authorization patterns
- Database operations
- Schema design
- Error handling
- Testing with Convex MCP

**Auto-activates when**:
- Working in `/convex` directory
- Keywords: "backend", "query", "mutation", "action", "database", "auth"
- Editing files with `ctx.db`, `ctx.auth`, etc.

### 2. Next.js Frontend Skill (`nextjs-frontend-dev`)

**Complete patterns for**:
- Server Components (default)
- Client Components ("use client")
- Convex React hooks (useQuery, useMutation, useAction)
- shadcn/ui component usage
- Tailwind CSS patterns
- Form handling with react-hook-form + Zod
- Clerk authentication
- App Router (layouts, pages, loading, errors)
- Image optimization
- Performance patterns

**Auto-activates when**:
- Working in `/app` or `/components` directories
- Keywords: "frontend", "component", "react", "nextjs", "tailwind", "shadcn"
- Editing files with "use client", `useQuery`, shadcn imports, etc.

### 3. E2E Testing Skill (`e2e-testing-framework`)

**Complete patterns for**:
- 4-pillar test structure (Step 0, step-by-step, fail-fast, reports)
- Chrome DevTools MCP integration
- Browser automation
- User workflow testing
- Authentication verification
- Visual regression testing

**Auto-activates when**:
- Keywords: "e2e", "test", "browser", "chrome", "workflow"
- Working on test files or E2E documentation

### 4. Stack-Specific CLAUDE.md

**Tailored quick reference with**:
- Convex + Next.js specific commands
- Project structure for this stack
- Environment variables needed
- Common patterns
- Testing strategy
- Links to relevant skills

---

## Setup Instructions

### Option 1: Drop into Existing Project

```bash
# In your Convex/Next.js project
cp -r /path/to/this/branch/.claude .
cp /path/to/this/branch/CLAUDE.md .

# Install global hooks
mkdir -p ~/.claude/hooks
cp .claude/hooks-global/* ~/.claude/hooks/
claude hooks add UserPromptSubmit ~/.claude/hooks/user-prompt-submit.ts --user
claude hooks add PostToolUse ~/.claude/hooks/stop.ts --user --matcher "Edit|Write"
```

### Option 2: Clone for New Project

```bash
# Clone this branch
git clone -b example/convex-nextjs-stack https://github.com/gigacoded/agentic-autoflow.git my-project
cd my-project

# Remove git history (optional)
rm -rf .git
git init

# Install global hooks
mkdir -p ~/.claude/hooks
cp .claude/hooks-global/* ~/.claude/hooks/
claude hooks add UserPromptSubmit ~/.claude/hooks/user-prompt-submit.ts --user
claude hooks add PostToolUse ~/.claude/hooks/stop.ts --user --matcher "Edit|Write"

# Initialize your Next.js + Convex project
# (follow Convex quickstart if starting from scratch)
```

---

## Testing the Setup

### 1. Test Skill Activation

```bash
claude

# Try these prompts to see skills activate:

# Should activate convex-backend-dev:
"How do I create a query in Convex?"

# Should activate nextjs-frontend-dev:
"How do I create a server component in Next.js?"

# Should activate e2e-testing-framework:
"How do I write an e2e test?"
```

### 2. Test TypeScript Hook

```bash
# Make an edit that introduces a TypeScript error
# Should see error message after Edit/Write tool
```

### 3. Test Dev Docs

```bash
# In Claude Code session
/create-dev-docs

# Should prompt for task name and create structure
```

---

## Skills Quick Reference

### Convex Backend Examples

**Create a Query**:
```typescript
export const getQuote = query({
  args: { quoteId: v.id("quotes") },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");

    return await ctx.db.get(args.quoteId);
  },
});
```

**Create a Mutation**:
```typescript
export const createQuote = mutation({
  args: {
    clientName: v.string(),
    total: v.number(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");

    return await ctx.db.insert("quotes", {
      userId: identity.subject,
      ...args,
      createdAt: Date.now(),
    });
  },
});
```

### Next.js Frontend Examples

**Server Component**:
```typescript
// app/quotes/page.tsx
export default async function QuotesPage() {
  const { userId } = await auth();
  if (!userId) redirect("/sign-in");

  return <div>Quotes Page</div>;
}
```

**Client Component with Convex**:
```typescript
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function QuotesList() {
  const quotes = useQuery(api.quotes.list);

  return (
    <div>
      {quotes?.map(quote => (
        <div key={quote._id}>{quote.clientName}</div>
      ))}
    </div>
  );
}
```

**shadcn/ui Form**:
```typescript
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";

function QuoteForm() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Create Quote</CardTitle>
      </CardHeader>
      <CardContent>
        <Input placeholder="Client name" />
        <Button>Create</Button>
      </CardContent>
    </Card>
  );
}
```

---

## MCP Integration

This stack benefits from two MCPs:

### 1. Chrome DevTools MCP (E2E Testing)

```bash
claude mcp add chrome-devtools "npx chrome-devtools-mcp"
```

**Usage**: Automated browser testing with visual verification

### 2. Convex MCP (Backend Testing)

```bash
claude mcp add convex "npx convex mcp start"
```

**Usage**: Interactive testing of queries, mutations, actions

---

## File Structure

```
.claude/
├── skills/
│   ├── convex-backend-dev/
│   │   ├── SKILL.md                  # Complete Convex patterns
│   │   └── skill-config.json
│   ├── nextjs-frontend-dev/
│   │   ├── SKILL.md                  # Complete Next.js patterns
│   │   └── skill-config.json
│   ├── e2e-testing-framework/
│   │   ├── SKILL.md                  # 4-pillar testing framework
│   │   ├── skill-config.json
│   │   └── resources/
│   │       └── chrome-mcp-tools.md   # MCP tools reference
│   └── skill-rules.json              # Activation triggers
├── hooks-global/
│   ├── user-prompt-submit.ts         # Skill activation
│   └── stop.ts                       # TypeScript checking
├── commands/
│   ├── create-dev-docs.md
│   ├── update-dev-docs.md
│   └── dev-docs-status.md
└── CLAUDE.template.md                # (Not used in this branch)

CLAUDE.md                             # Stack-specific quick reference
```

---

## Customization

### Adding Your Own Patterns

Edit the skills to add your project-specific patterns:

```bash
# Edit Convex skill
code .claude/skills/convex-backend-dev/SKILL.md

# Edit Next.js skill
code .claude/skills/nextjs-frontend-dev/SKILL.md

# Edit triggers
code .claude/skills/skill-rules.json
```

### Adding New Skills

Follow the pattern:

```bash
mkdir -p .claude/skills/my-new-skill
touch .claude/skills/my-new-skill/SKILL.md
touch .claude/skills/my-new-skill/skill-config.json

# Add triggers to skill-rules.json
```

---

## Benefits Over Generic Template

1. **Production-Ready** - Skills contain real patterns used in production
2. **Stack-Specific** - Every example is for this exact tech stack
3. **No Adaptation Needed** - Drop into your project and start
4. **Comprehensive** - Covers backend, frontend, and testing
5. **Auto-Activating** - Skills inject automatically based on context
6. **Battle-Tested** - Patterns from 6+ months of real-world use

---

## Comparison

| Aspect | Main Branch | This Branch |
|--------|-------------|-------------|
| **Skills** | 1 example skill | 3 production skills |
| **CLAUDE.md** | Generic template | Stack-specific |
| **Convex Patterns** | Not included | Complete |
| **Next.js Patterns** | Not included | Complete |
| **E2E Testing** | Documentation only | Full framework |
| **Ready to Use** | Needs customization | Ready immediately |

---

## Support

- **Main template docs**: See main branch README
- **Convex docs**: https://docs.convex.dev
- **Next.js docs**: https://nextjs.org/docs
- **shadcn/ui**: https://ui.shadcn.com
- **Issues**: Open on main repository

---

## License

MIT - Same as main template

---

**This branch is maintained as an example**. For other tech stacks, see the main branch and create your own skills following the pattern shown here.
