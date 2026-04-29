---
name: tanstack-start-dev
description: TanStack Start specialist (full-stack React on Vite). Use when writing server functions (createServerFn), file routes (createFileRoute), loaders/beforeLoad, middleware, SSR, or wiring TanStack Query/Router. Enforces inputValidator (not validator), thin server fns, server-only data fetching, and type-safe routing.
paths: "src/routes/**/*.tsx,src/router.tsx,src/utils/*.functions.ts,src/utils/*.server.ts,vite.config.ts,app.config.ts"
---

# TanStack Start

**Auto-activates** for routes, server functions, loaders, middleware, router config.

**Stack** (2026): TanStack Start RC (Vite-native), TanStack Router, TanStack Query, React 19+. Imports come from `@tanstack/react-start` and `@tanstack/react-router`.

## Key 2026 API change

`createServerFn().validator(...)` was renamed to `.inputValidator(...)`. Use `.inputValidator()`. Old code with `.validator()` should be migrated.

---

## File-Based Routing (`src/routes/`)

| File | Path | Purpose |
|---|---|---|
| `__root.tsx` | — | Root shell. Required. Renders `<HeadContent />` and `<Scripts />`. |
| `index.tsx` | `/` | Index |
| `about.tsx` | `/about` | Static |
| `posts/$postId.tsx` | `/posts/:postId` | Dynamic param |
| `_auth/login.tsx` | `/login` | Pathless layout group |
| `(marketing)/pricing.tsx` | `/pricing` | Route group (org only) |
| `posts.route.tsx` | layout for `/posts/*` | Layout file |

### Root route

```tsx
// src/routes/__root.tsx
import { createRootRoute, Outlet } from "@tanstack/react-router";
import { HeadContent, Scripts } from "@tanstack/react-start";

export const Route = createRootRoute({
  head: () => ({
    meta: [{ title: "My App" }],
    links: [{ rel: "stylesheet", href: "/app.css" }],
  }),
  component: RootComponent,
});

function RootComponent() {
  return (
    <html lang="en">
      <head><HeadContent /></head>
      <body>
        <Outlet />
        <Scripts />
      </body>
    </html>
  );
}
```

### Route options

| Option | Purpose |
|---|---|
| `component` | Render component |
| `head` | meta/title/links |
| `loader` | Data fetching (server + client; runs before render) |
| `beforeLoad` | Pre-load gate: auth checks, redirects, parent context |
| `errorComponent` | Renders on loader/component errors |
| `pendingComponent` | Renders while loader resolves |
| `validateSearch` | Type-safe search params (Zod-friendly) |
| `params` | Param parsing/validation |
| `staleTime`, `gcTime` | Loader cache control |

### Dynamic route + loader

```tsx
// src/routes/posts/$postId.tsx
import { createFileRoute, notFound } from "@tanstack/react-router";
import { getPost } from "@/utils/posts.functions";

export const Route = createFileRoute("/posts/$postId")({
  loader: async ({ params }) => {
    const post = await getPost({ data: params.postId });
    if (!post) throw notFound();
    return post;
  },
  component: PostPage,
  errorComponent: ({ error }) => <p>Failed: {error.message}</p>,
  pendingComponent: () => <p>Loading…</p>,
});

function PostPage() {
  const post = Route.useLoaderData();
  const { postId } = Route.useParams();
  return <article><h1>{post.title}</h1><p>{post.body}</p></article>;
}
```

### Search params

```tsx
import { z } from "zod";
const searchSchema = z.object({ page: z.number().default(1), q: z.string().optional() });

export const Route = createFileRoute("/posts/")({
  validateSearch: searchSchema,
  loader: ({ deps }) => listPosts({ data: deps }),
  loaderDeps: ({ search }) => ({ page: search.page, q: search.q }),
  component: PostsPage,
});

function PostsPage() {
  const { page, q } = Route.useSearch();
}
```

### `beforeLoad` for auth

```tsx
import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_auth")({
  beforeLoad: async ({ context, location }) => {
    const user = await context.getUser();
    if (!user) throw redirect({ to: "/login", search: { from: location.href } });
    return { user };
  },
});
```

Child routes inherit returned context via `Route.useRouteContext()`.

---

## Server Functions (`createServerFn`)

Server-only RPC. Files conventionally end `.functions.ts`.

```tsx
// src/utils/posts.functions.ts
import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { db } from "./db.server";

// GET — read
export const listPosts = createServerFn({ method: "GET" })
  .inputValidator(z.object({ page: z.number(), q: z.string().optional() }))
  .handler(async ({ data }) => {
    return db.posts.findMany({ skip: (data.page - 1) * 20, take: 20 });
  });

// GET by id
export const getPost = createServerFn({ method: "GET" })
  .inputValidator(z.string())
  .handler(async ({ data: postId }) => db.posts.findUnique({ where: { id: postId } }));

// POST — mutation
export const createPost = createServerFn({ method: "POST" })
  .inputValidator(z.object({ title: z.string().min(3), body: z.string().min(10) }))
  .handler(async ({ data }) => db.posts.create({ data }));
```

### Calling from client

```tsx
import { useServerFn } from "@tanstack/react-start";

function CreateForm() {
  const create = useServerFn(createPost);
  const router = useRouter();

  async function onSubmit(values) {
    await create({ data: values });
    router.invalidate();
  }
}
```

Or call directly: `await createPost({ data: { ... } })`.

### Errors / redirects / 404 from server fns

```tsx
import { redirect, notFound } from "@tanstack/react-router";

.handler(async ({ data }) => {
  const post = await db.posts.findUnique({ where: { id: data } });
  if (!post) throw notFound();
  if (post.archived) throw redirect({ to: "/" });
  return post;
});
```

### Reading request / writing response headers

```tsx
import { getRequestHeader, setResponseHeader } from "@tanstack/react-start/server";

.handler(async () => {
  const auth = getRequestHeader("authorization");
  setResponseHeader("cache-control", "max-age=300");
  return data;
});
```

### Raw responses

```tsx
.handler(async () => new Response(buffer, { headers: { "content-type": "application/octet-stream" } }));
```

---

## Middleware

Cross-cutting logic (auth, logging, request context):

Server-function middleware requires `{ type: 'function' }`:

```tsx
// src/utils/middleware.ts
import { createMiddleware } from "@tanstack/react-start";

export const authMiddleware = createMiddleware({ type: "function" })
  .server(async ({ next }) => {
    const user = await readUserFromCookies();
    if (!user) throw new Error("Unauthenticated");
    return next({ context: { user } });
  });

// usage — chain order: .middleware() → .inputValidator() → .handler()
export const myFn = createServerFn({ method: "POST" })
  .middleware([authMiddleware])
  .inputValidator(schema)
  .handler(async ({ data, context }) => {
    // context.user available
  });
```

For request-level middleware (runs on every request, not tied to a server fn), omit `type` or use `createMiddleware()` without args.

---

## Router setup (`src/router.tsx`)

```tsx
import { createRouter } from "@tanstack/react-router";
import { routeTree } from "./routeTree.gen";

export function createAppRouter() {
  return createRouter({
    routeTree,
    scrollRestoration: true,
    defaultPreload: "intent",
    defaultPreloadStaleTime: 0,
    defaultErrorComponent: ({ error }) => <p>{error.message}</p>,
    defaultNotFoundComponent: () => <p>Not found</p>,
  });
}

declare module "@tanstack/react-router" {
  interface Register {
    router: ReturnType<typeof createAppRouter>;
  }
}
```

---

## Vite config

TanStack Start runs through `vite.config.ts` (no separate `app.config.ts` in current versions):

```ts
import { defineConfig } from "vite";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";

export default defineConfig({
  plugins: [tanstackStart({ /* options */ })],
});
```

---

## TanStack Query Integration

Pre-fetch in route loaders, hydrate on client:

```tsx
import { queryOptions } from "@tanstack/react-query";

const postQuery = (id: string) => queryOptions({
  queryKey: ["post", id],
  queryFn: () => getPost({ data: id }),
});

export const Route = createFileRoute("/posts/$postId")({
  loader: ({ context, params }) => context.queryClient.ensureQueryData(postQuery(params.postId)),
  component: PostPage,
});

function PostPage() {
  const { postId } = Route.useParams();
  const { data: post } = useSuspenseQuery(postQuery(postId));
  return <h1>{post.title}</h1>;
}
```

---

## Convex Integration

```tsx
// src/utils/convex.functions.ts
import { createServerFn } from "@tanstack/react-start";
import { ConvexHttpClient } from "convex/browser";
import { api } from "../../convex/_generated/api";

const convex = new ConvexHttpClient(process.env.CONVEX_URL!);

export const listPosts = createServerFn({ method: "GET" })
  .handler(async () => convex.query(api.posts.list));
```

For real-time client subscriptions, use `ConvexProvider` + `useQuery` from `convex/react` directly in components.

---

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| `.validator(...)` in `createServerFn` | `.inputValidator(...)` |
| Client `fetch` to your own backend | Use server function instead |
| Secrets imported in route component | Move to `.server.ts` or server fn handler |
| Loader fetch waterfalls | Parallel: `await Promise.all([...])` in loader |
| `useEffect` for initial data | Loader |
| Inline objects/arrays as props | Stable refs, `useMemo` |
| Skipping `validateSearch` | All search params must be validated |

---

## Quick Checklist

- [ ] All server fns use `.inputValidator()` (not `.validator()`)
- [ ] Sensitive logic only in `.server.ts` / server fn handlers
- [ ] Routes have `errorComponent` + `pendingComponent` where loaders are slow
- [ ] Search params validated with `validateSearch`
- [ ] Loader deps declared via `loaderDeps` when search affects data
- [ ] Auth gates use `beforeLoad` with `redirect()`
- [ ] Type-safe `Register` interface declared
- [ ] `npx tsc --noEmit` clean

---

## References

- [TanStack Start Docs](https://tanstack.com/start/latest/docs)
- [Server Functions Guide](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
- [Routing Guide](https://tanstack.com/start/latest/docs/framework/react/guide/routing)
- [TanStack Router](https://tanstack.com/router/latest)
- [TanStack Query](https://tanstack.com/query/latest)
