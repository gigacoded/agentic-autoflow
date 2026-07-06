---
name: verify-frontend-change
description: Verify any UI change end-to-end in a real browser before declaring it done. Use after editing components, routes, styles, or any code that renders — never report a UI change as complete based on a successful edit or typecheck alone. Uses Chrome DevTools MCP to interact with the change, check the console, and screenshot the result.
---

# Verifying Frontend Changes

**Never report a UI change as complete based on a successful edit alone.**
An edit that compiles is an unverified hypothesis. Verify it the way a human
reviewer would: run it, see it, interact with it.

## The verification loop

Run these steps in order. If any step fails, fix the issue and rerun from
step 1 — do not hand back partially verified work.

### 1. Start the dev server and open the page

```
# Ensure the dev server is running (usually `npm run dev`); start it in the
# background if it is not.
mcp__chrome-devtools__new_page(url: "http://localhost:3000/<edited-page>")
mcp__chrome-devtools__take_snapshot()
```

Confirm the page actually rendered — not an error boundary, a blank screen,
or a redirect to sign-in you didn't expect.

### 2. Interact with the change directly

For a new or modified control (button, input, toggle, form):

- Take a snapshot to get element UIDs — never guess selectors.
- Click / type / toggle it: `mcp__chrome-devtools__click(uid)`,
  `mcp__chrome-devtools__fill(uid, value)`, `mcp__chrome-devtools__fill_form(...)`.
- Confirm the expected state change with `mcp__chrome-devtools__wait_for(text)`
  and a fresh snapshot. Assert the *behavior you changed*, not just "no crash":
  if you fixed a validation rule, submit the boundary value.
- Screenshot before/after for the report:
  `mcp__chrome-devtools__take_screenshot()`.

### 3. Check the browser console

```
mcp__chrome-devtools__list_console_messages()
```

Pass criteria: **zero new errors or warnings** attributable to your change.
Pre-existing noise is reported, not silently ignored.

### 4. Check network activity when data is involved

```
mcp__chrome-devtools__list_network_requests()
```

Look for failed requests (4xx/5xx), unexpected request storms, or calls that
should have been eliminated by your change.

### 5. (When performance matters) Run a trace

For changes to page load, large lists, images, or layout:

```
mcp__chrome-devtools__performance_start_trace()
# ...reload / interact...
mcp__chrome-devtools__performance_stop_trace()
```

Audit Core Web Vitals (LCP, INP, CLS). For a full audit use
`mcp__chrome-devtools__lighthouse_audit`.

## Reporting

Every report must contain exactly one of:

- `Verified: <what you exercised in the browser and what it showed>`
- `Unverified: edited but not verified because <reason>` (e.g., dev server
  cannot start in this environment)

Quote failures verbatim. "Mostly working" is not a status.

## Notes

- If the change is behind auth, authenticate first (see the
  `e2e-testing-framework` skill's Step 0 pattern; test credentials live in
  `dev/test-credentials.json` or `.env.test`).
- If Chrome DevTools MCP is not connected, say so explicitly and fall back to
  the strongest available check (test suite → typecheck) — and label the
  result `Unverified` for browser behavior.
- For full user-journey testing (multi-step flows, multi-user), use the
  `e2e-testing-framework` skill instead; this skill is the fast loop for a
  single change.
