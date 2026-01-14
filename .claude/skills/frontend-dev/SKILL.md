# Frontend Development - React, TanStack Start, Tailwind CSS, shadcn/ui

You are working with a modern React frontend using TanStack Start, Tailwind CSS, and shadcn/ui components. This skill provides guidelines for developing frontend components and features.

## Tech Stack

- **React 18+**: Component-based UI library
- **TanStack Start**: Full-stack React framework (Vite-powered)
- **TanStack Router**: Type-safe file-based routing
- **TanStack Query**: Data fetching and caching
- **Tailwind CSS**: Utility-first CSS framework
- **shadcn/ui**: Beautifully designed components built with Radix UI
- **TypeScript**: Type-safe JavaScript

## TanStack Start Overview

TanStack Start is a full-stack React framework built on Vite, featuring:
- Full-document SSR and streaming
- Server functions (`createServerFn`)
- File-based routing with type safety
- Deploy anywhere (no vendor lock-in)

## Project Structure

```
├── src/
│   ├── routes/
│   │   ├── __root.tsx        # Root layout (required)
│   │   ├── index.tsx         # Home page (/)
│   │   ├── about.tsx         # /about
│   │   ├── posts/
│   │   │   ├── index.tsx     # /posts
│   │   │   └── $postId.tsx   # /posts/$postId (dynamic)
│   │   └── _auth/            # Pathless layout group
│   │       ├── login.tsx
│   │       └── signup.tsx
│   ├── components/
│   │   ├── ui/               # shadcn/ui components
│   │   └── custom/           # Custom components
│   ├── utils/
│   │   ├── *.functions.ts    # Server function wrappers
│   │   ├── *.server.ts       # Server-only helpers
│   │   └── schemas.ts        # Shared validation schemas
│   ├── router.tsx            # Router configuration
│   └── routeTree.gen.ts      # Auto-generated route tree
├── app.config.ts             # TanStack Start config
├── vite.config.ts
├── package.json
└── tsconfig.json
```

## File-Based Routing

### Route File Naming Conventions

| File Pattern | Route Path | Description |
|--------------|------------|-------------|
| `__root.tsx` | - | Root layout (required) |
| `index.tsx` | `/` | Index route |
| `about.tsx` | `/about` | Static route |
| `posts/$postId.tsx` | `/posts/:postId` | Dynamic parameter |
| `_layout/` | - | Pathless layout group |
| `(group)/` | - | Route group (organizational) |

### Root Route (`__root.tsx`)

```typescript
// src/routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { HeadContent, Scripts } from '@tanstack/react-start'

export const Route = createRootRoute({
  component: RootComponent,
})

function RootComponent() {
  return (
    <html lang="en">
      <head>
        <HeadContent />
      </head>
      <body>
        <div className="min-h-screen">
          <Outlet />
        </div>
        <Scripts />
      </body>
    </html>
  )
}
```

### Basic Route with Loader

```typescript
// src/routes/posts/index.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPosts } from '@/utils/posts.functions'

export const Route = createFileRoute('/posts/')({
  component: PostsPage,
  loader: () => getPosts(),
})

function PostsPage() {
  const posts = Route.useLoaderData()

  return (
    <div className="space-y-4">
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

### Dynamic Route with Parameters

```typescript
// src/routes/posts/$postId.tsx
import { createFileRoute } from '@tanstack/react-router'
import { getPost } from '@/utils/posts.functions'

export const Route = createFileRoute('/posts/$postId')({
  component: PostPage,
  loader: ({ params }) => getPost(params.postId),
})

function PostPage() {
  const post = Route.useLoaderData()

  return (
    <article>
      <h1 className="text-3xl font-bold">{post.title}</h1>
      <p>{post.content}</p>
    </article>
  )
}
```

## Server Functions

### Creating Server Functions

Server functions run **only on the server** and are the secure way to handle database operations, secrets, and sensitive logic.

```typescript
// src/utils/posts.functions.ts
import { createServerFn } from '@tanstack/react-start'
import { z } from 'zod'
import { db } from './db.server'

// GET - Fetch data
export const getPosts = createServerFn({
  method: 'GET',
}).handler(async () => {
  return db.posts.findMany()
})

// GET with parameters
export const getPost = createServerFn({
  method: 'GET',
})
  .validator(z.string())
  .handler(async ({ data: postId }) => {
    return db.posts.findUnique({ where: { id: postId } })
  })

// POST - Mutations with validation
const CreatePostSchema = z.object({
  title: z.string().min(3),
  content: z.string().min(10),
})

export const createPost = createServerFn({
  method: 'POST',
})
  .validator(CreatePostSchema)
  .handler(async ({ data }) => {
    return db.posts.create({ data })
  })
```

### Using Server Functions in Components

```typescript
"use client"

import { useRouter } from '@tanstack/react-router'
import { createPost } from '@/utils/posts.functions'

export function CreatePostForm() {
  const router = useRouter()
  const [isPending, setIsPending] = useState(false)

  const handleSubmit = async (formData: FormData) => {
    setIsPending(true)
    try {
      await createPost({
        data: {
          title: formData.get('title') as string,
          content: formData.get('content') as string,
        },
      })
      router.invalidate() // Refresh data
      router.navigate({ to: '/posts' })
    } finally {
      setIsPending(false)
    }
  }

  return (
    <form action={handleSubmit}>
      {/* form fields */}
    </form>
  )
}
```

## Router Configuration

```typescript
// src/router.tsx
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

export function createAppRouter() {
  return createRouter({
    routeTree,
    scrollRestoration: true,
    defaultPreload: 'intent',
    defaultPreloadStaleTime: 0,
  })
}

declare module '@tanstack/react-router' {
  interface Register {
    router: ReturnType<typeof createAppRouter>
  }
}
```

## shadcn/ui Integration

**IMPORTANT**: This project uses shadcn/ui for UI components. Always prefer shadcn/ui components over building custom components from scratch.

### Installing shadcn/ui Components

```bash
# Initialize shadcn/ui (if not already done)
npx shadcn@latest init

# Add individual components as needed
npx shadcn@latest add button card dialog form input select table toast
```

### Using shadcn/ui Components

```typescript
import { Button } from "@/components/ui/button"
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
} from "@/components/ui/card"

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
  )
}
```

## Form Handling with shadcn/ui

```typescript
import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { createPost } from "@/utils/posts.functions"
import { useRouter } from "@tanstack/react-router"
import { toast } from "@/components/ui/use-toast"

const formSchema = z.object({
  title: z.string().min(3, "Title must be at least 3 characters"),
  content: z.string().min(10, "Content must be at least 10 characters"),
})

export function CreatePostForm() {
  const router = useRouter()

  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: { title: "", content: "" },
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      await createPost({ data: values })
      toast({ title: "Success", description: "Post created" })
      router.invalidate()
      form.reset()
    } catch (error) {
      toast({ title: "Error", description: "Failed to create post", variant: "destructive" })
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
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Creating..." : "Create Post"}
        </Button>
      </form>
    </Form>
  )
}
```

## Convex Integration

### Using Convex with TanStack Start

```typescript
// src/utils/convex.functions.ts
import { createServerFn } from '@tanstack/react-start'
import { ConvexHttpClient } from 'convex/browser'
import { api } from '@/convex/_generated/api'

const convex = new ConvexHttpClient(process.env.CONVEX_URL!)

export const getPosts = createServerFn({
  method: 'GET',
}).handler(async () => {
  return convex.query(api.posts.list)
})

export const createPost = createServerFn({
  method: 'POST',
})
  .validator(z.object({ title: z.string(), content: z.string() }))
  .handler(async ({ data }) => {
    return convex.mutation(api.posts.create, data)
  })
```

### Using TanStack Query with Convex (Client-Side)

```typescript
"use client"

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { convex } from '@/lib/convex'
import { api } from '@/convex/_generated/api'

export function PostsList() {
  const { data: posts, isLoading } = useQuery({
    queryKey: ['posts'],
    queryFn: () => convex.query(api.posts.list),
  })

  if (isLoading) return <Skeleton />

  return (
    <div className="space-y-4">
      {posts?.map(post => <PostCard key={post._id} post={post} />)}
    </div>
  )
}
```

## Navigation

### Link Component

```typescript
import { Link } from '@tanstack/react-router'

// Basic navigation
<Link to="/posts">Posts</Link>

// With parameters
<Link to="/posts/$postId" params={{ postId: '123' }}>
  View Post
</Link>

// With search params
<Link to="/posts" search={{ page: 2, filter: 'published' }}>
  Page 2
</Link>

// Active styling
<Link
  to="/posts"
  activeProps={{ className: 'font-bold text-primary' }}
>
  Posts
</Link>
```

### Programmatic Navigation

```typescript
import { useRouter, useNavigate } from '@tanstack/react-router'

function Component() {
  const router = useRouter()
  const navigate = useNavigate()

  // Navigate to route
  navigate({ to: '/posts' })

  // Navigate with params
  navigate({ to: '/posts/$postId', params: { postId: '123' } })

  // Invalidate and refetch data
  router.invalidate()
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

### Custom Component Variants (CVA)

```typescript
import { cva, type VariantProps } from "class-variance-authority"

const cardVariants = cva(
  "rounded-lg shadow-md p-6",
  {
    variants: {
      variant: {
        default: "bg-white",
        dark: "bg-gray-900 text-white",
        outline: "bg-transparent border-2 border-gray-300",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

interface CardProps extends VariantProps<typeof cardVariants> {
  children: React.ReactNode
  className?: string
}

export function Card({ variant, children, className }: CardProps) {
  return (
    <div className={cardVariants({ variant, className })}>
      {children}
    </div>
  )
}
```

## Best Practices

1. **Accessibility**
   - Use semantic HTML (`<button>`, `<nav>`, `<main>`, etc.)
   - Add ARIA labels where needed
   - Ensure keyboard navigation works
   - Test with screen readers

2. **Performance** (see `resources/react-performance.md` for full guide)
   - **CRITICAL**: Use server functions for data fetching (avoids client waterfalls)
   - **CRITICAL**: Leverage route loaders for parallel data fetching
   - Use TanStack Query for client-side caching
   - Memoize expensive computations with `useMemo`
   - Avoid unnecessary re-renders with `React.memo`
   - Use stable references for props (avoid inline objects/arrays)

3. **Code Organization**
   - Keep components small and focused
   - Extract reusable logic into custom hooks
   - Separate server functions into `*.functions.ts` files
   - Keep server-only code in `*.server.ts` files
   - Share validation schemas in `schemas.ts`

4. **Styling**
   - Use Tailwind's utility classes for styling
   - Extract repeated class combinations into components
   - Use `@apply` sparingly (prefer components)
   - Follow a consistent spacing scale

5. **Type Safety**
   - Define interfaces for all component props
   - Use Zod schemas for server function validation
   - Leverage TanStack Router's type-safe params
   - Avoid `any` type

6. **Security**
   - Use server functions for sensitive operations
   - Never expose secrets in loaders (they run on both server AND client)
   - Validate all inputs with Zod schemas

## Resources

- **[React Performance Best Practices](./resources/react-performance.md)** - Critical performance patterns
- **[Component Patterns](./resources/components.md)** - Reusable component examples

## References

- [TanStack Start Documentation](https://tanstack.com/start/latest)
- [TanStack Router Documentation](https://tanstack.com/router/latest)
- [TanStack Query Documentation](https://tanstack.com/query/latest)
- [React Documentation](https://react.dev)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [shadcn/ui Documentation](https://ui.shadcn.com)
- [Convex Documentation](https://docs.convex.dev)
