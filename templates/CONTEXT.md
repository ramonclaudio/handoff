# Project Name

> One-line description of what this project does.

## Links

| Resource | URL |
|----------|-----|
| Repository | https://github.com/... |
| Issues | https://github.com/.../issues or Linear/Jira URL |
| Docs | https://... |
| Local | `/path/to/project` |

## Stack (Updated: YYYY-MM-DD)

| Layer | Package | Version |
|-------|---------|---------|
| Runtime | node/bun/python | x.x.x |
| Framework | next/expo/django | x.x.x |
| Database | postgres/mongodb | x.x.x |
| Auth | clerk/auth0 | x.x.x |
| Styling | tailwind/css | x.x.x |

**Package manager:** npm/yarn/pnpm/bun

## Commands

```bash
# Development
npm run dev          # Start dev server

# Build
npm run build        # Production build

# Quality
npm run lint         # Lint
npm run typecheck    # Type check
npm run test         # Run tests

# Other
npm run db:migrate   # Database migrations
npm run clean        # Reset/clean
```

## Environment Variables

**Local (.env.local):**
- `DATABASE_URL` - Database connection string
- `API_KEY` - External API key

**Production (hosting dashboard):**
- `DATABASE_URL` - Production database
- `SECRET_KEY` - Application secret

## What Never Works

| Problem | Solution |
|---------|----------|
| Hot reload breaks after X | Restart dev server |
| Build fails on CI but works locally | Clear node_modules and reinstall |
| Database connection drops | Check connection pool settings |

## Architecture Patterns

**Authentication:**
```typescript
// How auth is handled in this project
```

**Data fetching:**
```typescript
// Pattern used for API calls / database queries
```

**State management:**
```typescript
// How state is managed (context, redux, etc.)
```

## Constraints

- API rate limits: X requests/minute
- File upload max: X MB
- Known platform limitations
- Browser support requirements
