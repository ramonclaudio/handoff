# <project-name>

> <One-line description>

## Links

| Resource | URL |
|----------|-----|
| GitHub | https://github.com/username/repo |
| Linear | https://linear.app/team/project/... |
| Local | `/Users/username/Developer/<project>` |
| Docs | `~/Notes/dev/projects/<project>/` |

## Stack (Updated: YYYY-MM-DD)

| Layer | Package | Version |
|-------|---------|---------|
| Runtime | node/bun | x.x.x |
| Framework | next/expo | x.x.x |
| Backend | convex/supabase | x.x.x |
| Auth | better-auth/clerk | x.x.x |
| Styling | tailwind | x.x.x |

**Runtime:** npm/bun (check lockfile)

## Commands

```bash
# Development
npm run dev          # Start dev server
npm run convex       # Backend (if separate)

# Build
npm run build        # Production build
npm run ios          # iOS build (Expo)

# Quality
npm run lint         # Lint
npm run typecheck    # Type check
npm run test         # Tests

# Reset
npm run clean        # Nuclear reset
```

## Environment Variables

**Local (.env.local):**
- `VAR_NAME` - description

**Server (dashboard):**
- `VAR_NAME` - description

## What Never Works

| Problem | Solution |
|---------|----------|
| Example issue | How to fix/avoid |

## Architecture Patterns

**Pattern Name:**
```typescript
// Code example showing the pattern
```

## Constraints

- Rate limits, quotas
- Platform limitations
- Known issues
