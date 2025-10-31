# Project Development Infrastructure

**Tech Stack**: Next.js 14 + React + Convex + Tailwind CSS + shadcn/ui + Clerk

Quick reference for development. See `.claude/skills/` for detailed patterns and best practices.

## Quick Start

**Development**:
- `npm run dev` - Start Next.js development server (port 3000)
- `npx convex dev` - Start Convex backend in dev mode

**Build & Quality**:
- `npm run build` - Build Next.js for production
- `npm run lint` - Lint code with ESLint
- `npx tsc --noEmit` - TypeScript type checking

**Testing**:
- E2E tests use Chrome DevTools MCP (see `e2e-testing-framework` skill)
- Backend testing via Convex MCP

---

## Skills System

Auto-activating skills provide consistent patterns without manual reminders:

1. **`convex-backend-dev`** - Convex backend patterns
   - Queries, mutations, actions
   - Authentication and authorization
   - Database operations, schema design
   - Error handling
   - Auto-activates: "backend", "convex", "query", "mutation", working in `/convex`

2. **`nextjs-frontend-dev`** - Next.js App Router development
   - Server vs Client components
   - Convex React hooks (useQuery, useMutation, useAction)
   - Tailwind CSS and shadcn/ui patterns
   - Clerk authentication
   - Auto-activates: "frontend", "react", "component", "nextjs", working in `/app` or `/components`

3. **`e2e-testing-framework`** - E2E testing with Chrome MCP
   - Mandatory 4-part structure: Step 0 auth, step-by-step, fail-fast, rich reports
   - Browser automation patterns
   - User workflow testing
   - Auto-activates: "e2e", "test", "chrome", "browser"

**Skills activate automatically** based on keywords, file paths, and intent patterns defined in `.claude/skills/skill-rules.json`.

---

## Dev Docs System

For large tasks (3+ steps), use dev docs to prevent context loss during auto-compaction:

**Commands**:
- `/create-dev-docs` - Initialize dev docs for new task
- `/update-dev-docs` - Update progress before auto-compaction
- `/dev-docs-status` - Show progress overview

**Location**: `dev/active/[task-name]/`

**Files Created**:
- `[task-name]-plan.md` - Approved plan
- `[task-name]-context.md` - Decisions, blockers, status
- `[task-name]-tasks.md` - Checklist (markdown checkboxes)

**Rule**: Mark tasks complete IMMEDIATELY after finishing, not in batches!

---

## Core Development Principles

### Type Safety

1. **Full TypeScript everywhere** - No `any` types
2. **Convex validators** - Use `v` validators for all function args
3. **Zod for forms** - Schema validation with react-hook-form
4. **Type imports** - Use `import type` when importing types only

### Component Architecture

1. **Server Components by default** - Use "use client" only when needed
2. **Colocate with usage** - Keep components near where they're used
3. **shadcn/ui for UI** - Don't create custom buttons, inputs, etc.
4. **Tailwind for styling** - No separate CSS files

### Convex Patterns

1. **Queries are read-only** - Never modify data in queries
2. **Mutations are transactional** - All operations succeed/fail together
3. **Actions for external APIs** - Non-deterministic operations only
4. **Auth first** - Always verify authentication before operations

### Testing Strategy

**E2E Testing (Browser)**:
- Uses Chrome DevTools MCP
- Mandatory for user-facing features
- See `e2e-testing-framework` skill for complete framework

**Backend Testing**:
- Convex MCP for interactive testing
- Test queries, mutations, actions in dev environment

---

## Build & Quality Hooks

Hooks automatically verify quality after code changes:

**`user-prompt-submit.ts`** (Pre-execution):
- Analyzes prompts for skill triggers
- Injects skill activation reminders

**`stop.ts`** (Post-execution):
- Checks TypeScript errors after edits
- Reminds about error handling patterns

---

## Project Structure

```
/
├── app/                  # Next.js App Router (frontend)
│   ├── layout.tsx       # Root layout
│   ├── page.tsx         # Home page
│   └── ...              # Other pages/routes
├── components/
│   ├── ui/              # shadcn/ui components
│   └── ...              # Custom components
├── convex/              # Convex backend
│   ├── schema.ts        # Database schema
│   ├── _generated/      # Generated types
│   └── ...              # Queries, mutations, actions
├── lib/                 # Utility functions
├── hooks/               # Custom React hooks
├── dev/active/          # Active dev docs (for long tasks)
├── .claude/
│   ├── skills/          # Auto-activating skills
│   ├── hooks/           # Quality automation hooks
│   └── commands/        # Slash commands
└── CLAUDE.md           # This file
```

---

## Environment Variables

**Required**:
- `CONVEX_DEPLOYMENT` - Convex deployment URL (from `npx convex dev`)
- `NEXT_PUBLIC_CONVEX_URL` - Public Convex URL
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` - Clerk public key
- `CLERK_SECRET_KEY` - Clerk secret key

**Optional**:
- `RESEND_API_KEY` - For sending emails (if using)
- `STRIPE_SECRET_KEY` - For payments (if using)

---

## Common Commands

### Convex

```bash
# Start dev environment
npx convex dev

# Run function manually
npx convex run module:functionName --arg key=value

# Deploy to production
npx convex deploy

# Check logs
npx convex logs
```

### shadcn/ui

```bash
# Add new component
npx shadcn-ui@latest add button

# Add all components
npx shadcn-ui@latest add --all
```

### Next.js

```bash
# Dev server
npm run dev

# Build
npm run build

# Start production server
npm start
```

---

## Important Constants Rule

Any value used more than once (numbers, strings, etc.) **must** be defined as a named constant:

**Bad**:
```typescript
for (let i = 0; i < 10; i++) { ... }
```

**Good**:
```typescript
const MAX_ITEMS = 10;
for (let i = 0; i < MAX_ITEMS; i++) { ... }
```

---

## Error Handling

### Convex Backend

All errors should be thrown with clear messages:

```typescript
if (!identity) {
  throw new Error("Not authenticated");
}

if (!quote) {
  throw new Error("Quote not found");
}

if (quote.userId !== identity.subject) {
  throw new Error("Not authorized to access this quote");
}
```

### Frontend

Use toast notifications for user-facing errors:

```typescript
try {
  await createQuote({ ... });
  toast({
    title: "Quote created",
    description: "The quote has been created successfully.",
  });
} catch (error) {
  toast({
    title: "Error",
    description: error.message,
    variant: "destructive",
  });
}
```

---

## Important Links

- **Convex Dashboard**: Check `npx convex dev` output for URL
- **Skills**: [`.claude/skills/`](./.claude/skills/)
- **Active Dev Docs**: `dev/active/` (if exists)
- **Convex Docs**: https://docs.convex.dev
- **Next.js Docs**: https://nextjs.org/docs
- **shadcn/ui**: https://ui.shadcn.com

---

## Quick Reference

### Git Workflow (If Applicable)

**Commit Message Format**:
```
[scope] Brief description

Details if needed
```

**Pull Request Title**:
```
[Feature/Fix] Description
```

### File Creation Policy

- **NEVER create files** unless absolutely necessary
- **ALWAYS prefer editing** existing files
- **NEVER create** documentation files (`.md`) proactively
- Exception: Files explicitly required by the framework or task

---

## Getting Help

- **Convex Backend**: Activate `convex-backend-dev` skill
- **Next.js Frontend**: Activate `nextjs-frontend-dev` skill
- **E2E Testing**: Activate `e2e-testing-framework` skill
- **Dev Docs**: Use `/create-dev-docs`, `/update-dev-docs`, `/dev-docs-status`

Skills activate automatically - no need to invoke manually!

---

**Version**: 1.0 (Convex + Next.js Stack Example)
**Based On**: [Claude Code Workflow Template](https://github.com/gigacoded/agentic-autoflow)
