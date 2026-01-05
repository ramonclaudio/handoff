# Handoff: Project Name

> Session: YYYY-MM-DD HH:MM
> Task: What we're working on
> Issue: #123 or PROJ-123 (if applicable)

## Status: IN PROGRESS | BLOCKED | IDLE

## Git State

- **Branch:** main | feature/branch-name
- **Status:** clean | X uncommitted changes
- **Stash:** none | X stashed
- **Open PR:** none | #N (link)

### Recent Commits
```
# Output of: git log -10 --format='%h %s%n%b---'
abc1234 feat: add user authentication

Implemented JWT-based auth with refresh tokens.
Added login/logout endpoints.
---
def5678 fix: resolve database connection issue

Connection was dropping due to pool exhaustion.
Increased pool size and added keepalive.
---
```

### Recent PRs
| PR | Title | Summary | Merged |
|----|-------|---------|--------|
| #12 | Add authentication | JWT auth with refresh | 2024-01-15 |
| #11 | Fix db connections | Pool size increase | 2024-01-14 |

## Issue Tracker

| Issue | Title | Status |
|-------|-------|--------|
| #45 | Implement user profile | In Progress |
| #46 | Add email notifications | Backlog |
| #47 | Performance optimization | Backlog |

## Done (This Session)

- [x] Set up authentication middleware
- [x] Created login/logout API endpoints
- [x] Added JWT token generation

## Failed (Don't Retry)

### ❌ Session storage with Redis
- **Attempted:** Replaced in-memory sessions with Redis
- **Error:** Connection timeouts under load
- **Why:** Redis instance is in different region, latency too high
- **Tried also:** Connection pooling, persistent connections
- **Would need:** Redis instance in same region or switch to database sessions
- **Workaround:** Using database sessions for now

## In Progress

- [ ] User profile page
  - Done: API endpoint, database schema
  - Left: Frontend form, image upload

## Decisions

| Decision | Choice | Alternatives | Reasoning |
|----------|--------|--------------|-----------|
| Session storage | Database | Redis, Memory | Redis latency issues (see Failed) |
| Auth tokens | JWT | Session cookies | Need stateless for API |

## Files Touched

| File | Lines | What Changed |
|------|-------|--------------|
| src/auth/middleware.ts | new | Auth middleware |
| src/api/auth/login.ts | new | Login endpoint |
| src/api/auth/logout.ts | new | Logout endpoint |
| src/lib/jwt.ts | 12-45 | Token generation |
| prisma/schema.prisma | 67-80 | User model updates |

## Resume

**Next:** Create profile page component at `src/pages/profile.tsx`
**Then:** Add image upload to profile using existing S3 utilities
**Files to read:** `src/lib/s3.ts:20-40`, `src/components/ImageUpload.tsx`
**Context:** S3 bucket is already configured, just need to wire up the upload
**Blockers:** None

## Session Chain (for multi-session features)

| Session | Progress |
|---------|----------|
| 2024-01-14 10:00 | Started auth, set up JWT |
| 2024-01-14 14:00 | Completed auth, started profile |
| 2024-01-15 09:00 | THIS SESSION |
