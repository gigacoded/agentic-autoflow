# React Performance Best Practices

Based on [Vercel's React Best Practices](https://github.com/vercel-labs/agent-skills/tree/react-best-practices/skills/react-best-practices), adapted for TanStack Start.

## Priority Order

1. **CRITICAL**: Async/Bundle optimization (directly affects TTI, LCP)
2. **HIGH**: Server-side performance (waterfalls are #1 performance killer)
3. **MEDIUM-HIGH**: Client-side data fetching
4. **MEDIUM**: Re-render optimization, Rendering performance
5. **LOWER**: JS micro-optimizations, Advanced patterns

---

## 1. Async Patterns (CRITICAL)

### TanStack Start: Route Loaders for Parallel Fetching

**Problem**: Sequential awaits in loaders create waterfalls.

```typescript
// INCORRECT - Creates waterfall in loader
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getUser()      // Wait...
    const posts = await getPosts()    // Wait...
    const stats = await getStats()    // Wait...
    return { user, posts, stats }
  },
})
```

```typescript
// CORRECT - Parallel fetching with Promise.all
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const [user, posts, stats] = await Promise.all([
      getUser(),
      getPosts(),
      getStats(),
    ])
    return { user, posts, stats }
  },
})
```

### Parallel Fetching via Component Composition

```typescript
// CORRECT - Each route fetches its own data in parallel
// src/routes/dashboard/index.tsx
export const Route = createFileRoute('/dashboard/')({
  component: DashboardPage,
  loader: () => getDashboardData(),
})

// src/routes/dashboard/sidebar.tsx (nested route)
export const Route = createFileRoute('/dashboard/sidebar')({
  component: Sidebar,
  loader: () => getSidebarData(),  // Fetches in parallel with parent
})
```

### Using TanStack Query for Client-Side Parallel Fetching

```typescript
import { useQueries } from '@tanstack/react-query'

function Dashboard() {
  const results = useQueries({
    queries: [
      { queryKey: ['user'], queryFn: fetchUser },
      { queryKey: ['posts'], queryFn: fetchPosts },
      { queryKey: ['stats'], queryFn: fetchStats },
    ],
  })

  // All three fetch in parallel
  const [user, posts, stats] = results
}
```

---

## 2. Bundle Optimization (CRITICAL)

### Dynamic Imports with React.lazy

**Impact**: Directly affects Time to Interactive (TTI) and Largest Contentful Paint (LCP).

```typescript
// INCORRECT - Adds ~300KB to initial bundle
import { MonacoEditor } from "./MonacoEditor"

export function CodePage() {
  return <MonacoEditor />
}
```

```typescript
// CORRECT - Lazy loads when needed
import { lazy, Suspense } from 'react'

const MonacoEditor = lazy(() => import('./MonacoEditor'))

export function CodePage() {
  return (
    <Suspense fallback={<EditorSkeleton />}>
      <MonacoEditor />
    </Suspense>
  )
}
```

### TanStack Router: Route-Based Code Splitting

TanStack Router automatically code-splits routes. Each route file becomes its own chunk.

```typescript
// Automatic code splitting - each route is lazy loaded
// src/routes/admin/index.tsx → Only loaded when visiting /admin
// src/routes/settings/index.tsx → Only loaded when visiting /settings
```

### Preloading on Intent

```typescript
import { Link } from '@tanstack/react-router'

// TanStack Router preloads on hover by default
<Link to="/heavy-page" preload="intent">
  Heavy Page
</Link>

// Or preload immediately
<Link to="/critical-page" preload="viewport">
  Critical Page
</Link>
```

### Barrel Import Optimization

**Problem**: Barrel files (`index.ts`) can pull in entire module trees.

```typescript
// INCORRECT - May import entire icon library
import { HomeIcon } from "@/components/icons"
```

```typescript
// CORRECT - Direct import
import { HomeIcon } from "@/components/icons/HomeIcon"
```

---

## 3. Server-Side Performance (HIGH)

### TanStack Start: Server Functions for Data Fetching

```typescript
// src/utils/data.functions.ts
import { createServerFn } from '@tanstack/react-start'

// Server function - runs ONLY on server
export const getData = createServerFn({
  method: 'GET',
}).handler(async () => {
  // Safe to use secrets here
  const data = await db.query(process.env.SECRET_KEY)
  return data
})

// Route loader calls server function
export const Route = createFileRoute('/data')({
  loader: () => getData(),  // Isomorphic - works on server & client
})
```

### Caching with TanStack Query

```typescript
import { queryOptions } from '@tanstack/react-query'

// Define query options with caching
export const userQueryOptions = (id: string) =>
  queryOptions({
    queryKey: ['user', id],
    queryFn: () => getUser(id),
    staleTime: 5 * 60 * 1000,  // 5 minutes
    gcTime: 10 * 60 * 1000,    // 10 minutes
  })

// Use in route loader
export const Route = createFileRoute('/users/$userId')({
  loader: ({ context, params }) =>
    context.queryClient.ensureQueryData(userQueryOptions(params.userId)),
})
```

### Request Deduplication

```typescript
// TanStack Query automatically dedupes identical requests
function ComponentA() {
  const { data } = useQuery(userQueryOptions('123'))  // Fetches
  return <div>{data?.name}</div>
}

function ComponentB() {
  const { data } = useQuery(userQueryOptions('123'))  // Reuses cache!
  return <div>{data?.email}</div>
}
```

---

## 4. Re-render Optimization (MEDIUM)

### Extract to Memoized Components

```typescript
// INCORRECT - Expensive work happens even when loading
function Parent({ isLoading }) {
  const result = useMemo(() => expensiveWork(), [])

  if (isLoading) return <Spinner />  // Too late!
  return <Child result={result} />
}
```

```typescript
// CORRECT - Skips computation when loading
function Parent({ isLoading }) {
  if (isLoading) return <Spinner />
  return <ExpensiveChild />
}

const ExpensiveChild = memo(function ExpensiveChild() {
  const result = useMemo(() => expensiveWork(), [])
  return <div>{result}</div>
})
```

### Lazy State Initialization

```typescript
// INCORRECT - Runs on every render
const [state, setState] = useState(expensiveComputation())
```

```typescript
// CORRECT - Runs only once
const [state, setState] = useState(() => expensiveComputation())
```

### Subscribe to Derived State

```typescript
// INCORRECT - Re-renders on every pixel change
function Component() {
  const width = useWindowWidth()  // Updates continuously
  const isMobile = width < 768
  return <div>{isMobile ? "Mobile" : "Desktop"}</div>
}
```

```typescript
// CORRECT - Re-renders only when boolean changes
function Component() {
  const isMobile = useMediaQuery("(max-width: 767px)")
  return <div>{isMobile ? "Mobile" : "Desktop"}</div>
}
```

### Avoid Inline Object/Array Props

```typescript
// INCORRECT - New reference every render
<List items={items.filter(x => x.active)} />
<Component style={{ color: "red" }} />
```

```typescript
// CORRECT - Stable references
const activeItems = useMemo(() => items.filter(x => x.active), [items])
const style = useMemo(() => ({ color: "red" }), [])

<List items={activeItems} />
<Component style={style} />
```

---

## 5. Rendering Optimization (MEDIUM)

### Hoist Static JSX

```typescript
// INCORRECT - Recreated every render
function Container({ isLoading }) {
  const skeleton = <Skeleton />  // New object each render
  return isLoading ? skeleton : <Content />
}
```

```typescript
// CORRECT - Created once
const skeleton = <Skeleton />

function Container({ isLoading }) {
  return isLoading ? skeleton : <Content />
}
```

### Content Visibility for Long Lists

```css
/* Defer rendering of off-screen content */
.list-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 80px;
}
```

### Use TanStack Virtual for Large Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

function VirtualList({ items }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  })

  return (
    <div ref={parentRef} className="h-[400px] overflow-auto">
      <div
        style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}
      >
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: 0,
              transform: `translateY(${virtualItem.start}px)`,
            }}
          >
            {items[virtualItem.index]}
          </div>
        ))}
      </div>
    </div>
  )
}
```

---

## 6. Client-Side Patterns (MEDIUM-HIGH)

### TanStack Query Deduplication

```typescript
// Multiple components can call same query - only one request
function ComponentA() {
  const { data } = useQuery({ queryKey: ['user'], queryFn: fetchUser })
  return <div>{data?.name}</div>
}

function ComponentB() {
  const { data } = useQuery({ queryKey: ['user'], queryFn: fetchUser })  // Deduped!
  return <div>{data?.email}</div>
}
```

### Optimistic Updates

```typescript
const queryClient = useQueryClient()

const mutation = useMutation({
  mutationFn: updatePost,
  onMutate: async (newPost) => {
    await queryClient.cancelQueries({ queryKey: ['posts'] })
    const previous = queryClient.getQueryData(['posts'])

    // Optimistically update
    queryClient.setQueryData(['posts'], (old) =>
      old.map((p) => (p.id === newPost.id ? newPost : p))
    )

    return { previous }
  },
  onError: (err, newPost, context) => {
    // Rollback on error
    queryClient.setQueryData(['posts'], context.previous)
  },
})
```

### Event Listener Cleanup

```typescript
// CORRECT - Proper cleanup
useEffect(() => {
  const handler = () => { /* ... */ }
  window.addEventListener("resize", handler)
  return () => window.removeEventListener("resize", handler)
}, [])
```

---

## 7. JavaScript Micro-Optimizations (LOWER)

### Cache Property Access in Loops

```typescript
// INCORRECT
for (let i = 0; i < arr.length; i++) {  // .length checked each iteration
  process(arr[i])
}

// CORRECT
const len = arr.length
for (let i = 0; i < len; i++) {
  process(arr[i])
}
```

### Use Set/Map for Lookups

```typescript
// INCORRECT - O(n) lookup
const ids = [1, 2, 3, 4, 5]
items.filter(item => ids.includes(item.id))  // Slow for large arrays

// CORRECT - O(1) lookup
const idSet = new Set([1, 2, 3, 4, 5])
items.filter(item => idSet.has(item.id))
```

### Early Exit Patterns

```typescript
// INCORRECT
function process(items) {
  if (items && items.length > 0) {
    // ... lots of code
  }
}

// CORRECT
function process(items) {
  if (!items?.length) return
  // ... lots of code
}
```

---

## Quick Reference Checklist

### Before Every Component
- [ ] Can this be a server function? (prefer server for data fetching)
- [ ] Are there any async waterfalls in loaders?
- [ ] Can heavy imports be dynamically loaded?

### Re-render Prevention
- [ ] Stable object/array references (useMemo)
- [ ] Memoized components for expensive children (memo)
- [ ] Lazy state initialization for expensive defaults

### Data Fetching (TanStack)
- [ ] Use Promise.all in loaders for parallel fetching
- [ ] Use TanStack Query for client-side caching
- [ ] Leverage route preloading (`preload="intent"`)
- [ ] Use server functions for sensitive data

### Bundle Size
- [ ] Rely on route-based code splitting
- [ ] Use React.lazy for heavy non-route components
- [ ] Direct imports instead of barrel files
- [ ] Preload on user intent (hover/focus)

### Large Lists
- [ ] Use TanStack Virtual for 100+ items
- [ ] Use content-visibility CSS for moderate lists
