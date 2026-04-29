---
name: convex-backend-dev
description: Convex backend specialist. Use when writing/modifying Convex queries, mutations, actions, schema, indexes, or auditing query performance. Enforces indexes-only, validators on args+returns, helper-functions-in-model, internal vs public split, and transaction-safety in actions.
paths: "convex/**/*.ts"
---

# Convex Backend Development

**Auto-activates** for any work in `convex/`. Develops efficient, type-safe Convex backend with optimal query performance.

**Key principle**: Every query uses an index. No full table scans. Validators on every public arg AND return. Most logic lives in plain TypeScript helpers; `query`/`mutation`/`action` are thin wrappers.

---

## Autonomous Audit Process

When this skill activates, **proceed without asking** - follow these steps:

### Step 1 — Identify Convex Code

Files in `convex/`:
- New/modified `query` / `mutation` / `action` / `httpAction` / `internalQuery` / `internalMutation` / `internalAction`
- Schema changes
- Cron jobs / high-frequency functions
- Helpers in `convex/model/`

### Step 2 — Check Anti-Patterns

| Pattern | Problem | Fix |
|---|---|---|
| `.query("table").collect()` w/o index | Full table scan | Add `.withIndex()` |
| `.collect()` + JS `.filter()` | Fetches all, filters in JS | Server-side `.withIndex()` or `.filter()` |
| `.filter()` without `.withIndex()` | No index = full scan | Add index to schema |
| Cron every N seconds + `.collect()` | N × full_scans/day | Index the query |
| `ctx.db.get(id)` (no table name) | Lint violation | `ctx.db.get("table", id)` |
| `api.foo.bar` inside Convex code | Wrong — `api.*` is for clients | Use `internal.foo.bar` |
| Missing `args` validators | Type-unsafe public function | Add `v.*` validators |
| Missing `returns` validator | Drift between client/server | Add `returns` validator |
| Loop of `ctx.runMutation` in action | Each call = own transaction → broken atomicity | Single mutation; pass arrays |
| Floating promise (no `await`) | Race / lost write | Always `await` |
| `runAction` for non-Node code | Pointless overhead | Inline as helper |

### Step 3 — Verify Indexes

Check `convex/schema.ts`:
- Every queried field has an index
- Compound indexes for multi-field queries (equality fields first, range last)
- High-frequency (cron) queries indexed
- No redundant indexes (`by_foo` redundant when `by_foo_and_bar` exists, unless sort differs)

### Step 4 — Apply Fixes & Verify

1. Add missing indexes / validators
2. Move shared logic to `convex/model/*.ts` helpers
3. Convert `api.*` internal calls to `internal.*`
4. Run `npx tsc --noEmit`
5. Test via Convex MCP

---

## Core Rules

### 1. Always Use Indexes

```typescript
// ❌ Full table scan
const items = await ctx.db.query("items").collect();
const active = items.filter(i => i.status === "active");

// ✅ Indexed
const active = await ctx.db
  .query("items")
  .withIndex("by_status", q => q.eq("status", "active"))
  .collect();
```

Reserve `.filter()` for paginated queries. Bound `.collect()` to <1000 docs; otherwise use `.paginate()` or `.take(n)`.

### 2. Validators on Every Public Function — Args AND Returns

```typescript
import { v } from "convex/values";

export const create = mutation({
  args: {
    title: v.string(),
    status: v.union(v.literal("draft"), v.literal("published")),
    userId: v.id("users"),
  },
  returns: v.id("posts"),
  handler: async (ctx, args) => {
    return await ctx.db.insert("posts", args);
  },
});
```

`returns` validator catches client/server drift; required on public functions.

### 3. Thin Wrappers, Logic in `convex/model/`

```typescript
// convex/model/posts.ts — plain TS helper
import type { QueryCtx } from "../_generated/server";
import type { Id, Doc } from "../_generated/dataModel";

export async function getActivePostsForUser(
  ctx: QueryCtx,
  userId: Id<"users">,
): Promise<Doc<"posts">[]> {
  return ctx.db
    .query("posts")
    .withIndex("by_user_status", q => q.eq("userId", userId).eq("status", "active"))
    .collect();
}

// convex/posts.ts — wrapper
import { query } from "./_generated/server";
import { v } from "convex/values";
import { getActivePostsForUser } from "./model/posts";

export const listActive = query({
  args: { userId: v.id("users") },
  handler: (ctx, args) => getActivePostsForUser(ctx, args.userId),
});
```

Add a `returns` validator (e.g. `v.array(v.object({...}))`) when you want runtime checking; the doc-shape validator is verbose, so many teams omit it on read queries and rely on the helper's TS return type.

Wrappers handle auth + validation; helpers do the work. Reuse helpers across public/internal functions.

### 4. Internal vs Public

- Public: `query`, `mutation`, `action`, `httpAction` → callable by clients
- Internal: `internalQuery`, `internalMutation`, `internalAction` → only callable from other Convex functions
- **Never** use `api.*` inside Convex functions; use `internal.*`
- `ctx.scheduler.runAfter`, `ctx.runMutation`, etc. take only `internal.*` references

### 5. Server-Side Filtering

```typescript
// ❌ JS filter after collect
const items = (await ctx.db.query("items").withIndex("by_user", q => q.eq("userId", userId)).collect())
  .filter(i => i.status === "active");

// ✅ Server filter
const items = await ctx.db
  .query("items")
  .withIndex("by_user", q => q.eq("userId", userId))
  .filter(q => q.eq(q.field("status"), "active"))
  .collect();
```

### 6. Compound Index Order

Equality fields first, range last:

```typescript
// schema
defineTable({...}).index("by_user_createdAt", ["userId", "createdAt"])

// ✅ eq then range
.withIndex("by_user_createdAt", q => q.eq("userId", userId).gte("createdAt", since))
```

### 7. Always Include Table Name in `db.get/patch/replace/delete`

```typescript
// ✅
const post = await ctx.db.get("posts", postId);
await ctx.db.patch("posts", postId, { title: newTitle });
```

The `@convex-dev/explicit-table-ids` ESLint rule autofixes this.

### 8. Always `await` Promises

```typescript
// ❌ Floating
ctx.scheduler.runAfter(0, internal.notify.send, { userId });

// ✅
await ctx.scheduler.runAfter(0, internal.notify.send, { userId });
```

Enable `no-floating-promises` ESLint rule.

### 9. Transaction Safety in Actions

Each `ctx.runQuery` / `ctx.runMutation` from an action runs in its own transaction. Looping them breaks atomicity.

```typescript
// ❌ Each call = own transaction; one fail = partial state
for (const id of ids) {
  await ctx.runMutation(internal.posts.archive, { id });
}

// ✅ Single mutation, batch arg
await ctx.runMutation(internal.posts.archiveMany, { ids });
```

Inside `internal.posts.archiveMany` mutation, do all writes — they share one transaction.

### 10. `runAction` Only for Node Code

Default Convex runtime handles most logic. Use Node-runtime actions only when calling Node-only libraries (e.g., AWS SDK v3, certain crypto). For pure logic shared with queries/mutations, use plain TS helpers.

### 11. No `Date.now()` in Queries

Causes stale subscriptions and cache thrash. Use coarse boolean flags updated by scheduled jobs.

### 12. Authenticate Early

```typescript
export const myData = query({
  args: {},
  returns: v.array(v.any()),
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");

    return await ctx.db
      .query("data")
      .withIndex("by_userId", q => q.eq("userId", identity.subject))
      .collect();
  },
});
```

Never trust spoofable client args (`email`, etc.) for access control. Prefer granular functions (`setTeamOwner`) over broad ones (`updateTeam`) for fine-grained permission checks.

---

## Convex MCP Integration

The project's `.mcp.json` already wires up the Convex MCP:

```json
{
  "mcpServers": {
    "convex": { "command": "npx", "args": ["-y", "convex", "mcp", "start"] }
  }
}
```

Available MCP tools (use these to inspect/test):

| Tool | Purpose |
|---|---|
| `mcp__convex__status` | Connection / deployment status |
| `mcp__convex__tables` | List tables + schema |
| `mcp__convex__data` | Read documents from a table |
| `mcp__convex__functionSpec` | Inspect function signatures |
| `mcp__convex__run` | Invoke a deployed query/mutation/action |
| `mcp__convex__runOneoffQuery` | Run an ad-hoc query (not deployed) |
| `mcp__convex__logs` | Tail function logs |
| `mcp__convex__insights` | Bandwidth / performance insights |
| `mcp__convex__envGet` / `envList` / `envSet` / `envRemove` | Env var management |

Use these to:
- Verify schema before writing functions
- Test mutations after implementation
- Audit `mcp__convex__insights` for bandwidth hot spots
- Tail `mcp__convex__logs` while debugging

---

## Performance & Bandwidth

Convex bills database bandwidth. Inefficient queries can cost $10–50/day in overages.

| Pattern | Problem | Fix |
|---|---|---|
| `.query(t).collect()` w/o index | Full table scan | `.withIndex()` |
| `.find()` after `.collect()` | Full scan for one item | `.withIndex(...).first()` |
| Cron + `.collect()` | N × scans/day | Index it |
| Unbounded `.collect()` | Pulls everything | `.take(limit)` or `.paginate()` |

Estimate: `bandwidth/day = records_returned × avg_record_size × calls/day`

---

## Common Patterns

### Replace `.find()` with Indexed Lookup

```typescript
// ❌
const users = await ctx.db.query("users").collect();
const user = users.find(u => u.email === email);

// ✅
const user = await ctx.db
  .query("users")
  .withIndex("by_email", q => q.eq("email", email))
  .first();
```

### Parallelize Independent Reads

```typescript
const [user, posts, followers] = await Promise.all([
  ctx.db.get("users", userId),
  getUserPosts(ctx, userId),
  getFollowers(ctx, userId),
]);
```

### Pagination

```typescript
import { paginationOptsValidator } from "convex/server";
import { query } from "./_generated/server";

export const listPaginated = query({
  args: { paginationOpts: paginationOptsValidator },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("posts")
      .withIndex("by_creation")
      .order("desc")
      .paginate(args.paginationOpts);
  },
});
```

---

## When to Apply

**Always**: new Convex functions, schema changes, query optimization, cron jobs, debugging perf
**Skip**: frontend-only changes, third-party HTTP calls inside actions

---

## Quick Checklist

Before marking complete:

- [ ] Every query uses `.withIndex()` (no full scans)
- [ ] No JS `.filter()` after `.collect()`
- [ ] `args` AND `returns` validators on public functions
- [ ] Logic lives in `convex/model/`; wrappers thin
- [ ] Internal calls use `internal.*`, not `api.*`
- [ ] `ctx.db.get/patch/replace/delete` includes table name
- [ ] All promises awaited (no floating)
- [ ] Actions: no looped `ctx.runMutation` (use batch)
- [ ] `runAction` only when Node runtime needed
- [ ] No `Date.now()` in queries
- [ ] Auth checked early
- [ ] `npx tsc --noEmit` clean
- [ ] Tested via Convex MCP

---

## References

- [Convex Best Practices](https://docs.convex.dev/production/best-practices)
- [Convex Indexes](https://docs.convex.dev/database/reading-data/indexes/)
- [Convex Validators](https://docs.convex.dev/database/schemas)
- [Convex MCP](https://docs.convex.dev/ai/convex-mcp-server)
- [Convex Billing](https://docs.convex.dev/production/billing)
