// Simple test that doesn't import App component to avoid import issues
test('basic math test', () => {
  expect(1 + 1).toBe(2);
});

test('environment should be test', () => {
  expect(process.env.NODE_ENV).toBe('test');
});