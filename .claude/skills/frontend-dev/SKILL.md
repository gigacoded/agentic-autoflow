# Frontend Development - React, Next.js, Tailwind CSS, shadcn/ui

You are working with a modern React frontend using Next.js, Tailwind CSS, and shadcn/ui components. This skill provides guidelines for developing frontend components and features.

## Tech Stack

- **React 18+**: Component-based UI library
- **Next.js 14+**: React framework with App Router
- **Tailwind CSS**: Utility-first CSS framework
- **shadcn/ui**: Beautifully designed components built with Radix UI
- **TypeScript**: Type-safe JavaScript

## shadcn/ui Integration

**IMPORTANT**: This project uses shadcn/ui for UI components. Always prefer shadcn/ui components over building custom components from scratch.

### Installing shadcn/ui Components

```bash
# Initialize shadcn/ui (if not already done)
npx shadcn@latest init

# Add individual components as needed
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog
npx shadcn@latest add form
npx shadcn@latest add input
npx shadcn@latest add select
npx shadcn@latest add table
npx shadcn@latest add dropdown-menu
npx shadcn@latest add sheet
npx shadcn@latest add toast
```

### Available shadcn/ui Components

Common components to use:
- **Button**: Primary UI actions
- **Card**: Container for content
- **Dialog/Sheet**: Modals and side panels
- **Form**: Form handling with React Hook Form + Zod
- **Input/Textarea**: Form inputs
- **Select/Combobox**: Dropdowns
- **Table**: Data tables
- **Toast**: Notifications
- **Dropdown Menu**: Context menus
- **Tabs**: Tabbed interfaces
- **Badge**: Status indicators
- **Avatar**: User avatars
- **Skeleton**: Loading states

### shadcn/ui File Location

Components are installed in `components/ui/` and can be customized:

```
components/
├── ui/                  # shadcn/ui components (customizable)
│   ├── button.tsx
│   ├── card.tsx
│   ├── dialog.tsx
│   ├── form.tsx
│   └── ...
└── custom/              # Your custom components
```

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

## React Component Patterns with shadcn/ui

### Using shadcn/ui Components

**Button Component:**
```typescript
import { Button } from "@/components/ui/button";

export function Example() {
  return (
    <div className="space-x-2">
      {/* Variants */}
      <Button variant="default">Default</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="destructive">Destructive</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="link">Link</Button>

      {/* Sizes */}
      <Button size="sm">Small</Button>
      <Button size="default">Default</Button>
      <Button size="lg">Large</Button>
      <Button size="icon">
        <IconComponent />
      </Button>

      {/* States */}
      <Button disabled>Disabled</Button>
      <Button loading>Loading</Button>
    </div>
  );
}
```

**Card Component:**
```typescript
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export function PostCard({ post }: { post: Post }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{post.title}</CardTitle>
        <CardDescription>{post.author}</CardDescription>
      </CardHeader>
      <CardContent>
        <p>{post.content}</p>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="outline">Edit</Button>
        <Button variant="destructive">Delete</Button>
      </CardFooter>
    </Card>
  );
}
```

**Dialog/Modal Component:**
```typescript
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

export function ConfirmDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="destructive">Delete Post</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Are you sure?</DialogTitle>
          <DialogDescription>
            This action cannot be undone. This will permanently delete the post.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline">Cancel</Button>
          <Button variant="destructive">Delete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
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

## Form Handling with shadcn/ui

### shadcn/ui Form Component

**IMPORTANT**: Always use shadcn/ui Form components for forms. They integrate React Hook Form + Zod validation with accessible markup.

```typescript
"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { toast } from "@/components/ui/use-toast";

const formSchema = z.object({
  title: z.string().min(3, "Title must be at least 3 characters"),
  content: z.string().min(10, "Content must be at least 10 characters"),
});

export function CreatePostForm() {
  const createPost = useMutation(api.posts.create);

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: "",
      content: "",
    },
  });

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      await createPost(values);
      toast({
        title: "Success",
        description: "Post created successfully",
      });
      form.reset();
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to create post",
        variant: "destructive",
      });
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="title"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Title</FormLabel>
              <FormControl>
                <Input placeholder="Enter post title" {...field} />
              </FormControl>
              <FormDescription>
                This is the title of your post.
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="content"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Content</FormLabel>
              <FormControl>
                <Textarea
                  placeholder="Write your content here"
                  className="min-h-[100px]"
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Creating..." : "Create Post"}
        </Button>
      </form>
    </Form>
  );
}
```

### Form with Select and Multiple Fields

```typescript
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const formSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  category: z.string(),
  bio: z.string().optional(),
});

export function UserProfileForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="category"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Category</FormLabel>
              <Select onValueChange={field.onChange} defaultValue={field.value}>
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a category" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="tech">Technology</SelectItem>
                  <SelectItem value="design">Design</SelectItem>
                  <SelectItem value="business">Business</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit">Submit</Button>
      </form>
    </Form>
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
