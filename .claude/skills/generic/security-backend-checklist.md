---
name: security-backend-checklist
version: 1.0.0
tokens: ~500
confidence: high
sources:
  - https://owasp.org/www-project-top-ten/
  - https://cheatsheetseries.owasp.org/
last_validated: 2025-01-10
next_review: 2025-01-24
tags: [security, backend, api, owasp]
---

## When to Use
When implementing backend APIs, database queries, authentication, or handling user input.

## Patterns

### Input Validation
```typescript
// ✅ Whitelist validation with Zod
const userSchema = z.object({
  email: z.string().email().max(255),
  age: z.number().int().min(0).max(150),
});
const validated = userSchema.parse(userInput);
```

### SQL Injection Prevention
```typescript
// ❌ NEVER - string concatenation
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ ALWAYS - parameterized queries
const query = 'SELECT * FROM users WHERE id = $1';
await db.query(query, [userId]);
```

### Secrets Management
```typescript
// ❌ NEVER
const apiKey = 'sk-1234567890abcdef';

// ✅ ALWAYS
const apiKey = process.env.API_KEY;
// + .env in .gitignore
```

### Error Handling
```typescript
// ❌ Exposes internals
catch (error) {
  return res.status(500).json({ error: error.stack, query: sql });
}

// ✅ Safe response
catch (error) {
  logger.error('DB error', { error, userId });
  return res.status(500).json({ error: 'Internal server error' });
}
```

## Anti-Patterns
- Trusting client-side validation alone
- Storing passwords in plaintext (use bcrypt/argon2)
- Hardcoded secrets in code
- Exposing stack traces in production
- Missing rate limiting on auth endpoints

## Verification Checklist
- [ ] All user input validated server-side
- [ ] Parameterized queries everywhere (no string concat)
- [ ] No secrets in code (all from env vars)
- [ ] Passwords hashed (bcrypt/argon2)
- [ ] Auth checked on EVERY endpoint
- [ ] Rate limiting on login/register
- [ ] Error responses don't leak internals
- [ ] HTTPS enforced
