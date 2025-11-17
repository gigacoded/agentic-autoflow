# Convex Backend Patterns

## Common Use Cases

### User Management

```typescript
// convex/users.ts
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const createUser = mutation({
  args: {
    name: v.string(),
    email: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");

    return await ctx.db.insert("users", {
      name: args.name,
      email: args.email,
      tokenIdentifier: identity.tokenIdentifier,
    });
  },
});

export const getCurrentUser = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return null;

    return await ctx.db
      .query("users")
      .withIndex("by_token", (q) =>
        q.eq("tokenIdentifier", identity.tokenIdentifier)
      )
      .unique();
  },
});
```

### Data Relationships

```typescript
// Fetching related data
export const getPostWithAuthor = query({
  args: { postId: v.id("posts") },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.postId);
    if (!post) return null;

    const author = await ctx.db.get(post.authorId);

    return {
      ...post,
      author,
    };
  },
});
```

### Optimistic Updates Pattern

```typescript
// Frontend pattern for optimistic updates
const mutation = useMutation(api.items.create);

const handleCreate = async (data) => {
  // Optimistically add to UI
  const optimisticId = generateId();
  setItems([...items, { _id: optimisticId, ...data }]);

  try {
    const realId = await mutation(data);
    // Replace optimistic with real
    setItems(items.map(i =>
      i._id === optimisticId ? { ...i, _id: realId } : i
    ));
  } catch (error) {
    // Rollback on error
    setItems(items.filter(i => i._id !== optimisticId));
  }
};
```

### Complex Queries

```typescript
export const searchAndFilter = query({
  args: {
    searchTerm: v.optional(v.string()),
    category: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("items");

    // Use search index if search term provided
    if (args.searchTerm) {
      query = query
        .withSearchIndex("search_name", (q) =>
          q.search("name", args.searchTerm)
        );
    }

    // Apply filters
    let results = await query.collect();

    if (args.category) {
      results = results.filter(item => item.category === args.category);
    }

    // Apply limit
    if (args.limit) {
      results = results.slice(0, args.limit);
    }

    return results;
  },
});
```

### File Upload Pattern

```typescript
import { action } from "./_generated/server";
import { v } from "convex/values";

export const generateUploadUrl = mutation({
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

export const saveFile = mutation({
  args: {
    storageId: v.id("_storage"),
    name: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("files", {
      storageId: args.storageId,
      name: args.name,
      uploadedAt: Date.now(),
    });
  },
});

export const getFileUrl = query({
  args: { storageId: v.id("_storage") },
  handler: async (ctx, args) => {
    return await ctx.storage.getUrl(args.storageId);
  },
});
```

## Error Handling Patterns

### Validation Errors

```typescript
export const update = mutation({
  args: {
    id: v.id("items"),
    name: v.string(),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db.get(args.id);
    if (!existing) {
      throw new Error("Item not found");
    }

    if (args.name.length < 3) {
      throw new Error("Name must be at least 3 characters");
    }

    await ctx.db.patch(args.id, { name: args.name });
  },
});
```

### Permission Checks

```typescript
async function requireUser(ctx: QueryCtx | MutationCtx) {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) {
    throw new Error("Authentication required");
  }

  const user = await ctx.db
    .query("users")
    .withIndex("by_token", (q) =>
      q.eq("tokenIdentifier", identity.tokenIdentifier)
    )
    .unique();

  if (!user) {
    throw new Error("User not found");
  }

  return user;
}

export const deletePost = mutation({
  args: { postId: v.id("posts") },
  handler: async (ctx, args) => {
    const user = await requireUser(ctx);
    const post = await ctx.db.get(args.postId);

    if (!post) throw new Error("Post not found");
    if (post.authorId !== user._id) {
      throw new Error("Not authorized to delete this post");
    }

    await ctx.db.delete(args.postId);
  },
});
```
