---
name: api-validation
version: 1.0.0
tokens: ~600
confidence: high
sources:
  - https://zod.dev/
  - https://express-validator.github.io/docs/
last_validated: 2025-01-10
next_review: 2025-01-24
tags: [api, validation, zod, backend]
---

## When to Use

Apply when validating API request inputs: body, query params, path params, and headers.

## Patterns

### Pattern 1: Zod Schema Validation
```typescript
// Source: https://zod.dev/
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Min 8 characters'),
  name: z.string().min(1, 'Name required').max(100),
  role: z.enum(['user', 'admin']).default('user'),
});

type CreateUserDto = z.infer<typeof CreateUserSchema>;
```

### Pattern 2: Request Handler with Validation
```typescript
// Source: https://zod.dev/
export async function POST(request: NextRequest) {
  const body = await request.json();
  const result = CreateUserSchema.safeParse(body);

  if (!result.success) {
    return NextResponse.json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid request body',
        details: result.error.issues.map(issue => ({
          field: issue.path.join('.'),
          message: issue.message,
        })),
      },
    }, { status: 400 });
  }

  // result.data is fully typed
  const user = await createUser(result.data);
  return NextResponse.json(user, { status: 201 });
}
```

### Pattern 3: Query Params Validation
```typescript
// Source: https://zod.dev/
const ListQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sort: z.enum(['asc', 'desc']).default('desc'),
  search: z.string().optional(),
});

export async function GET(request: NextRequest) {
  const params = Object.fromEntries(request.nextUrl.searchParams);
  const result = ListQuerySchema.safeParse(params);

  if (!result.success) {
    return NextResponse.json({ error: 'Invalid query params' }, { status: 400 });
  }

  const { page, limit, sort, search } = result.data;
  // ...
}
```

### Pattern 4: Reusable Validators
```typescript
// Source: https://zod.dev/
// Common field schemas
const EmailSchema = z.string().email();
const UUIDSchema = z.string().uuid();
const DateStringSchema = z.string().datetime();
const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

// Compose schemas
const GetUserSchema = z.object({
  params: z.object({ id: UUIDSchema }),
});

const ListUsersSchema = z.object({
  query: PaginationSchema.extend({
    status: z.enum(['active', 'inactive']).optional(),
  }),
});
```

### Pattern 5: Validation Middleware
```typescript
// Source: Best practice pattern
function validate<T extends z.ZodSchema>(schema: T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
    });

    if (!result.success) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          details: result.error.issues,
        },
      });
    }

    req.validated = result.data;
    next();
  };
}

// Usage
app.post('/users', validate(CreateUserSchema), createUserHandler);
```

## Anti-Patterns

- **No validation** - Always validate external input
- **Client-only validation** - Server must validate too
- **Trusting type assertions** - Use runtime validation
- **Vague error messages** - Tell user what's wrong

## Verification Checklist

- [ ] All endpoints validate input
- [ ] Schemas use Zod for runtime + types
- [ ] Error response includes field-level details
- [ ] Query params coerced to correct types
- [ ] Default values for optional fields
