---
# Example conditional rule - only applies to files matching these paths
# Remove or modify the paths array to change when this rule applies
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
---

# Example Rule

This is an example conditional rule. Rules in `.claude/rules/` are automatically loaded with the same priority as CLAUDE.md.

## How Rules Work

- Rules without `paths` frontmatter apply globally
- Rules with `paths` frontmatter only apply when working with matching files
- Use glob patterns like `src/**/*.ts` to target specific file types

## Creating Your Own Rules

1. Create a new `.md` file in `.claude/rules/`
2. Add YAML frontmatter with `paths` if you want conditional activation
3. Write your rules in markdown

## Example Use Cases

- **Code style rules**: Apply TypeScript conventions only to `.ts` files
- **Testing rules**: Apply testing patterns only to `**/*.test.ts` files
- **Security rules**: Apply security checks to `src/api/**/*.ts` files

Delete this example file and create your own project-specific rules.
