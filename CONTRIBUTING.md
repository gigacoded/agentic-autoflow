# Contributing to Claude Code Workflow Template

Thank you for your interest in improving this template! Contributions are welcome.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check existing issues to avoid duplicates
2. Open a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior

### Suggesting Improvements

We welcome suggestions for:

- Additional example skills for common tech stacks
- Hook improvements or new hooks
- Documentation clarifications
- Workflow optimizations

Open an issue to discuss before submitting large changes.

### Contributing Code

1. **Fork the repository**

2. **Create a branch**
   ```bash
   git checkout -b feature/your-improvement
   ```

3. **Make your changes**
   - Follow existing style and structure
   - Update documentation if needed
   - Test thoroughly

4. **Commit with clear messages**
   ```bash
   git commit -m "Add Python stop hook example"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-improvement
   ```

6. **Describe your changes** in the PR

## Contribution Ideas

### Example Skills

We'd love example skills for:

- **Backend**: Django, Flask, FastAPI, Spring Boot, Rails, Laravel
- **Frontend**: Vue, Svelte, Angular, Ember
- **Mobile**: React Native, Flutter, Swift, Kotlin
- **Data**: Pandas, NumPy, data pipelines
- **Infrastructure**: Terraform, Kubernetes, AWS CDK

### Hook Examples

- ESLint integration
- Prettier integration
- Language-specific type checkers (mypy, cargo check, etc.)
- Security scanning hooks
- Custom quality metrics

### Documentation

- Migration guides from other workflows
- Video tutorials
- Translation to other languages
- Real-world case studies

## Style Guide

### Markdown Documents

- Use clear headings (H1 for title, H2 for major sections)
- Include code examples where relevant
- Keep line length reasonable (wrap at 100-120 chars)
- Use `bash` for shell commands, appropriate language for code

### Skills

- Follow the example-skill structure
- Include real, working code examples
- Document both correct and incorrect patterns
- Keep focused (one skill per domain)

### Hooks

- Include comprehensive error handling
- Fail gracefully (don't break Claude Code)
- Add timeouts for external commands
- Include comments explaining logic

## Testing

Before submitting:

- [ ] Test skill activation with relevant keywords
- [ ] Verify hooks run without errors
- [ ] Check documentation for typos/broken links
- [ ] Ensure examples work as written

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on improving the template
- Give credit where due

## Questions?

Open an issue for questions or discussion!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
