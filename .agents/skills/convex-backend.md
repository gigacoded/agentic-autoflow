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
