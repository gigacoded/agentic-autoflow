# Commit Message Format

All git commits must follow this format.

## Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Type

Must be one of:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc (no code change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding tests
- `chore`: Maintenance tasks

## Scope

The scope should be the area of the codebase:
- `backend`: Convex backend changes
- `frontend`: Next.js frontend changes
- `ui`: UI component changes
- `auth`: Authentication changes
- `api`: API endpoint changes

## Subject

- Use imperative mood: "add" not "added" or "adds"
- Don't capitalize first letter
- No period at the end
- Maximum 50 characters

## Examples

**Good**:
```
feat(backend): add user profile query

Created getUserProfile query that fetches user data
with related posts and comments.

Closes #123
```

```
fix(ui): resolve button hover state issue

The primary button wasn't showing hover state due to
incorrect CSS specificity.
```

```
refactor(auth): simplify token validation logic
```

**Bad**:
```
Updated stuff
```

```
Fixed bug
```

```
WIP
```

## Body (Optional)

- Explain WHAT and WHY, not HOW
- Wrap at 72 characters
- Leave blank line after subject

## Footer (Optional)

- Reference issues: `Closes #123`, `Fixes #456`
- Breaking changes: `BREAKING CHANGE: description`

## Co-Authoring

When using AI assistance, add:
```
🤖 Generated with [Gemini CLI](https://github.com/google-gemini/gemini-cli)

Co-Authored-By: Gemini <noreply@google.com>
```
