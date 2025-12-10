---
name: react-hooks
version: 1.0.0
tokens: ~750
confidence: high
sources:
  - https://react.dev/reference/react/hooks
  - https://react.dev/learn/rules-of-hooks
last_validated: 2025-01-10
next_review: 2025-01-24
tags: [react, hooks, frontend, state]
---

## When to Use

Apply when managing state, side effects, context, or refs in React functional components.

## Patterns

### Pattern 1: useState with Objects
```typescript
// Source: https://react.dev/reference/react/useState
interface FormState {
  name: string;
  email: string;
}

const [form, setForm] = useState<FormState>({ name: '', email: '' });

// Update single field (immutable)
setForm(prev => ({ ...prev, name: 'John' }));
```

### Pattern 2: useEffect Cleanup
```typescript
// Source: https://react.dev/reference/react/useEffect
useEffect(() => {
  const controller = new AbortController();

  async function fetchData() {
    const res = await fetch(url, { signal: controller.signal });
    setData(await res.json());
  }
  fetchData();

  return () => controller.abort(); // Cleanup
}, [url]);
```

### Pattern 3: useCallback for Stable References
```typescript
// Source: https://react.dev/reference/react/useCallback
const handleSubmit = useCallback((data: FormData) => {
  onSubmit(data);
}, [onSubmit]); // Only recreate if onSubmit changes

// Use in child: <Form onSubmit={handleSubmit} />
```

### Pattern 4: useMemo for Expensive Computations
```typescript
// Source: https://react.dev/reference/react/useMemo
const sortedItems = useMemo(() => {
  return items
    .filter(item => item.active)
    .sort((a, b) => a.name.localeCompare(b.name));
}, [items]); // Recompute only when items change
```

### Pattern 5: Custom Hook Pattern
```typescript
// Source: https://react.dev/learn/reusing-logic-with-custom-hooks
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debounced;
}

// Usage
const debouncedSearch = useDebounce(searchTerm, 300);
```

### Pattern 6: useRef for DOM Access
```typescript
// Source: https://react.dev/reference/react/useRef
const inputRef = useRef<HTMLInputElement>(null);

const focusInput = () => {
  inputRef.current?.focus();
};

return <input ref={inputRef} />;
```

## Anti-Patterns

- **Hooks in conditions/loops** - Call hooks at top level only
- **Missing dependencies** - Include all values used in effect/callback
- **Over-using useMemo/useCallback** - Use only when performance matters
- **Mutating state directly** - Always use setter, spread for objects/arrays

## Verification Checklist

- [ ] Hooks at component top level (not in conditions)
- [ ] All dependencies listed in dependency arrays
- [ ] useEffect has cleanup for subscriptions/timers
- [ ] Custom hooks start with `use` prefix
- [ ] No direct state mutation
