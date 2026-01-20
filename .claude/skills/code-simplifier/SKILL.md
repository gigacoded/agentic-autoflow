---
name: "Code Simplifier"
description: "Code refactoring, simplification, and clarity improvements while preserving functionality"
---

# Code Simplifier

**Auto-activates when**: Completing code changes, refactoring, code review, after implementing features

## Overview

Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.

**Key Principle**: Readable, explicit code over overly compact solutions.

## Core Rules

### 1. Preserve Functionality

Never change what the code does - only how it does it:
- All original features must remain intact
- All outputs must be identical
- All behaviors must be preserved
- Test before and after to verify

### 2. Apply Project Standards

Follow established coding standards from CLAUDE.md:

**JavaScript/TypeScript**:
- Use ES modules with proper import sorting
- Prefer `function` keyword over arrow functions for top-level
- Use explicit return type annotations for top-level functions
- Maintain consistent naming conventions

**React**:
- Follow proper component patterns with explicit Props types
- Use proper error handling patterns (avoid try/catch when possible)
- Prefer composition over inheritance

### 3. Enhance Clarity

Simplify code structure by:

| Do | Don't |
|----|-------|
| Reduce unnecessary nesting | Over-nest callbacks/conditionals |
| Eliminate redundant code | Duplicate logic across files |
| Use clear variable names | Use single-letter names (except loops) |
| Consolidate related logic | Scatter related code |
| Remove obvious comments | Comment every line |

**IMPORTANT**: Avoid nested ternary operators

```typescript
// ❌ Bad - nested ternary
const status = isLoading ? 'loading' : isError ? 'error' : 'success';

// ✅ Good - explicit conditionals
function getStatus() {
  if (isLoading) return 'loading';
  if (isError) return 'error';
  return 'success';
}
```

### 4. Maintain Balance

Avoid over-simplification that could:

- ❌ Reduce code clarity or maintainability
- ❌ Create overly clever solutions
- ❌ Combine too many concerns into single functions
- ❌ Remove helpful abstractions
- ❌ Prioritize "fewer lines" over readability
- ❌ Make code harder to debug or extend

**Clarity over brevity**:

```typescript
// ❌ Too compact - hard to read
const result = data?.items?.filter(x => x.active)?.map(x => x.id) ?? [];

// ✅ Explicit - easy to understand
const items = data?.items ?? [];
const activeItems = items.filter(item => item.active);
const activeIds = activeItems.map(item => item.id);
```

### 5. Focus Scope

Only refine code that has been:
- Recently modified in current session
- Explicitly requested for review
- Part of the current task

**Don't** refactor unrelated code unless asked.

---

## Refinement Process

### Step 1: Identify Modified Code

Look at files changed in current task:
- New functions/components added
- Existing code modified
- Logic that was touched

### Step 2: Analyze for Improvements

Check for:
- [ ] Unnecessary complexity or nesting
- [ ] Redundant code or abstractions
- [ ] Unclear variable/function names
- [ ] Scattered related logic
- [ ] Nested ternaries
- [ ] Missing type annotations
- [ ] Inconsistent patterns

### Step 3: Apply Standards

Reference CLAUDE.md for project-specific:
- Import ordering
- Naming conventions
- Component patterns
- Error handling approach

### Step 4: Verify Functionality

Before finalizing:
- [ ] All tests still pass
- [ ] TypeScript compiles without errors
- [ ] Behavior is unchanged
- [ ] Edge cases still handled

### Step 5: Document Changes

Only document significant changes:
- Major structural improvements
- Pattern changes that affect understanding
- Removed abstractions and why

---

## Common Patterns

### Flatten Nested Conditionals

```typescript
// ❌ Before
function processUser(user: User) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        return doSomething(user);
      }
    }
  }
  return null;
}

// ✅ After - early returns
function processUser(user: User) {
  if (!user) return null;
  if (!user.isActive) return null;
  if (!user.hasPermission) return null;

  return doSomething(user);
}
```

### Extract Complex Conditions

```typescript
// ❌ Before
if (user.role === 'admin' || (user.role === 'editor' && user.department === 'content')) {
  // ...
}

// ✅ After
const isAdmin = user.role === 'admin';
const isContentEditor = user.role === 'editor' && user.department === 'content';
const canEdit = isAdmin || isContentEditor;

if (canEdit) {
  // ...
}
```

### Simplify State Updates

```typescript
// ❌ Before - multiple setState calls
setLoading(true);
setError(null);
setData(null);

// ✅ After - single state object or reducer
setState({ loading: true, error: null, data: null });
```

### Use Descriptive Function Names

```typescript
// ❌ Before
function process(items: Item[]) {
  return items.filter(i => i.x > 0).map(i => i.id);
}

// ✅ After
function getActiveItemIds(items: Item[]): string[] {
  const activeItems = items.filter(item => item.quantity > 0);
  return activeItems.map(item => item.id);
}
```

### Prefer Named Exports

```typescript
// ❌ Before
export default function MyComponent() { ... }

// ✅ After
export function MyComponent() { ... }
```

---

## When to Simplify

### Always Simplify

- After implementing a new feature
- After fixing a bug
- During code review
- When touching legacy code

### Don't Simplify

- Code outside current task scope
- Working code with no clarity issues
- During time-critical fixes (do it after)
- Third-party or generated code

---

## Quick Checklist

Before marking code complete:

- [ ] No nested ternaries
- [ ] No deeply nested conditionals (max 2-3 levels)
- [ ] All functions have clear names
- [ ] Related logic is grouped together
- [ ] No redundant abstractions
- [ ] Type annotations on public functions
- [ ] Consistent with CLAUDE.md standards
- [ ] Tests still pass
