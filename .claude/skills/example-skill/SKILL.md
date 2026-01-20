---
name: "Example Skill"
description: "Template skill showing recommended structure - replace with your domain-specific patterns"
---

# Example Skill

**Auto-activates when**: Working with [technology/domain], using keywords like "[keyword1]", "[keyword2]", or editing files in `[path]/**/*.ext`

## Overview

This is an example skill showing the recommended structure. Replace this content with your domain-specific best practices, patterns, and guidelines.

Skills are context-aware documentation that Claude references automatically when relevant. They keep your CLAUDE.md lean while providing detailed guidance when needed.

## Core Principles

List the fundamental principles for this domain:

1. **Principle 1** - Brief explanation
2. **Principle 2** - Brief explanation
3. **Principle 3** - Brief explanation

## Common Patterns

### Pattern 1: [Pattern Name]

**When to use**: Describe the scenario where this pattern applies

**Implementation**:
```typescript
// Example code showing the pattern
function examplePattern() {
  // Well-commented code
  return "example";
}
```

**Best Practices**:
- Practice 1
- Practice 2
- Practice 3

**Common Gotchas**:
- ❌ **Anti-pattern**: What to avoid and why
- ✅ **Correct approach**: What to do instead

---

### Pattern 2: [Pattern Name]

**When to use**: Describe the scenario

**Implementation**:
```typescript
// Another code example
```

**Best Practices**:
- Practice 1
- Practice 2

## Error Handling

Describe how errors should be handled in this domain:

```typescript
try {
  // Operation
} catch (error) {
  // Error handling pattern
  throw error;
}
```

## Testing Strategies

How should code in this domain be tested?

**Unit Tests**:
```typescript
describe("Feature", () => {
  it("should behave correctly", () => {
    // Test example
  });
});
```

**Integration Tests**:
- Approach 1
- Approach 2

## Performance Considerations

- Optimization 1
- Optimization 2
- When to optimize vs when to prioritize clarity

## Quick Reference

**Create [Thing]**:
```typescript
// One-liner or minimal example
```

**Update [Thing]**:
```typescript
// One-liner or minimal example
```

**Delete [Thing]**:
```typescript
// One-liner or minimal example
```

## Common Commands

```bash
# Command 1 with explanation
npm run example

# Command 2 with explanation
npm test
```

## Related Documentation

- [Official Documentation](https://example.com)
- [Best Practices Guide](https://example.com)
- Related skill: `other-skill-name`

---

## Skill Maintenance

**When to update this skill**:
- New patterns emerge from actual usage
- Breaking changes in dependencies
- Team discovers better approaches
- Common mistakes need documentation

**Keep it focused**:
- This skill should cover ONE domain/technology
- If content exceeds 600 lines, consider splitting into multiple skills
- Move large examples to `resources/` directory
