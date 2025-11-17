# Error Handling Patterns

These rules apply to ALL error handling across the codebase.

## Backend (Convex)

**Always throw descriptive errors**:
```typescript
// Good
export const getUser = query({
  handler: async (ctx, { userId }) => {
    const user = await ctx.db.get(userId);
    if (!user) {
      throw new Error(`User not found: ${userId}`);
    }
    return user;
  },
});

// Bad
if (!user) {
  throw new Error("Error");
}
```

**Validate inputs early**:
```typescript
export const createPost = mutation({
  handler: async (ctx, { title, content }) => {
    // Validate first
    if (!title || title.length < 3) {
      throw new Error("Title must be at least 3 characters");
    }

    // Then proceed
    const postId = await ctx.db.insert("posts", { title, content });
    return postId;
  },
});
```

## Frontend (React)

**Use Error Boundaries**:
```typescript
// app/error.tsx
"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

**Handle async errors**:
```typescript
"use client";

import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { toast } from "@/components/ui/use-toast";

export function CreateForm() {
  const create = useMutation(api.items.create);

  const handleSubmit = async (data: FormData) => {
    try {
      await create(data);
      toast({
        title: "Success",
        description: "Item created",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Unknown error",
        variant: "destructive",
      });
    }
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

## Form Validation

**Use Zod for validation**:
```typescript
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";

const schema = z.object({
  email: z.string().email("Invalid email"),
  age: z.number().min(18, "Must be 18+"),
});

export function SignupForm() {
  const form = useForm({
    resolver: zodResolver(schema),
  });

  // Errors handled automatically by react-hook-form
  return <Form {...form}>...</Form>;
}
```

## Network Errors

**Provide user-friendly messages**:
```typescript
try {
  await fetch('/api/data');
} catch (error) {
  // Good
  toast({
    title: "Connection Error",
    description: "Please check your internet connection",
  });

  // Bad
  console.log(error); // Silent failure
}
```

## Logging

**Log errors for debugging**:
```typescript
try {
  await dangerousOperation();
} catch (error) {
  console.error('Operation failed:', error);
  // Show user-friendly message
  toast({ title: "Operation failed", variant: "destructive" });
  // Re-throw if needed
  throw error;
}
```

## Never Swallow Errors

**Bad**:
```typescript
try {
  await importantOperation();
} catch (error) {
  // Silently ignoring
}
```

**Good**:
```typescript
try {
  await importantOperation();
} catch (error) {
  console.error('Important operation failed:', error);
  notifyUser(error);
  // Or re-throw
  throw error;
}
```
