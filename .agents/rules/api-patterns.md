# API Design Patterns

These rules apply to ALL backend API development.

## REST Conventions

**Endpoint Naming**:
- Use plural nouns: `/api/users`, not `/api/user`
- Use kebab-case: `/api/user-profiles`, not `/api/userProfiles`
- Nest resources: `/api/users/{id}/posts`

**HTTP Methods**:
- `GET` - Retrieve resources
- `POST` - Create resources
- `PUT`/`PATCH` - Update resources
- `DELETE` - Remove resources

## Convex API Patterns

**Function Naming**:
```typescript
// Good
export const getUserById = query({...});
export const createUser = mutation({...});
export const sendWelcomeEmail = action({...});

// Bad
export const get = query({...});  // Too generic
export const user = query({...}); // Unclear action
```

**Input Validation**:
```typescript
// Always validate inputs with Convex validators
import { v } from "convex/values";

export const createUser = mutation({
  args: {
    email: v.string(),
    name: v.string(),
    age: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    // Additional validation
    if (!args.email.includes('@')) {
      throw new Error("Invalid email format");
    }
    // ...
  },
});
```

## Error Handling

**Always throw meaningful errors**:
```typescript
// Good
if (!user) {
  throw new Error(`User not found: ${userId}`);
}

// Bad
if (!user) {
  throw new Error("Error");
}
```

**Error Response Format**:
```typescript
{
  error: {
    message: "User not found",
    code: "USER_NOT_FOUND",
    details: { userId: "123" }
  }
}
```

## Authentication

**Always check auth in mutations**:
```typescript
export const deletePost = mutation({
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }
    // ...
  },
});
```

## Response Structure

**Consistent response shapes**:
```typescript
// List endpoints - always return arrays
export const listUsers = query({
  handler: async (ctx) => {
    return await ctx.db.query("users").collect(); // Returns array
  },
});

// Single resource - can return null
export const getUser = query({
  handler: async (ctx, { id }) => {
    return await ctx.db.get(id); // Returns object or null
  },
});
```
