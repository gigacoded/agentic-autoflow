# Convex Backend Development

You are working with a Convex backend. This skill provides guidelines for developing backend functionality.

## Convex MCP Integration

**IMPORTANT**: This project uses the official Convex MCP (Model Context Protocol) server for enhanced development capabilities.

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

## Core Principles

1. **Functions are Single-Purpose**: Each Convex function should do one thing well
2. **Type Safety**: Always use TypeScript with proper types from Convex
3. **Error Handling**: Use proper error handling and validation
4. **Security**: Validate inputs and use authentication where needed

## Convex Function Types

### Queries
- Read-only operations
- Can be subscribed to for real-time updates
- Use `query()` helper from `convex/server`

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

export const get = query({
  args: { id: v.id("tableName") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});
```

### Mutations
- Write operations (create, update, delete)
- Use `mutation()` helper from `convex/server`

```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const create = mutation({
  args: {
    field1: v.string(),
    field2: v.number(),
  },
  handler: async (ctx, args) => {
    const id = await ctx.db.insert("tableName", {
      field1: args.field1,
      field2: args.field2,
    });
    return id;
  },
});
```

### Actions
- For side effects (external APIs, email, etc.)
- Use `action()` helper from `convex/server`

```typescript
import { action } from "./_generated/server";
import { v } from "convex/values";

export const sendEmail = action({
  args: { to: v.string(), subject: v.string() },
  handler: async (ctx, args) => {
    // Call external API
    await fetch("https://api.example.com/email", {
      method: "POST",
      body: JSON.stringify(args),
    });
  },
});
```

## Database Patterns

### Schema Definition
```typescript
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  tableName: defineTable({
    field1: v.string(),
    field2: v.number(),
    userId: v.id("users"),
  })
    .index("by_userId", ["userId"])
    .searchIndex("search_field1", {
      searchField: "field1",
    }),
});
```

### Common Operations

**Query with filter:**
```typescript
const items = await ctx.db
  .query("tableName")
  .filter((q) => q.eq(q.field("userId"), userId))
  .collect();
```

**Query with index:**
```typescript
const items = await ctx.db
  .query("tableName")
  .withIndex("by_userId", (q) => q.eq("userId", userId))
  .collect();
```

**Update:**
```typescript
await ctx.db.patch(id, { field1: newValue });
```

**Delete:**
```typescript
await ctx.db.delete(id);
```

## Authentication

### Getting Current User
```typescript
import { query } from "./_generated/server";

export const myQuery = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }
    const user = await ctx.db
      .query("users")
      .withIndex("by_token", (q) =>
        q.eq("tokenIdentifier", identity.tokenIdentifier)
      )
      .unique();
    return user;
  },
});
```

## File Structure

```
convex/
├── schema.ts              # Database schema
├── _generated/            # Auto-generated types
├── tableName.ts           # Functions for a specific table
├── utils/                 # Shared utilities
│   └── validators.ts      # Input validation helpers
└── http.ts               # HTTP actions (optional)
```

## Best Practices

1. **Validate All Inputs**: Use Convex validators (`v.*`) for all arguments
2. **Use Indexes**: Create indexes for frequently queried fields
3. **Batch Operations**: Use `Promise.all()` for parallel operations
4. **Error Messages**: Provide clear error messages for debugging
5. **Avoid N+1 Queries**: Fetch related data efficiently
6. **Use Transactions**: Mutations are automatically transactional

---

## Performance & Bandwidth Optimization

**CRITICAL**: Database bandwidth is a major cost driver in Convex. Inefficient queries can cost $10-50/day in overages. Always audit queries for performance.

### Understanding Bandwidth Costs

Convex charges for **database bandwidth** - the amount of data transferred from the database to your functions:
- Every `.collect()` transfers ALL matching rows
- `.filter()` without an index scans the ENTIRE table
- High-frequency queries (crons, polling) multiply the impact

### The #1 Mistake: Full Table Scans

```typescript
// BAD - Full table scan, then JS filtering
const allItems = await ctx.db.query("items").collect();
const activeItems = allItems.filter(item => item.status === "active");

// GOOD - Index-based query, filters at database level
const activeItems = await ctx.db
  .query("items")
  .withIndex("by_status", (q) => q.eq("status", "active"))
  .collect();
```

### Bandwidth Audit Checklist

When reviewing Convex code, check for these patterns:

| Pattern | Problem | Fix |
|---------|---------|-----|
| `.query("table").collect()` | Full table scan | Add `.withIndex()` |
| `.collect()` + `.filter()` in JS | Fetches all, filters in JS | Use `.withIndex()` or server `.filter()` |
| `.filter()` without `.withIndex()` | No index = full scan | Add index to schema |
| Cron calling query every N seconds | N × full_scans/day | Ensure query uses index |
| `.find()` after `.collect()` | Full scan for single item | Use `.withIndex().first()` |

### Index Design Principles

1. **Create indexes for frequently queried fields**
```typescript
// Schema
defineTable({...})
  .index("by_status", ["status"])
  .index("by_user", ["userId"])
  .index("by_user_status", ["userId", "status"]) // Compound index
```

2. **Compound indexes for multi-field queries**
```typescript
// If you often query by userId AND status, create compound index
.withIndex("by_user_status", (q) =>
  q.eq("userId", userId).eq("status", "active")
)
```

3. **Order matters in compound indexes**
- Put equality fields first, range fields last
- `["userId", "createdAt"]` enables `eq(userId).gte(createdAt)`
- But NOT `eq(createdAt).eq(userId)`

### Server-Side vs JS Filtering

```typescript
// Server-side filter (efficient) - runs on Convex servers
const items = await ctx.db
  .query("items")
  .withIndex("by_user", (q) => q.eq("userId", userId))
  .filter((q) => q.eq(q.field("status"), "active")) // Server filter
  .collect();

// JS filter (inefficient) - fetches all, filters in your code
const items = await ctx.db
  .query("items")
  .withIndex("by_user", (q) => q.eq("userId", userId))
  .collect();
return items.filter(i => i.status === "active"); // JS filter
```

### High-Frequency Query Patterns

For queries called frequently (crons, polling, real-time updates):

```typescript
// BAD - Called every 10 seconds, scans entire table
export const getAllActiveUsers = query({
  handler: async (ctx) => {
    const all = await ctx.db.query("subscriptions").collect();
    return all.filter(s => s.status === "active").map(s => s.userId);
  },
});

// GOOD - Uses index, only fetches active subscriptions
export const getAllActiveUsers = query({
  handler: async (ctx) => {
    const active = await ctx.db
      .query("subscriptions")
      .withIndex("by_status", (q) => q.eq("status", "active"))
      .collect();
    return [...new Set(active.map(s => s.userId))];
  },
});
```

### Bandwidth Calculation

Estimate bandwidth impact:
```
Daily bandwidth = (records_fetched × avg_record_size) × calls_per_day

Example:
- 100 records × 500 bytes = 50KB per call
- Called every 10 seconds = 8,640 calls/day
- Total: 50KB × 8,640 = 432 GB/day (!!)
```

### Performance Audit Process

When investigating bandwidth issues:

1. **Identify high-frequency queries** - Check crons.ts and polling intervals
2. **Search for anti-patterns**:
   ```bash
   grep -n "\.collect()" convex/*.ts
   grep -n "\.filter(" convex/*.ts
   ```
3. **Check each query uses appropriate index**
4. **Verify schema has required indexes**
5. **Monitor Convex dashboard** → Team Settings → Project Usage

### Quick Fixes

| Before | After |
|--------|-------|
| `ctx.db.query("t").collect()` then `.find()` | `ctx.db.query("t").withIndex("by_x").first()` |
| `ctx.db.query("t").filter(...)` | Add index, use `.withIndex()` |
| `.collect()` + JS `.filter()` | `.withIndex()` + server `.filter()` |
| Full scan for count | Add counter field or use index |

### References

- [Convex Indexes Documentation](https://docs.convex.dev/database/reading-data/indexes/)
- [Convex Billing](https://docs.convex.dev/production/billing)

---

## Common Patterns

### Paginated Queries
```typescript
export const list = query({
  args: {
    paginationOpts: paginationOptsValidator,
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("tableName")
      .order("desc")
      .paginate(args.paginationOpts);
  },
});
```

### Scheduled Functions
```typescript
import { cronJobs } from "convex/server";

const crons = cronJobs();

crons.interval(
  "cleanup old data",
  { hours: 24 },
  async (ctx) => {
    // Cleanup logic
  }
);

export default crons;
```

## Testing Convex Functions

- Test queries and mutations locally using `npx convex dev`
- Use the Convex dashboard to inspect data and test functions
- Write integration tests that interact with your Convex deployment

## References

- [Convex Documentation](https://docs.convex.dev/)
- [Convex TypeScript API](https://docs.convex.dev/api/modules)
- [Convex Best Practices](https://docs.convex.dev/production/best-practices)
