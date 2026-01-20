---
name: "Convex Backend Development"
description: "Convex database functions, queries, mutations, schema design, MCP integration, and performance optimization"
---

# Convex Backend Development

**Auto-activates when**: Creating/modifying Convex functions, working with schema, debugging queries, optimizing database performance

## Overview

Develops efficient, type-safe Convex backend functions with optimal database performance. Focuses on query optimization, proper indexing, and bandwidth efficiency.

**Key Principle**: Every query must use an appropriate index. Full table scans are unacceptable.

---

## Autonomous Audit Process

When this skill activates, **proceed without asking** - follow these steps:

### Step 1: Identify Convex Code

Look at files in `convex/` directory:
- New or modified queries/mutations/actions
- Schema changes
- Cron jobs or high-frequency functions

### Step 2: Check for Anti-Patterns

Scan for these issues (use Grep tool):

```bash
# Find potential full table scans
grep -n "\.collect()" convex/*.ts
grep -n "\.filter(" convex/*.ts
```

| Pattern | Problem | Fix |
|---------|---------|-----|
| `.query("table").collect()` | Full table scan | Add `.withIndex()` |
| `.collect()` + JS `.filter()` | Fetches all, filters in JS | Use `.withIndex()` + server `.filter()` |
| `.filter()` without `.withIndex()` | No index = full scan | Add index to schema |
| Cron every N seconds + collect | N × full_scans/day | Ensure query uses index |

### Step 3: Verify Indexes

Check `convex/schema.ts` has required indexes:
- [ ] Every frequently queried field has an index
- [ ] Compound indexes for multi-field queries
- [ ] High-frequency queries (crons) use indexes

### Step 4: Apply Fixes

For each issue found:
1. Add missing index to schema if needed
2. Update query to use `.withIndex()`
3. Convert JS filtering to server-side `.filter()`

### Step 5: Verify & Report

- [ ] TypeScript compiles (`npx tsc --noEmit`)
- [ ] Test query still returns correct results
- [ ] Report changes made

---

## Core Rules

### 1. Always Use Indexes

Never query without an index - full table scans cost $10-50/day in overages:

```typescript
// ❌ Bad - Full table scan
const items = await ctx.db.query("items").collect();
const active = items.filter(i => i.status === "active");

// ✅ Good - Index-based query
const active = await ctx.db
  .query("items")
  .withIndex("by_status", (q) => q.eq("status", "active"))
  .collect();
```

### 2. Single-Purpose Functions

Each Convex function should do one thing well:

```typescript
// ❌ Bad - Multiple responsibilities
export const getUserAndPosts = query({
  handler: async (ctx) => {
    const user = await ctx.db.query("users").first();
    const posts = await ctx.db.query("posts").collect();
    const comments = await ctx.db.query("comments").collect();
    return { user, posts, comments };
  },
});

// ✅ Good - Single responsibility
export const getUser = query({
  args: { userId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.userId);
  },
});
```

### 3. Validate All Inputs

Use Convex validators for every argument:

```typescript
// ❌ Bad - No validation
export const create = mutation({
  args: {},
  handler: async (ctx, args: any) => { ... },
});

// ✅ Good - Explicit validation
export const create = mutation({
  args: {
    title: v.string(),
    status: v.union(v.literal("draft"), v.literal("published")),
    userId: v.id("users"),
  },
  handler: async (ctx, args) => { ... },
});
```

### 4. Use Server-Side Filtering

Filter on the server, not in JavaScript:

```typescript
// ❌ Bad - JS filtering after collect
const items = await ctx.db
  .query("items")
  .withIndex("by_user", (q) => q.eq("userId", userId))
  .collect();
return items.filter(i => i.status === "active");

// ✅ Good - Server-side filter
const items = await ctx.db
  .query("items")
  .withIndex("by_user", (q) => q.eq("userId", userId))
  .filter((q) => q.eq(q.field("status"), "active"))
  .collect();
```

### 5. Design Compound Indexes Properly

Order matters - equality fields first, range fields last:

```typescript
// Schema definition
defineTable({...})
  .index("by_user_status", ["userId", "status"])
  .index("by_user_createdAt", ["userId", "createdAt"])

// ✅ Correct usage - equality then range
.withIndex("by_user_createdAt", (q) =>
  q.eq("userId", userId).gte("createdAt", startDate)
)

// ❌ Wrong - can't do range then equality
.withIndex("by_user_createdAt", (q) =>
  q.gte("createdAt", startDate).eq("userId", userId)
)
```

---

## Convex MCP Integration

**IMPORTANT**: Use the Convex MCP tools to inspect and test:

### Available MCP Tools

When the Convex MCP is configured, you have access to these tools:

- **list_functions**: List all Convex functions (queries, mutations, actions)
- **get_function**: Get details about a specific function
- **run_query**: Execute a Convex query
- **run_mutation**: Execute a Convex mutation
- **run_action**: Execute a Convex action
- **list_tables**: List all database tables
- **get_schema**: Get the database schema
- **query_table**: Query records from a table

### Using MCP Tools

**List all functions:**
```
Use the list_functions MCP tool to see all available Convex functions
```

**Execute a query:**
```
Use the run_query MCP tool with:
- functionName: "tableName:functionName"
- args: JSON object with query arguments
```

**Query database directly:**
```
Use the query_table MCP tool to inspect table contents during development
```

### MCP Configuration

The Convex MCP should be configured in your Claude Code settings to connect to your deployment:

```json
{
  "mcpServers": {
    "convex": {
      "command": "npx",
      "args": ["-y", "@convex-dev/mcp-server@latest"],
      "env": {
        "CONVEX_DEPLOYMENT_URL": "https://your-deployment.convex.cloud"
      }
    }
  }
}
```

When working on Convex functions, always leverage the MCP tools to:
- Inspect existing functions before creating new ones
- Test queries and mutations directly
- Validate schema changes
- Debug data issues

---

## Performance & Bandwidth Optimization

**CRITICAL**: Database bandwidth is a major cost driver in Convex. Inefficient queries can cost $10-50/day in overages. Always audit queries for performance.

### Understanding Bandwidth Costs

Convex charges for **database bandwidth** - the amount of data transferred from the database to your functions:
- Every `.collect()` transfers ALL matching rows
- `.filter()` without an index scans the ENTIRE table
- High-frequency queries (crons, polling) multiply the impact

### Bandwidth Audit Checklist

When reviewing Convex code, check for these patterns:

| Pattern | Problem | Fix |
|---------|---------|-----|
| `.query("table").collect()` | Full table scan | Add `.withIndex()` |
| `.collect()` + `.filter()` in JS | Fetches all, filters in JS | Use `.withIndex()` or server `.filter()` |
| `.filter()` without `.withIndex()` | No index = full scan | Add index to schema |
| Cron calling query every N seconds | N × full_scans/day | Ensure query uses index |
| `.find()` after `.collect()` | Full scan for single item | Use `.withIndex().first()` |

### Bandwidth Calculation

Estimate bandwidth impact:
```
Daily bandwidth = (records_fetched × avg_record_size) × calls_per_day

Example:
- 100 records × 500 bytes = 50KB per call
- Called every 10 seconds = 8,640 calls/day
- Total: 50KB × 8,640 = 432 GB/day (!!)
```

---

## Common Patterns

### Flatten Query Logic

```typescript
// ❌ Before - nested conditionals
export const getItems = query({
  args: { userId: v.optional(v.id("users")) },
  handler: async (ctx, args) => {
    if (args.userId) {
      const items = await ctx.db.query("items").collect();
      return items.filter(i => i.userId === args.userId);
    } else {
      return await ctx.db.query("items").collect();
    }
  },
});

// ✅ After - early return, indexed query
export const getItems = query({
  args: { userId: v.optional(v.id("users")) },
  handler: async (ctx, args) => {
    if (!args.userId) {
      return await ctx.db.query("items").take(100);
    }

    return await ctx.db
      .query("items")
      .withIndex("by_userId", (q) => q.eq("userId", args.userId))
      .collect();
  },
});
```

### Replace .find() with Indexed Query

```typescript
// ❌ Before - collect then find
const users = await ctx.db.query("users").collect();
const user = users.find(u => u.email === email);

// ✅ After - direct indexed lookup
const user = await ctx.db
  .query("users")
  .withIndex("by_email", (q) => q.eq("email", email))
  .first();
```

### Authenticate Early

```typescript
// ❌ Before - auth check buried in logic
export const getData = query({
  handler: async (ctx) => {
    const data = await ctx.db.query("data").collect();
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    return data.filter(d => d.userId === identity.subject);
  },
});

// ✅ After - early auth, indexed query
export const getData = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");

    return await ctx.db
      .query("data")
      .withIndex("by_userId", (q) => q.eq("userId", identity.subject))
      .collect();
  },
});
```

### Batch Related Queries

```typescript
// ❌ Before - sequential queries
const user = await ctx.db.get(userId);
const posts = await getUserPosts(ctx, userId);
const followers = await getFollowers(ctx, userId);

// ✅ After - parallel queries
const [user, posts, followers] = await Promise.all([
  ctx.db.get(userId),
  getUserPosts(ctx, userId),
  getFollowers(ctx, userId),
]);
```

---

## When to Apply

### Always Apply

- Creating new Convex functions
- Adding database queries
- Modifying schema
- Debugging performance issues
- Reviewing Convex code

### Don't Apply

- Frontend-only changes
- Non-Convex backend code
- Third-party integrations (actions)

---

## Quick Checklist

Before marking Convex code complete:

- [ ] All queries use `.withIndex()` (no full table scans)
- [ ] No JS `.filter()` after `.collect()` (use server-side filter)
- [ ] Schema has indexes for all frequently queried fields
- [ ] High-frequency queries (crons) are optimized
- [ ] Validators (`v.*`) on all function arguments
- [ ] Authentication checked early
- [ ] TypeScript compiles without errors
- [ ] Functions tested via MCP or dashboard

---

## References

- [Convex Documentation](https://docs.convex.dev/)
- [Convex TypeScript API](https://docs.convex.dev/api/modules)
- [Convex Best Practices](https://docs.convex.dev/production/best-practices)
- [Convex Indexes Documentation](https://docs.convex.dev/database/reading-data/indexes/)
- [Convex Billing](https://docs.convex.dev/production/billing)
