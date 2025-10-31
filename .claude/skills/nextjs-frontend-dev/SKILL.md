# Next.js Frontend Development

**Auto-activates when**: Working with React components, Next.js App Router, Tailwind, shadcn/ui, or files in `/app` or `/components`

## Overview

Patterns for Next.js 14+ App Router with React Server Components, Tailwind CSS, shadcn/ui, and Convex integration.

## Core Principles

1. **Server Components by default** - Use Client Components only when needed
2. **Type safety everywhere** - Full TypeScript for components and data
3. **shadcn/ui for UI** - Consistent, accessible components
4. **Tailwind for styling** - Utility-first CSS
5. **Convex for data** - React hooks for realtime data

## Component Patterns

### Server Component (Default)

```typescript
// app/quotes/page.tsx
import { preloadQuery } from "convex/nextjs";
import { api } from "@/convex/_generated/api";
import { auth } from "@clerk/nextjs/server";
import QuotesList from "@/components/quotes-list";

export default async function QuotesPage() {
  const { userId } = await auth();

  if (!userId) {
    redirect("/sign-in");
  }

  // Preload data on server
  const preloadedQuotes = await preloadQuery(api.quotes.list, {
    paginationOpts: { numItems: 20, cursor: null },
  });

  return (
    <div className="container mx-auto py-8">
      <h1 className="text-3xl font-bold mb-6">My Quotes</h1>
      <QuotesList preloadedQuotes={preloadedQuotes} />
    </div>
  );
}
```

**Best Practices**:
- ✅ Async by default
- ✅ Fetch data on server when possible
- ✅ Use Tailwind classes directly
- ✅ No "use client" directive needed
- ❌ Can't use hooks (useState, useEffect, etc.)
- ❌ Can't use browser APIs

### Client Component

```typescript
"use client";

import { useQuery, useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Button } from "@/components/ui/button";
import { useState } from "react";

export default function QuotesList({ preloadedQuotes }) {
  const [isCreating, setIsCreating] = useState(false);

  // Use Convex hooks for realtime data
  const quotes = useQuery(
    api.quotes.list,
    { paginationOpts: { numItems: 20, cursor: null } }
  );

  const createQuote = useMutation(api.quotes.create);

  const handleCreate = async () => {
    setIsCreating(true);
    try {
      await createQuote({
        clientName: "New Client",
        items: [],
      });
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className="space-y-4">
      <Button onClick={handleCreate} disabled={isCreating}>
        Create Quote
      </Button>

      <div className="grid gap-4">
        {quotes?.map((quote) => (
          <QuoteCard key={quote._id} quote={quote} />
        ))}
      </div>
    </div>
  );
}
```

**When to use "use client"**:
- ✅ Need hooks (useState, useEffect, useQuery, etc.)
- ✅ Event handlers (onClick, onChange, etc.)
- ✅ Browser APIs (localStorage, window, etc.)
- ✅ Third-party components that use hooks
- ❌ Just for styling (use Server Components)
- ❌ Just for displaying data (use Server Components)

## Convex Integration

### useQuery Hook

```typescript
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Id } from "@/convex/_generated/dataModel";

function QuoteDetail({ quoteId }: { quoteId: Id<"quotes"> }) {
  const quote = useQuery(api.quotes.get, { quoteId });

  if (quote === undefined) {
    return <div>Loading...</div>;
  }

  if (quote === null) {
    return <div>Quote not found</div>;
  }

  return <div>{quote.clientName}</div>;
}
```

**States**:
- `undefined` - Loading
- `null` - Not found (if query returns null)
- `data` - Data loaded

### useMutation Hook

```typescript
"use client";

import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Button } from "@/components/ui/button";
import { useToast } from "@/hooks/use-toast";

function DeleteQuoteButton({ quoteId }) {
  const deleteQuote = useMutation(api.quotes.delete);
  const { toast } = useToast();

  const handleDelete = async () => {
    try {
      await deleteQuote({ quoteId });
      toast({
        title: "Quote deleted",
        description: "The quote has been deleted successfully.",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  return (
    <Button variant="destructive" onClick={handleDelete}>
      Delete
    </Button>
  );
}
```

### useAction Hook

```typescript
"use client";

import { useAction } from "convex/react";
import { api } from "@/convex/_generated/api";

function SendQuoteButton({ quoteId }) {
  const sendQuote = useAction(api.quotes.sendEmail);
  const [isSending, setIsSending] = useState(false);

  const handleSend = async () => {
    setIsSending(true);
    try {
      await sendQuote({ quoteId });
    } finally {
      setIsSending(false);
    }
  };

  return (
    <Button onClick={handleSend} disabled={isSending}>
      {isSending ? "Sending..." : "Send Quote"}
    </Button>
  );
}
```

## shadcn/ui Patterns

### Using Components

```typescript
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

function QuoteForm() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Create Quote</CardTitle>
        <CardDescription>Enter quote details below</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="client">Client Name</Label>
          <Input id="client" placeholder="Acme Corp" />
        </div>
        <Button>Create Quote</Button>
      </CardContent>
    </Card>
  );
}
```

### Form with react-hook-form

```typescript
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";

const formSchema = z.object({
  clientName: z.string().min(1, "Client name is required"),
  email: z.string().email("Invalid email address"),
});

function QuoteForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      clientName: "",
      email: "",
    },
  });

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    // Submit to Convex
    console.log(values);
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="clientName"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Client Name</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Create Quote</Button>
      </form>
    </Form>
  );
}
```

## Tailwind Patterns

### Layout with Flexbox

```typescript
function QuoteGrid() {
  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Quotes</h2>
        <Button>New Quote</Button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Cards */}
      </div>
    </div>
  );
}
```

### Responsive Design

```typescript
<div className="
  w-full
  max-w-7xl
  mx-auto
  px-4 sm:px-6 lg:px-8
  py-4 sm:py-6 lg:py-8
">
  <h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold">
    Responsive Heading
  </h1>
</div>
```

### Dark Mode

```typescript
// Use dark: prefix for dark mode styles
<Card className="bg-white dark:bg-gray-900">
  <CardHeader className="border-b border-gray-200 dark:border-gray-800">
    <CardTitle className="text-gray-900 dark:text-white">
      Title
    </CardTitle>
  </CardHeader>
</Card>
```

## App Router Patterns

### Page Structure

```
app/
├── layout.tsx          # Root layout
├── page.tsx            # Home page
├── quotes/
│   ├── layout.tsx      # Quotes section layout
│   ├── page.tsx        # List all quotes
│   ├── [id]/
│   │   ├── page.tsx    # Quote detail
│   │   └── edit/
│   │       └── page.tsx # Edit quote
│   └── new/
│       └── page.tsx    # Create quote
└── api/
    └── webhook/
        └── route.ts    # API route
```

### Dynamic Routes

```typescript
// app/quotes/[id]/page.tsx
import { api } from "@/convex/_generated/api";
import { Id } from "@/convex/_generated/dataModel";
import { preloadQuery } from "convex/nextjs";

export default async function QuotePage({
  params,
}: {
  params: { id: string };
}) {
  const quoteId = params.id as Id<"quotes">;

  const preloadedQuote = await preloadQuery(api.quotes.get, { quoteId });

  return (
    <div>
      <QuoteDetail preloadedQuote={preloadedQuote} />
    </div>
  );
}
```

### Layouts

```typescript
// app/quotes/layout.tsx
export default function QuotesLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      <aside className="w-64 border-r">
        <QuotesNav />
      </aside>
      <main className="flex-1 p-8">{children}</main>
    </div>
  );
}
```

### Loading States

```typescript
// app/quotes/loading.tsx
export default function Loading() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-12 w-full" />
      <Skeleton className="h-64 w-full" />
    </div>
  );
}
```

### Error Handling

```typescript
// app/quotes/error.tsx
"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Something went wrong</CardTitle>
        <CardDescription>{error.message}</CardDescription>
      </CardHeader>
      <CardContent>
        <Button onClick={reset}>Try again</Button>
      </CardContent>
    </Card>
  );
}
```

## Authentication with Clerk

### Protecting Pages

```typescript
// app/dashboard/page.tsx
import { auth } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";

export default async function DashboardPage() {
  const { userId } = await auth();

  if (!userId) {
    redirect("/sign-in");
  }

  return <div>Protected content</div>;
}
```

### User Button

```typescript
// components/header.tsx
"use client";

import { UserButton } from "@clerk/nextjs";

export function Header() {
  return (
    <header className="border-b">
      <div className="container flex h-16 items-center justify-between">
        <h1>My App</h1>
        <UserButton afterSignOutUrl="/" />
      </div>
    </header>
  );
}
```

### Get Current User

```typescript
"use client";

import { useUser } from "@clerk/nextjs";

export function WelcomeMessage() {
  const { user } = useUser();

  if (!user) return null;

  return <p>Welcome, {user.firstName}!</p>;
}
```

## Performance Optimization

### Image Optimization

```typescript
import Image from "next/image";

<Image
  src="/quote-logo.png"
  alt="Quote"
  width={200}
  height={200}
  className="rounded-lg"
  priority // For above-the-fold images
/>
```

### Dynamic Imports

```typescript
import dynamic from "next/dynamic";

const QuoteEditor = dynamic(() => import("@/components/quote-editor"), {
  loading: () => <Skeleton className="h-96" />,
  ssr: false, // Disable server-side rendering
});
```

### Memoization

```typescript
"use client";

import { useMemo } from "react";

function QuoteStats({ quotes }) {
  const stats = useMemo(() => {
    return {
      total: quotes.length,
      totalValue: quotes.reduce((sum, q) => sum + q.total, 0),
    };
  }, [quotes]);

  return <div>Total: ${stats.totalValue}</div>;
}
```

## Quick Reference

**Server Component**:
```typescript
export default async function Page() { }
```

**Client Component**:
```typescript
"use client";
export default function Component() { }
```

**Convex Query**:
```typescript
const data = useQuery(api.module.function, args);
```

**Convex Mutation**:
```typescript
const mutate = useMutation(api.module.function);
await mutate(args);
```

**shadcn Component**:
```typescript
import { Button } from "@/components/ui/button";
<Button variant="outline">Click</Button>
```

**Tailwind Responsive**:
```typescript
className="text-sm md:text-base lg:text-lg"
```

**Protect Page**:
```typescript
const { userId } = await auth();
if (!userId) redirect("/sign-in");
```

## Related Documentation

- [Next.js App Router](https://nextjs.org/docs/app)
- [Convex React](https://docs.convex.dev/client/react)
- [shadcn/ui](https://ui.shadcn.com)
- [Tailwind CSS](https://tailwindcss.com)
- [Clerk Authentication](https://clerk.com/docs)
- Related skill: `convex-backend-dev` for backend
- Related skill: `e2e-testing-framework` for testing
