# Jest Testing Guide

This project uses Jest for unit testing. Jest is a popular testing framework for JavaScript/TypeScript applications with excellent TypeScript support through ts-jest.

## Installation

Jest and related dependencies have been installed. If you need to reinstall, run:

```bash
npm install --save-dev jest @types/jest ts-jest babel-jest @babel/preset-typescript @babel/preset-env @babel/preset-react
```

## Running Tests

### Run all tests
```bash
npm test
```

### Run tests in watch mode (re-run tests as files change)
```bash
npm run test:watch
```

### Run tests with coverage report
```bash
npm run test:coverage
```

## Project Test Files

### Firebase Configuration Tests
- **File**: `app/(tabs)/firebaseConfig.test.ts`
- **Coverage**: Tests for Firebase initialization, module exports, and security best practices
- **Test Cases**:
  - ✓ Module structure and exports
  - ✓ Security best practices (no API key exposure)
  - ✓ Firestore integration

## Writing New Tests

### Basic Test Structure

```typescript
describe('Feature Name', () => {
  describe('Specific functionality', () => {
    it('should do something', () => {
      // Arrange - setup
      const input = 'test';
      
      // Act - perform action
      const result = processInput(input);
      
      // Assert - check result
      expect(result).toBe('expected');
    });
  });
});
```

### Mocking Examples

```typescript
// Mock a module
jest.mock('firebase/firestore', () => ({
  getFirestore: jest.fn(() => ({ type: 'firestore' })),
}));

// Mock a function
const mockFn = jest.fn();
mockFn.mockReturnValue('value');
mockFn.mockResolvedValue(Promise.resolve('async value'));

// Reset mocks between tests
beforeEach(() => {
  jest.clearAllMocks();
});
```

### Common Jest Matchers

```typescript
// Equality
expect(value).toBe(5);              // strict equality
expect(value).toEqual({ a: 1 });    // deep equality
expect(value).toStrictEqual(value); // strict deep equality

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(5);
expect(value).toBeLessThan(10);
expect(value).toBeCloseTo(0.3, 5);

// Strings
expect(text).toMatch(/pattern/);
expect(text).toContain('substring');

// Arrays
expect(array).toContain(item);
expect(array).toHaveLength(5);

// Objects
expect(obj).toHaveProperty('key');
expect(obj).toHaveProperty('key', value);

// Exceptions
expect(() => fnThatThrows()).toThrow();
expect(() => fnThatThrows()).toThrow(Error);

// Functions
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith(arg);
expect(mockFn).toHaveBeenCalledTimes(2);
```

## Test File Naming Conventions

Jest automatically finds and runs test files with these naming patterns:
- `*.test.ts` or `*.test.tsx`
- `*.spec.ts` or `*.spec.tsx`
- Files in `__tests__` directory

## Configuration

The Jest configuration is in `jest.config.js`:
- Uses `ts-jest` preset for TypeScript support
- Configured for Node.js test environment
- Includes module path mapping for `@/*` imports
- Excludes node_modules, .expo, and build directories from coverage

## Debugging Tests

### Run a specific test file
```bash
npm test -- app/(tabs)/firebaseConfig.test.ts
```

### Run tests matching a pattern
```bash
npm test -- --testNamePattern="should export"
```

### Run tests in verbose mode
```bash
npm test -- --verbose
```

### Debug with Node inspector
```bash
node --inspect-brk node_modules/.bin/jest --runInBand
```

## Best Practices

1. **Keep tests focused**: Each test should test one thing
2. **Use descriptive names**: Test names should clearly describe what they test
3. **Follow AAA pattern**: Arrange, Act, Assert
4. **Mock external dependencies**: Mock Firebase, APIs, and other external services
5. **Avoid testing implementation details**: Test behavior, not how it's done
6. **Keep tests independent**: Don't rely on the order tests run
7. **Use beforeEach/afterEach**: Clean up state between tests
8. **Test edge cases**: Consider null, undefined, empty values

## Resources

- [Jest Documentation](https://jestjs.io/)
- [ts-jest Documentation](https://kulshekhar.github.io/ts-jest/)
- [Testing Library](https://testing-library.com/)

## Troubleshooting

### Tests not found
- Make sure test files follow the naming convention (`*.test.ts` or `*.spec.ts`)
- Check the `testMatch` pattern in `jest.config.js`

### Module resolution errors
- Verify module paths in `jest.config.js` moduleNameMapper
- Check that TypeScript paths in `tsconfig.json` match Jest config

### Firebase mock errors
- Ensure Firebase modules are properly mocked before imports
- Use `jest.mock()` at the top of test files
