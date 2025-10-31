# Chrome DevTools MCP Tools Reference

Complete reference for all Chrome DevTools MCP tools used in E2E testing.

## Core Navigation Tools

### `mcp__chrome-devtools__navigate_page(url, timeout?)`
Navigate to a URL.

**Parameters**:
- `url` (string, required): URL to navigate to
- `timeout` (number, optional): Maximum wait time in milliseconds (default: 30000)

**Returns**: Page information including URL and title

**Example**:
```javascript
mcp__chrome-devtools__navigate_page({
  url: "http://localhost:3000/app/quotes"
})
```

**Best Practices**:
- Always wait for page load before taking snapshot
- Use absolute URLs (include protocol)
- Check return value for successful navigation

---

### `mcp__chrome-devtools__navigate_page_history(navigate, timeout?)`
Navigate browser history (back/forward).

**Parameters**:
- `navigate` (string, required): "back" or "forward"
- `timeout` (number, optional): Maximum wait time

**Example**:
```javascript
mcp__chrome-devtools__navigate_page_history({
  navigate: "back"
})
```

---

### `mcp__chrome-devtools__list_pages()`
List all open browser tabs/pages.

**Returns**: Array of page objects with index, URL, and title

**Example Usage**:
```javascript
// List all tabs
const pages = mcp__chrome-devtools__list_pages()
// pages[0]: { index: 0, url: "...", title: "...", selected: true }
```

**Use Cases**:
- Multi-user testing (track which tab is which user)
- Verify URL changes after navigation
- Debug which page is currently selected

---

## Interaction Tools

### `mcp__chrome-devtools__click(uid, dblClick?)`
Click an element by its UID from snapshot.

**Parameters**:
- `uid` (string, required): Element UID from `take_snapshot()`
- `dblClick` (boolean, optional): Set true for double-click (default: false)

**Example**:
```javascript
// Get UID from snapshot first
const snapshot = mcp__chrome-devtools__take_snapshot()
// Find element UID (e.g., uid=123_5 for "Submit" button)

mcp__chrome-devtools__click({ uid: "123_5" })
```

**Best Practices**:
- ALWAYS take snapshot before clicking to get current UIDs
- UIDs change between snapshots - never reuse old UIDs
- Use `wait_for()` after click if expecting page change

---

### `mcp__chrome-devtools__fill(uid, value)`
Fill form field or select dropdown option.

**Parameters**:
- `uid` (string, required): Form element UID
- `value` (string, required): Value to fill/select

**Example**:
```javascript
// Text input
mcp__chrome-devtools__fill({
  uid: "123_10",
  value: "John Smith"
})

// Select dropdown
mcp__chrome-devtools__fill({
  uid: "123_15",
  value: "urgent" // Option value, not label
})
```

**Best Practices**:
- For selects, use option VALUE not display text
- Check field accepts input (not disabled/readonly)
- Verify validation after fill if applicable

---

### `mcp__chrome-devtools__fill_form(elements)`
Fill multiple form fields at once (more efficient).

**Parameters**:
- `elements` (array, required): Array of `{uid, value}` objects

**Example**:
```javascript
mcp__chrome-devtools__fill_form({
  elements: [
    { uid: "123_10", value: "customer@test.com" },
    { uid: "123_11", value: "#Testing123" },
    { uid: "123_12", value: "Test Customer" }
  ]
})
```

**When to Use**:
- Filling 2+ fields
- Login forms
- Multi-field forms

---

### `mcp__chrome-devtools__hover(uid)`
Hover over an element (trigger hover states, tooltips).

**Parameters**:
- `uid` (string, required): Element UID

**Example**:
```javascript
mcp__chrome-devtools__hover({ uid: "123_8" })
// Then take snapshot to verify tooltip appeared
```

---

### `mcp__chrome-devtools__drag(from_uid, to_uid)`
Drag element from one location to another.

**Parameters**:
- `from_uid` (string, required): UID of element to drag
- `to_uid` (string, required): UID of drop target

**Example**:
```javascript
mcp__chrome-devtools__drag({
  from_uid: "123_5",
  to_uid: "123_10"
})
```

---

## Verification Tools

### `mcp__chrome-devtools__take_snapshot(verbose?)`
Get accessible page structure with UIDs for all elements.

**Parameters**:
- `verbose` (boolean, optional): Include all a11y info (default: false)

**Returns**: Text representation of page with element UIDs

**Example Output**:
```
uid=428_0 RootWebArea "App Title"
  uid=428_1 button "Submit"
  uid=428_2 textbox "Email" value="test@example.com"
  uid=428_3 link "Back to Home"
```

**Best Practices**:
- Take snapshot AFTER every action
- Use UIDs from snapshot for next action
- Check snapshot for expected elements before interacting

**Common Patterns**:
```javascript
// Pattern: Navigate → Snapshot → Interact
mcp__chrome-devtools__navigate_page({ url: "..." })
const snapshot = mcp__chrome-devtools__take_snapshot()
// Find button UID in snapshot output
mcp__chrome-devtools__click({ uid: "found_uid" })
```

---

### `mcp__chrome-devtools__take_screenshot(filePath?, format?, quality?)`
Capture visual screenshot (use sparingly - snapshots are better for testing).

**Parameters**:
- `filePath` (string, optional): Path to save screenshot
- `format` (string, optional): "png", "jpeg", "webp" (default: "png")
- `quality` (number, optional): 0-100 for jpeg/webp

**When to Use**:
- Visual regression testing
- Documenting UI issues
- When a11y snapshot doesn't show visual problem

**When NOT to Use**:
- Regular element verification (use snapshot instead)
- Every step (too slow, too much data)

---

### `mcp__chrome-devtools__wait_for(text, timeout?)`
Wait for specific text to appear on page.

**Parameters**:
- `text` (string, required): Text to wait for
- `timeout` (number, optional): Max wait in milliseconds (default: 30000)

**Example**:
```javascript
// After submitting form, wait for success message
mcp__chrome-devtools__wait_for({
  text: "Quote created successfully"
})
```

**Best Practices**:
- Use after actions that trigger async updates
- Prefer this over arbitrary `sleep()` delays
- Choose unique text that only appears on success

---

## Debugging Tools

### `mcp__chrome-devtools__list_console_messages(includePreservedMessages?, pageIdx?, pageSize?, types?)`
Get console messages (logs, errors, warnings).

**Parameters**:
- `includePreservedMessages` (boolean, optional): Include messages from previous navigations
- `pageIdx` (number, optional): Pagination page number (0-based)
- `pageSize` (number, optional): Number of messages per page
- `types` (array, optional): Filter by type (["log", "error", "warn", etc.])

**Example**:
```javascript
// Get all console messages
const messages = mcp__chrome-devtools__list_console_messages()

// Get only errors
const errors = mcp__chrome-devtools__list_console_messages({
  types: ["error"]
})
```

**When to Check**:
- After authentication (check for auth errors)
- After form submission (check for validation errors)
- After API calls (check for network errors)
- In completion reports (always include console review)

**Example Pattern**:
```javascript
// After critical action, check console
mcp__chrome-devtools__click({ uid: "submit_button" })
mcp__chrome-devtools__wait_for({ text: "Success" })
const console = mcp__chrome-devtools__list_console_messages({ types: ["error", "warn"] })
// Document any errors in completion report
```

---

### `mcp__chrome-devtools__list_network_requests(includePreservedRequests?, pageIdx?, pageSize?, resourceTypes?)`
List network requests (for debugging API calls).

**Parameters**:
- `includePreservedRequests` (boolean, optional): Include requests from previous navigations
- `pageIdx` (number, optional): Pagination
- `pageSize` (number, optional): Results per page
- `resourceTypes` (array, optional): Filter by type (["xhr", "fetch", "document", etc.])

**Example**:
```javascript
// Get all XHR/fetch requests
const requests = mcp__chrome-devtools__list_network_requests({
  resourceTypes: ["xhr", "fetch"]
})
```

**When to Use**:
- Debugging API failures
- Verifying API was called
- Checking request/response data
- Diagnosing 401/403 errors

---

### `mcp__chrome-devtools__get_network_request(reqid)`
Get detailed info for specific network request.

**Parameters**:
- `reqid` (number, required): Request ID from `list_network_requests()`

**Returns**: Full request details including headers, body, response

---

### `mcp__chrome-devtools__evaluate_script(function, args?)`
Execute JavaScript in page context (use sparingly).

**Parameters**:
- `function` (string, required): JavaScript function to execute
- `args` (array, optional): Arguments to pass (must include `uid` property)

**Example**:
```javascript
mcp__chrome-devtools__evaluate_script({
  function: `() => {
    return document.title
  }`
})
```

**When to Use**:
- Extracting data not available in snapshot
- Debugging complex state
- Triggering browser-only APIs

**When NOT to Use**:
- Regular element interaction (use click/fill instead)
- Most testing scenarios (snapshot is better)

---

## Browser Management Tools

### `mcp__chrome-devtools__new_page(url, timeout?)`
Open new browser tab.

**Parameters**:
- `url` (string, required): URL to load
- `timeout` (number, optional): Max wait time

**Use Cases**:
- Multi-user testing (one tab per user)
- Testing cross-tab communication
- Parallel test scenarios

---

### `mcp__chrome-devtools__select_page(pageIdx)`
Switch to different browser tab.

**Parameters**:
- `pageIdx` (number, required): Page index from `list_pages()`

**Example Multi-User Pattern**:
```javascript
// Open 3 tabs for 3 users
mcp__chrome-devtools__new_page({ url: "http://localhost:3000" }) // Customer
mcp__chrome-devtools__new_page({ url: "http://localhost:3000" }) // Driver 1
mcp__chrome-devtools__new_page({ url: "http://localhost:3000" }) // Driver 2

// Switch between tabs
mcp__chrome-devtools__select_page({ pageIdx: 0 }) // Customer tab
// Do customer actions...
mcp__chrome-devtools__select_page({ pageIdx: 1 }) // Driver 1 tab
// Do driver actions...
```

---

### `mcp__chrome-devtools__close_page(pageIdx)`
Close a browser tab.

**Parameters**:
- `pageIdx` (number, required): Page index to close

**Note**: Cannot close the last open page

---

### `mcp__chrome-devtools__resize_page(width, height)`
Resize viewport (test responsive designs).

**Parameters**:
- `width` (number, required): Page width in pixels
- `height` (number, required): Page height in pixels

**Example**:
```javascript
// Test mobile viewport
mcp__chrome-devtools__resize_page({
  width: 375,
  height: 667
})
```

---

## Test Environment Tools

### `mcp__chrome-devtools__emulate_network(throttlingOption)`
Simulate network conditions.

**Parameters**:
- `throttlingOption` (string, required): "No emulation", "Offline", "Slow 3G", "Fast 3G", "Slow 4G", "Fast 4G"

**Example**:
```javascript
// Test offline behavior
mcp__chrome-devtools__emulate_network({
  throttlingOption: "Offline"
})

// Reset to normal
mcp__chrome-devtools__emulate_network({
  throttlingOption: "No emulation"
})
```

**Use Cases**:
- Test offline mode
- Verify loading states
- Test slow network resilience

---

### `mcp__chrome-devtools__emulate_cpu(throttlingRate)`
Simulate CPU throttling (test on slower devices).

**Parameters**:
- `throttlingRate` (number, required): 1-20x slowdown factor (1 = no throttling)

**Example**:
```javascript
// Simulate 4x slower CPU
mcp__chrome-devtools__emulate_cpu({
  throttlingRate: 4
})
```

---

## Testing Best Practices

1. **Always use snapshots after actions** - Verify state before next action
2. **Use element UIDs from snapshots** - Never guess selectors
3. **Check console after critical operations** - Catch errors early
4. **Use `wait_for()` instead of sleeps** - More reliable
5. **Document all tool usage** - Makes tests reproducible
6. **Take screenshots sparingly** - Snapshots are faster and more useful
7. **Filter network requests** - Use resourceTypes to focus on API calls

## Common Patterns

### Authentication Flow
```javascript
1. navigate_page → /auth/sign-in
2. take_snapshot → get form UIDs
3. fill_form → email + password
4. click → submit button
5. wait_for → "Dashboard" text
6. take_snapshot → verify authenticated UI
7. list_console_messages → check for auth errors
```

### Form Submission
```javascript
1. navigate_page → form URL
2. take_snapshot → get field UIDs
3. fill_form → all form fields
4. click → submit button
5. wait_for → success message
6. take_snapshot → verify result
7. list_console_messages → check for errors
8. list_network_requests → verify API call
```

### Multi-User Interaction
```javascript
1. new_page → User 1
2. new_page → User 2
3. select_page(0) → authenticate User 1
4. select_page(1) → authenticate User 2
5. select_page(0) → User 1 creates item
6. select_page(1) → User 2 sees item
7. Cross-verify state in both tabs
```
