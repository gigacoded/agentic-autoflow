# Frontend Development - React, Next.js, Tailwind CSS

You are working with a modern React frontend using Next.js and Tailwind CSS. This skill provides guidelines for developing frontend components and features.

## Tech Stack

- **React 18+**: Component-based UI library
- **Next.js 14+**: React framework with App Router
- **Tailwind CSS**: Utility-first CSS framework
- **TypeScript**: Type-safe JavaScript

## Core Principles

1. **Component Composition**: Build UIs from small, reusable components
2. **Type Safety**: Use TypeScript for all components and logic
3. **Responsive Design**: Mobile-first approach with Tailwind
4. **Accessibility**: Follow WCAG guidelines (semantic HTML, ARIA labels, keyboard navigation)
5. **Performance**: Optimize bundle size, lazy loading, image optimization

## Next.js App Router Patterns

### File-Based Routing

```
app/
├── page.tsx              # Home page (/)
├── layout.tsx            # Root layout
├── loading.tsx           # Loading UI
├── error.tsx             # Error UI
├── not-found.tsx         # 404 page
├── dashboard/
│   ├── page.tsx          # /dashboard
│   └── layout.tsx        # Dashboard layout
└── api/
    └── route.ts          # API routes
```

### Server vs Client Components

**Server Components (default):**
```typescript
// app/posts/page.tsx
import { convex } from "@/lib/convex";
import { api } from "@/convex/_generated/api";

export default async function PostsPage() {
  const posts = await convex.query(api.posts.list);

  return (
    <div>
      {posts.map(post => (
        <PostCard key={post._id} post={post} />
      ))}
    </div>
  );
}
```

**Client Components (use "use client"):**
```typescript
"use client";

import { useState } from "react";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function CreatePostForm() {
  const [title, setTitle] = useState("");
  const createPost = useMutation(api.posts.create);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await createPost({ title });
    setTitle("");
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Post title"
      />
      <button type="submit">Create</button>
    </form>
  );
}
```

## React Component Patterns

### Functional Components with TypeScript

```typescript
interface ButtonProps {
  variant?: "primary" | "secondary" | "danger";
  size?: "sm" | "md" | "lg";
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  className?: string;
}

export function Button({
  variant = "primary",
  size = "md",
  children,
  onClick,
  disabled = false,
  className = "",
}: ButtonProps) {
  const baseStyles = "rounded font-medium transition-colors";
  const variantStyles = {
    primary: "bg-blue-600 text-white hover:bg-blue-700",
    secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300",
    danger: "bg-red-600 text-white hover:bg-red-700",
  };
  const sizeStyles = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-6 py-3 text-lg",
  };

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className} ${
        disabled ? "opacity-50 cursor-not-allowed" : ""
      }`}
    >
      {children}
    </button>
  );
}
```

### Custom Hooks

```typescript
// hooks/useDebounce.ts
import { useEffect, useState } from "react";

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}
```

## Tailwind CSS Patterns

### Responsive Design

```typescript
<div className="
  flex flex-col           // Mobile: column
  md:flex-row            // Tablet+: row
  gap-4                  // 1rem gap
  p-4 md:p-6 lg:p-8     // Responsive padding
">
  <div className="w-full md:w-1/2 lg:w-1/3">
    {/* Content */}
  </div>
</div>
```

### Custom Component Variants

```typescript
import { cva, type VariantProps } from "class-variance-authority";

const cardVariants = cva(
  "rounded-lg shadow-md p-6",
  {
    variants: {
      variant: {
        default: "bg-white",
        dark: "bg-gray-900 text-white",
        outline: "bg-transparent border-2 border-gray-300",
      },
      size: {
        sm: "p-4",
        md: "p-6",
        lg: "p-8",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "md",
    },
  }
);

interface CardProps extends VariantProps<typeof cardVariants> {
  children: React.ReactNode;
  className?: string;
}

export function Card({ variant, size, children, className }: CardProps) {
  return (
    <div className={cardVariants({ variant, size, className })}>
      {children}
    </div>
  );
}
```

## Convex Integration

### Using Queries in Client Components

```typescript
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function PostsList() {
  const posts = useQuery(api.posts.list);

  if (!posts) return <div>Loading...</div>;

  return (
    <div className="space-y-4">
      {posts.map(post => (
        <PostCard key={post._id} post={post} />
      ))}
    </div>
  );
}
```

### Using Mutations

```typescript
"use client";

import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useState } from "react";

export function LikeButton({ postId }: { postId: Id<"posts"> }) {
  const [isLiking, setIsLiking] = useState(false);
  const likePost = useMutation(api.posts.like);

  const handleLike = async () => {
    setIsLiking(true);
    try {
      await likePost({ postId });
    } finally {
      setIsLiking(false);
    }
  };

  return (
    <button
      onClick={handleLike}
      disabled={isLiking}
      className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
    >
      {isLiking ? "Liking..." : "Like"}
    </button>
  );
}
```

## Form Handling

### React Hook Form Pattern

```typescript
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

const formSchema = z.object({
  title: z.string().min(3, "Title must be at least 3 characters"),
  content: z.string().min(10, "Content must be at least 10 characters"),
});

type FormData = z.infer<typeof formSchema>;

export function CreatePostForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const createPost = useMutation(api.posts.create);

  const onSubmit = async (data: FormData) => {
    await createPost(data);
    reset();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="title" className="block text-sm font-medium mb-1">
          Title
        </label>
        <input
          {...register("title")}
          id="title"
          className="w-full px-3 py-2 border rounded-md"
        />
        {errors.title && (
          <p className="text-red-600 text-sm mt-1">{errors.title.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="content" className="block text-sm font-medium mb-1">
          Content
        </label>
        <textarea
          {...register("content")}
          id="content"
          rows={4}
          className="w-full px-3 py-2 border rounded-md"
        />
        {errors.content && (
          <p className="text-red-600 text-sm mt-1">{errors.content.message}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
      >
        {isSubmitting ? "Creating..." : "Create Post"}
      </button>
    </form>
  );
}
```

## Best Practices

1. **Accessibility**
   - Use semantic HTML (`<button>`, `<nav>`, `<main>`, etc.)
   - Add ARIA labels where needed
   - Ensure keyboard navigation works
   - Test with screen readers

2. **Performance**
   - Use Next.js Image component for images
   - Lazy load components with `React.lazy()` or `dynamic()`
   - Memoize expensive computations with `useMemo`
   - Avoid unnecessary re-renders with `React.memo`

3. **Code Organization**
   - Keep components small and focused
   - Extract reusable logic into custom hooks
   - Use barrel exports (index.ts) for cleaner imports
   - Separate business logic from UI components

4. **Styling**
   - Use Tailwind's utility classes for styling
   - Extract repeated class combinations into components
   - Use `@apply` sparingly (prefer components)
   - Follow a consistent spacing scale

5. **Type Safety**
   - Define interfaces for all component props
   - Use Convex-generated types for data
   - Avoid `any` type
   - Use discriminated unions for variant props

## File Structure

```
app/
├── (auth)/              # Route groups
│   ├── login/
│   └── signup/
├── dashboard/
│   ├── page.tsx
│   └── layout.tsx
├── layout.tsx
└── page.tsx

components/
├── ui/                  # Reusable UI components
│   ├── button.tsx
│   ├── card.tsx
│   └── input.tsx
├── forms/               # Form components
└── layouts/             # Layout components

hooks/                   # Custom React hooks
lib/                     # Utilities and config
public/                  # Static assets
```

## References

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Convex React Documentation](https://docs.convex.dev/client/react)
