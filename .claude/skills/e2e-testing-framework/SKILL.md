# E2E Testing Framework

**Auto-activates when**: Writing E2E tests, working on test tasks, mentioning Chrome MCP or browser testing

## Overview

Comprehensive end-to-end testing framework using Chrome DevTools MCP for browser automation. This skill ensures all E2E tests follow mandatory structure: Step 0 authentication verification, step-by-step execution with visibility, fail-fast behavior, and rich completion reports.

## Core Philosophy

E2E tests simulate real user interactions through browser automation, verifying complete workflows from authentication through feature completion. Every test MUST follow the four-pillar structure defined below.

## Prerequisites

Before implementing E2E tests, verify:

1. **Chrome DevTools MCP Installation**
   ```bash
   # Check if installed
   claude mcp list | grep chrome-devtools

   # If not installed, ASK USER for permission first
   claude mcp add chrome-devtools npx chrome-devtools-mcp@latest
   ```

2. **Test Credentials Setup**
   - Test credentials stored in `.env.test` (NOT committed to version control)
   - Environment variables: `TEST_USER_EMAIL`, `TEST_USER_PASSWORD`, etc.

3. **Dev Server Running**
   - Application must be running locally (usually `npm run dev`)
   - Verify server responds before starting tests

## Mandatory Test Structure (Four Pillars)

### Pillar 1: Step 0 - Authentication Context Verification (ALWAYS FIRST)

**Requirement**: Every test MUST verify authentication context before testing features.

**Why**: Ensures protected features have required authentication context. Prevents wasted time testing features that require auth when user isn't authenticated.

**Implementation**:
```markdown
### Step 0: Verify Authentication Context

**Action**: Navigate to /app and verify authenticated state

**MCP Tools**:
- `mcp__chrome-devtools__navigate_page(url: http://localhost:3000/app)`
- `mcp__chrome-devtools__take_snapshot()`
- `mcp__chrome-devtools__list_console_messages()`

**Expected**:
- User avatar visible
- Settings menu accessible
- No redirect to /auth/sign-in
- No authentication errors in console

**Pass Criteria**: ✅ All auth UI elements present

**Fail-Fast**: If auth context unavailable, STOP immediately and report failure
```

**Common Auth Verification Patterns**:
- Check for user avatar/profile elements
- Verify authenticated nav items visible
- Confirm no redirect to login page
- Check console for auth errors

### Pillar 2: Step-by-Step Execution with Visibility

**Requirement**: Each test action logged as discrete numbered step with full visibility.

**Why**: Makes debugging easy - see exactly where test failed. Provides clear audit trail of test execution.

**Every Step Must Show**:
1. **Step number and description**: "Step 1: Navigate to Create Quote"
2. **Action taken**: Document Chrome MCP tool used
3. **Expected outcome**: What should happen
4. **Actual outcome**: What snapshot/tool returned
5. **Pass/Fail status**: ✅ or ❌

**Implementation Pattern**:
```markdown
### Step 1: Navigate to New Quote Page

**Action**: Click "New Quote" navigation item

**MCP Tools**:
- `mcp__chrome-devtools__click(uid: [uid from snapshot])`
- `mcp__chrome-devtools__wait_for(text: "Create New Quote")`
- `mcp__chrome-devtools__take_snapshot()`

**Expected**:
- Page URL changes to /app/quotes/new
- "Create New Quote" heading visible
- Form fields displayed

**Actual**: [Document what actually happened]

**Status**: ✅ PASS

---
```

**Best Practices**:
- Always take snapshot AFTER action before asserting state
- Use `wait_for()` instead of arbitrary timeouts
- Document UIDs used for reproducibility
- Number steps sequentially (Step 0, Step 1, Step 2, etc.)

### Pillar 3: Fail-Fast Behavior (MANDATORY)

**Requirement**: Test MUST stop immediately on first failed step.

**Why**: Prevents cascading failures, wasted execution time, and confusing error messages.

**Implementation**:
- Upon ANY assertion failure, immediately:
  1. Log failure details
  2. Generate completion report
  3. STOP execution - skip remaining steps
  4. Display clear message: `**Test Failed at Step X** - Remaining steps skipped`

**Example**:
```
Step 2: Fill Quote Form
**Status**: ❌ FAIL - Submit button not found (expected uid=123 not in snapshot)

**Test Failed at Step 2** - Remaining steps skipped

Generating completion report...
```

**Never**:
- Continue executing after a failure
- Try to "work around" failures
- Execute remaining steps "just to see"

### Pillar 4: Rich Completion Reports (MANDATORY)

**Requirement**: Every test generates comprehensive completion report (success OR failure).

**Report Structure**:

```markdown
## E2E Test Results: [Test Name]

### Summary
- Total Steps: 5
- Steps Executed: 3
- Passed: 2 ✅
- Failed: 1 ❌
- Status: **FAILED**

### Step Results
- Step 0: ✅ Authentication verified
- Step 1: ✅ Navigation successful
- Step 2: ❌ Form submission failed - submit button not found
- Step 3: ⏭️ Skipped (fail-fast)
- Step 4: ⏭️ Skipped (fail-fast)

### Recommendations
- [ ] Check if submit button UID changed in recent updates
- [ ] Verify form validation isn't blocking submit button
- [ ] Review snapshot at Step 2 for actual button UID

### Root Cause Analysis
**Primary Issue**: Submit button UID mismatch

**Likely Cause**: Recent component refactor changed button structure

**Fix Suggestions**:
1. Update test to use new button UID from latest snapshot
2. Check `components/quotes/QuoteForm.jsx:45` for button changes
3. Consider using `wait_for()` text match instead of UID

### Console Messages Reviewed
[Paste relevant console output]

### Network Activity
[List any failed requests or notable API calls]
```

**For Passing Tests**:
- Still include recommendations for improvements
- Suggest edge cases to test
- Note any flaky behavior observed

**For Failing Tests**:
- Root cause analysis (what went wrong)
- Specific file/line number suggestions
- Quick fixes to try
- Diagnostic steps

## Test Documentation Location

All E2E test procedures documented in task markdown files:
- Location: `docs/delivery/<PBI-ID>/<TASK-ID>.md`
- Section: `## E2E Test Procedure`
- Includes: Test steps, credentials reference, completion report template

## Common Testing Patterns

### Pattern 1: Form Submission
```markdown
1. Navigate to form page
2. Take snapshot to get form field UIDs
3. Fill form using `fill_form()` with multiple fields
4. Verify validation (if applicable)
5. Click submit
6. Wait for success message
7. Verify redirect/state change
8. Check console for errors
```

### Pattern 2: Multi-User Testing
```markdown
1. Open multiple browser tabs (one per user)
2. Authenticate each tab separately
3. Use `select_page()` to switch between tabs
4. Execute actions from different user perspectives
5. Verify state updates across all tabs
6. Cross-verify each user sees correct data
```

### Pattern 3: List/Grid Interactions
```markdown
1. Navigate to list view
2. Verify list loads (check for loading states)
3. Snapshot to get item UIDs
4. Click specific item
5. Verify detail view
6. Test back navigation
7. Verify list state preserved
```

## Resources

For detailed reference, see:
- **[Chrome MCP Tools Reference](./resources/chrome-mcp-tools.md)** - Complete tool documentation
- **[E2E Test Template](./resources/e2e-test-template.md)** - Full example test
- **[Completion Report Template](./resources/completion-report-template.md)** - Report format
- **[Troubleshooting Guide](./resources/troubleshooting.md)** - Common issues and fixes

## E2E Test Completion Criteria

An E2E test task cannot be marked "Done" unless:

1. ✅ Step 0 (authentication verification) implemented
2. ✅ All steps use step-by-step logging with visibility
3. ✅ Fail-fast behavior implemented
4. ✅ Rich completion report generated (for both success and failure)
5. ✅ All artifacts captured (snapshots, console, network)
6. ✅ Test verifies all Conditions of Satisfaction
7. ✅ Test passes consistently (no flakiness)
8. ✅ Test documented in PBI task list

## Integration with PBI Workflow

- **During Planning**: Include E2E test task at end of task breakdown
- **During Implementation**: E2E test is LAST task before PBI review
- **Before "InReview"**: E2E test must pass
- **Before "Done"**: Review completion report, address recommendations

## Quick Reference

**Navigate**: `mcp__chrome-devtools__navigate_page(url)`
**Snapshot**: `mcp__chrome-devtools__take_snapshot()`
**Click**: `mcp__chrome-devtools__click(uid)`
**Fill**: `mcp__chrome-devtools__fill(uid, value)`
**Wait**: `mcp__chrome-devtools__wait_for(text, timeout?)`
**Console**: `mcp__chrome-devtools__list_console_messages()`
**Network**: `mcp__chrome-devtools__list_network_requests()`

Always use UIDs from snapshots, never guess element selectors.
