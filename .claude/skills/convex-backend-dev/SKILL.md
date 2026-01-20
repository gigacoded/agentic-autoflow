---
name: "Convex Backend Development"
description: "Convex database functions, queries, mutations, schema design, and performance optimization"
---

# Convex Backend Development

**Auto-activates when**: Creating/modifying Convex functions, working with schema, debugging queries, optimizing database performance

## Overview

Develops efficient, type-safe Convex backend functions with optimal database performance. Focuses on query optimization, proper indexing, and bandwidth efficiency.

**Key Principle**: Every query must use an appropriate index. Full table scans are unacceptable.

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

## Development Process

### Step 1: Check Existing Functions

Before creating new functions:
- Use `list_functions` MCP tool to see existing Convex functions
- Use `get_schema` MCP tool to understand current schema
- Avoid duplicating existing functionality

### Step 2: Design Schema With Indexes

For every new table or query pattern:
- [ ] Identify all query patterns needed
- [ ] Create appropriate indexes
- [ ] Use compound indexes for multi-field queries
- [ ] Order compound index fields correctly

### Step 3: Write Type-Safe Functions

Use proper Convex patterns:
- [ ] Import from `"./_generated/server"`
- [ ] Use `v.*` validators for all args
- [ ] Use `query`, `mutation`, or `action` helpers
- [ ] Return typed data

### Step 4: Optimize Queries

Before finalizing:
- [ ] Every `.collect()` has a `.withIndex()`
- [ ] No JS filtering on database results
- [ ] High-frequency queries are optimized
- [ ] Use `.first()` instead of `.collect()[0]`

### Step 5: Test With MCP Tools

Verify using Convex MCP:
- Use `run_query` to test queries
- Use `query_table` to inspect data
- Verify results match expectations

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

## MCP Tools Reference

When Convex MCP is configured:

| Tool | Use For |
|------|---------|
| `list_functions` | See all available functions |
| `get_function` | Get function details |
| `run_query` | Test a query function |
| `run_mutation` | Execute a mutation |
| `list_tables` | See all database tables |
| `get_schema` | Get database schema |
| `query_table` | Inspect table contents |

---

## Quick Checklist

Before marking Convex code complete:

- [ ] All queries use `.withIndex()`
- [ ] No full table scans (`.query("table").collect()`)
- [ ] No JS filtering on query results
- [ ] All function args use `v.*` validators
- [ ] Authentication checked early
- [ ] Schema has required indexes
- [ ] High-frequency queries optimized
- [ ] Tested with MCP tools
