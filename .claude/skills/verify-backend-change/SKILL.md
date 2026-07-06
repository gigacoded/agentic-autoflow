---
name: verify-backend-change
description: Verify backend changes against live data before declaring them done. Use after editing Convex functions, schema, or any server-side logic — run the changed function against the dev deployment, read real documents, and check logs with the Convex MCP instead of reasoning from code alone.
---

# Verifying Backend Changes (Convex MCP)

**Never report a backend change as complete based on a successful edit or
typecheck alone.** The Convex MCP gives you a live dev deployment: use it to
observe real behavior and real data.

## The verification loop

### 0. Confirm the deployment

```
mcp__convex__status()
```

Verify you are pointed at a **dev** deployment. Mutations run through the MCP
change real data — never run verification mutations against prod.

### 1. Confirm the function deployed as written

```
mcp__convex__functionSpec()
```

Check the changed function exists with the expected args/validator signature.
`npx convex dev` must be running (or run `npx convex deploy` for the dev
deployment) for edits to be live.

### 2. Exercise the changed behavior

- **Queries**: run the real function with realistic args:
  `mcp__convex__run(functionName, args)`. Feed it the boundary case you
  changed, not just the happy path.
- **Ad-hoc inspection**: `mcp__convex__runOneoffQuery(...)` for read-only
  probes that don't exist as deployed functions (it cannot write — safe
  anywhere).
- **Mutations**: run against dev data, then read the affected documents back
  with `mcp__convex__data(table)` to confirm the write is what you intended —
  shape, index fields, and no unintended fields.

### 3. Check the schema and data shape

```
mcp__convex__tables()
```

After schema changes: confirm the table, its indexes, and inferred types match
what you wrote. If you added an index, verify the query actually uses
`withIndex` on it — a full table scan that returns the right answer is still
a failure.

### 4. Read the logs

```
mcp__convex__logs()
```

Zero new errors or warnings from your change. An `console.warn` you introduced
counts.

### 5. (For performance work) Check insights

```
mcp__convex__insights()
```

Look for bytes-read spikes, full table scans, or functions that got more
expensive after your change.

## Reporting

Every report must contain exactly one of:

- `Verified: <function run, args used, and what the live data/logs showed>`
- `Unverified: edited but not verified because <reason>` (e.g., no dev
  deployment configured, MCP not connected)

## Notes

- Environment variables: `mcp__convex__envList` / `envGet` to check config the
  function depends on — verify the variable exists before shipping code that
  reads it.
- Non-Convex backends: apply the same discipline with the strongest tool
  available — run the endpoint with `curl`, read the real database, tail the
  real logs. The principle is identical: observe live behavior, don't infer it.
- Pair with `verify-frontend-change` when the change spans both sides:
  verify the backend function first, then the UI that consumes it.
