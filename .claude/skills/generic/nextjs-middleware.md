---
name: nextjs-middleware
version: 1.0.0
tokens: ~400
confidence: high
sources:
  - https://nextjs.org/docs/app/building-your-application/routing/middleware
last_validated: 2025-01-10
next_review: 2025-01-24
tags: [nextjs, middleware, auth, routing, frontend]
---

## When to Use
When you need to run code before a request completes: auth checks, redirects, headers, A/B testing.

## Patterns

### Basic Middleware
```typescript
// middleware.ts (root of project)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Runs on EVERY matched route
  return NextResponse.next();
}

// Match specific routes
export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*']
};
```

### Auth Redirect
```typescript
export function middleware(request: NextRequest) {
  const token = request.cookies.get('session');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}
```

### Add Headers
```typescript
export function middleware(request: NextRequest) {
  const response = NextResponse.next();

  // Add security headers
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');

  return response;
}
```

### Matcher Patterns
```typescript
export const config = {
  matcher: [
    // Match all paths except static files
    '/((?!_next/static|_next/image|favicon.ico).*)',
    // Match specific paths
    '/dashboard/:path*',
    '/api/:path*',
  ]
};
```

## Anti-Patterns
- Heavy computation in middleware (runs on every request)
- Database queries (use Edge-compatible clients only)
- Large dependencies (bundle size matters at edge)
- Forgetting matcher (runs on ALL routes by default)

## Verification Checklist
- [ ] Matcher configured (not running on static files)
- [ ] No heavy computation or DB calls
- [ ] Auth redirects tested
- [ ] Headers properly set
