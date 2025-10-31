# Convex Backend Development

**Auto-activates when**: Working with Convex queries, mutations, actions, or files in `/convex` directory

## Overview

Comprehensive patterns for Convex backend development including queries, mutations, actions, authentication, error handling, and database operations.

## Core Principles

1. **Queries are read-only** - Never modify data in queries
2. **Mutations are transactional** - All database operations succeed or fail together
3. **Actions for external APIs** - Use actions for non-deterministic operations
4. **Type safety everywhere** - Full TypeScript types for all functions
5. **Authentication first** - Always verify auth before operations

## Function Types

### Queries (Read-Only)

**When to use**: Fetching data, no modifications

```typescript
import { query } from "./_generated/server";
import { v } from "convex/values";

export const getQuote = query({
  args: { quoteId: v.id("quotes") },
  handler: async (ctx, args) => {
    // Check authentication
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Fetch data
    const quote = await ctx.db.get(args.quoteId);
    if (!quote) {
      throw new Error("Quote not found");
    }

    // Check authorization
    if (quote.userId !== identity.subject) {
      throw new Error("Not authorized to view this quote");
    }

    return quote;
  },
});
```

**Best Practices**:
- ✅ Return null for "not found" when appropriate
- ✅ Filter sensitive fields before returning
- ✅ Use indexes for efficient queries
- ❌ Never modify data (use mutations)
- ❌ Never call external APIs (use actions)

### Mutations (Write Operations)

**When to use**: Creating, updating, or deleting data

```typescript
import { mutation } from "./_generated/server";
import { v } from "convex/values";

export const createQuote = mutation({
  args: {
    clientName: v.string(),
    items: v.array(v.object({
      description: v.string(),
      quantity: v.number(),
      price: v.number(),
    })),
  },
  handler: async (ctx, args) => {
    // Verify authentication
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Validate input
    if (args.items.length === 0) {
      throw new Error("Quote must have at least one item");
    }

    // Calculate total
    const total = args.items.reduce(
      (sum, item) => sum + item.quantity * item.price,
      0
    );

    // Create quote
    const quoteId = await ctx.db.insert("quotes", {
      userId: identity.subject,
      clientName: args.clientName,
      items: args.items,
      total,
      status: "draft",
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });

    return quoteId;
  },
});
```

**Best Practices**:
- ✅ Validate all input
- ✅ Check authentication and authorization
- ✅ Use transactions (automatic in mutations)
- ✅ Update `updatedAt` timestamps
- ❌ Don't call external APIs (use actions instead)

### Actions (External Operations)

**When to use**: Calling external APIs, sending emails, non-deterministic operations

```typescript
import { action } from "./_generated/server";
import { v } from "convex/values";
import { api } from "./_generated/api";

export const sendQuoteEmail = action({
  args: { quoteId: v.id("quotes") },
  handler: async (ctx, args) => {
    // Verify authentication
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Fetch quote via query
    const quote = await ctx.runQuery(api.quotes.getQuote, {
      quoteId: args.quoteId,
    });

    // Call external email service
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        to: quote.clientEmail,
        subject: `Quote #${quote.number}`,
        html: generateQuoteEmail(quote),
      }),
    });

    if (!response.ok) {
      throw new Error("Failed to send email");
    }

    // Update quote status via mutation
    await ctx.runMutation(api.quotes.updateQuoteStatus, {
      quoteId: args.quoteId,
      status: "sent",
    });

    return { success: true };
  },
});
```

**Best Practices**:
- ✅ Use `ctx.runQuery` and `ctx.runMutation` for database operations
- ✅ Handle external API errors gracefully
- ✅ Use environment variables for API keys
- ✅ Log errors for debugging
- ❌ Don't access `ctx.db` directly (use queries/mutations)

## Authentication Patterns

### Checking Authentication

```typescript
// Get identity (returns null if not authenticated)
const identity = await ctx.auth.getUserIdentity();

// Require authentication
if (!identity) {
  throw new Error("Not authenticated");
}

// User ID is in identity.subject
const userId = identity.subject;
```

### Role-Based Authorization

```typescript
export const deleteUser = mutation({
  args: { userId: v.id("users") },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Check if user is admin
    const currentUser = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .unique();

    if (!currentUser || currentUser.role !== "admin") {
      throw new Error("Not authorized: Admin role required");
    }

    // Proceed with deletion
    await ctx.db.delete(args.userId);
  },
});
```

### Resource Ownership

```typescript
// Verify user owns the resource
const quote = await ctx.db.get(args.quoteId);
if (quote.userId !== identity.subject) {
  throw new Error("Not authorized to modify this quote");
}
```

## Database Operations

### Inserting Documents

```typescript
const id = await ctx.db.insert("tableName", {
  field1: value1,
  field2: value2,
  createdAt: Date.now(),
});
```

### Querying Documents

```typescript
// Get by ID
const doc = await ctx.db.get(docId);

// Query with index
const docs = await ctx.db
  .query("tableName")
  .withIndex("by_user_id", (q) => q.eq("userId", userId))
  .collect();

// Query with filtering
const activeDocs = await ctx.db
  .query("tableName")
  .filter((q) => q.eq(q.field("status"), "active"))
  .collect();

// Paginated query
const results = await ctx.db
  .query("tableName")
  .order("desc")
  .paginate(args.paginationOpts);
```

### Updating Documents

```typescript
await ctx.db.patch(docId, {
  status: "completed",
  updatedAt: Date.now(),
});
```

### Deleting Documents

```typescript
await ctx.db.delete(docId);
```

## Error Handling

### Validation Errors

```typescript
// Validate input
if (!args.email.includes("@")) {
  throw new Error("Invalid email address");
}

if (args.quantity < 1) {
  throw new Error("Quantity must be at least 1");
}
```

### Not Found Errors

```typescript
const doc = await ctx.db.get(args.docId);
if (!doc) {
  throw new Error(`Document ${args.docId} not found`);
}
```

### Authorization Errors

```typescript
if (!identity) {
  throw new Error("Not authenticated");
}

if (doc.userId !== identity.subject) {
  throw new Error("Not authorized to access this resource");
}
```

### External API Errors

```typescript
try {
  const response = await fetch(apiUrl, options);
  if (!response.ok) {
    const error = await response.json();
    throw new Error(`API error: ${error.message}`);
  }
} catch (error) {
  console.error("External API failed:", error);
  throw new Error("Failed to complete operation");
}
```

## Schema Patterns

### Define Schema

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  quotes: defineTable({
    userId: v.string(),
    clientName: v.string(),
    items: v.array(v.object({
      description: v.string(),
      quantity: v.number(),
      price: v.number(),
    })),
    total: v.number(),
    status: v.union(
      v.literal("draft"),
      v.literal("sent"),
      v.literal("accepted"),
      v.literal("rejected")
    ),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_user_id", ["userId"])
    .index("by_status", ["status"])
    .index("by_created_at", ["createdAt"]),

  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    role: v.union(v.literal("user"), v.literal("admin")),
  })
    .index("by_clerk_id", ["clerkId"])
    .index("by_email", ["email"]),
});
```

**Best Practices**:
- ✅ Define all indexes you'll query on
- ✅ Use `v.union` for enum-like fields
- ✅ Include timestamps (createdAt, updatedAt)
- ✅ Use descriptive index names

## Testing Convex Functions

### Using Convex MCP (Recommended)

```bash
# Install Convex MCP
claude mcp add convex "npx convex mcp start"

# In Claude Code session
# "Test the createQuote mutation with sample data"
# Claude will use mcp__convex__run to execute function
```

### Manual Testing

```bash
# Deploy to dev
npx convex dev

# Run function via dashboard
# Or use npx convex run
npx convex run quotes:createQuote \
  --arg clientName="Test Client" \
  --arg items='[{"description":"Item","quantity":1,"price":100}]'
```

## Common Patterns

### Pagination

```typescript
export const listQuotes = query({
  args: { paginationOpts: paginationOptsValidator },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    return await ctx.db
      .query("quotes")
      .withIndex("by_user_id", (q) => q.eq("userId", identity.subject))
      .order("desc")
      .paginate(args.paginationOpts);
  },
});
```

### Aggregation

```typescript
export const getQuoteStats = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    const quotes = await ctx.db
      .query("quotes")
      .withIndex("by_user_id", (q) => q.eq("userId", identity.subject))
      .collect();

    return {
      total: quotes.length,
      draft: quotes.filter((q) => q.status === "draft").length,
      sent: quotes.filter((q) => q.status === "sent").length,
      accepted: quotes.filter((q) => q.status === "accepted").length,
      totalValue: quotes.reduce((sum, q) => sum + q.total, 0),
    };
  },
});
```

### File Upload (Actions)

```typescript
export const uploadFile = action({
  args: { file: v.any() },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // Generate upload URL
    const uploadUrl = await ctx.storage.generateUploadUrl();

    // Upload file
    const response = await fetch(uploadUrl, {
      method: "POST",
      body: args.file,
    });

    if (!response.ok) {
      throw new Error("File upload failed");
    }

    const { storageId } = await response.json();

    // Save file reference
    await ctx.runMutation(api.files.create, {
      storageId,
      fileName: args.file.name,
      fileType: args.file.type,
    });

    return storageId;
  },
});
```

## Quick Reference

**Query data**:
```typescript
const doc = await ctx.db.get(id);
const docs = await ctx.db.query("table").collect();
```

**Insert**:
```typescript
const id = await ctx.db.insert("table", { ...data });
```

**Update**:
```typescript
await ctx.db.patch(id, { field: newValue });
```

**Delete**:
```typescript
await ctx.db.delete(id);
```

**Auth check**:
```typescript
const identity = await ctx.auth.getUserIdentity();
if (!identity) throw new Error("Not authenticated");
```

**Run query from action**:
```typescript
await ctx.runQuery(api.module.functionName, args);
```

**Run mutation from action**:
```typescript
await ctx.runMutation(api.module.functionName, args);
```

## Related Documentation

- [Convex Documentation](https://docs.convex.dev)
- [Convex MCP](https://github.com/get-convex/convex-mcp)
- Related skill: `nextjs-frontend-dev` for frontend integration
- Related skill: `e2e-testing-framework` for testing
