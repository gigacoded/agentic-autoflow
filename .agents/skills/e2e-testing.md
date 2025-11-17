# E2E Testing Framework

You are working with E2E testing using Chrome DevTools MCP for browser automation.

## Core Principles

1. **Authentication First**: Step 0 is ALWAYS authentication verification
2. **Fail-Fast**: Stop immediately on errors, don't continue
3. **Rich Reporting**: Provide detailed completion reports
4. **Real Browser**: Use Chrome DevTools MCP, not mocks

## Chrome DevTools MCP Integration

**IMPORTANT**: This project uses Chrome DevTools MCP for E2E testing.

### Available MCP Tools

- `chrome_navigate`: Navigate to URL
- `chrome_click`: Click elements
- `chrome_screenshot`: Capture screenshots
- `chrome_evaluate`: Run JavaScript

### Example Test Structure

```typescript
// test/e2e/auth.test.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('Step 0: Verify auth flow', async ({ page }) => {
    // Navigate
    await page.goto('http://localhost:3000');

    // Click sign in
    await page.click('[data-testid="sign-in"]');

    // Verify redirect
    await expect(page).toHaveURL(/.*auth.*/);
  });
});
```

## Test Organization

```
test/
├── e2e/
│   ├── auth.test.ts           # Authentication tests
│   ├── core-flows.test.ts     # Main user flows
│   └── edge-cases.test.ts     # Error scenarios
└── setup/
    └── global-setup.ts        # Test environment setup
```

## Best Practices

1. **Always Start with Step 0**: Verify auth before other tests
2. **Use data-testid**: More stable than CSS selectors
3. **Screenshot on Failure**: Capture state for debugging
4. **Test Real Scenarios**: User journeys, not implementation details
5. **Keep Tests Independent**: Each test should work alone

## Completion Report Format

After completing E2E tests, provide:

```
## E2E Test Report

**Status**: ✅ Complete

**Tests Created**:
- ✅ Step 0: Authentication verification
- ✅ Core flow: User registration
- ✅ Edge case: Invalid email handling

**Coverage**:
- Authentication: 100%
- Registration: 100%
- Error handling: 100%

**Next Steps**:
1. Run tests locally: `npm run test:e2e`
2. Verify Chrome DevTools MCP is configured
3. Add screenshots to test failures
```

## References

- [Chrome DevTools MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/chrome-devtools)
- [Playwright Documentation](https://playwright.dev)
