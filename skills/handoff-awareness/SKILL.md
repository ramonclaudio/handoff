---
name: handoff-awareness
description: Session continuity for AI coding sessions. Use when context window is filling up, hitting token limits, need to continue later, preserve progress, document failures, or switch to another machine. Triggers on mentions of "handoff", "session", "context limit", "continue tomorrow", or "save progress".
---

# Handoff Awareness

Provides session continuity awareness for AI coding sessions. Use this skill to maintain context across sessions and prevent loss of progress.

## When to Use

This skill activates when:
- Working on a long coding session that might hit context limits
- Encountering errors or failures that should be documented
- Making important decisions that need to be preserved
- The user mentions "handoff", "session", "context", or "continuity"
- Starting work and needing to gather previous context

## Key Behaviors

### At Session Start
- Check for `.handoff/` or `~/obsidian/projects/<project>/` directories
- If handoff files exist, remind user to run `/handoff start`
- Read HANDOFF.md to understand where to resume

### During Session
- Document failures immediately with:
  - What was attempted
  - The exact error
  - Why it failed (root cause)
  - What would fix it
- Track files modified with line numbers
- Record decisions with reasoning and alternatives considered

### At Session End
- Remind user to run `/handoff end` before ending
- Ensure HANDOFF.md has clear resume point with:
  - Specific next action (file:line reference)
  - Files to read first
  - Context for why this is the next step

## Handoff File Locations

```
.handoff/                    # Project-local (default)
├── CONTEXT.md              # Permanent project knowledge
├── HANDOFF.md              # Session state
└── sessions/               # Archived handoffs

~/obsidian/projects/<project>/  # Alternative (Obsidian vault)
├── CONTEXT.md
├── HANDOFF.md
└── sessions/
```

## Anti-Bloat Guidelines

**DO include:**
- Full commit messages (body, not just subject)
- Full PR bodies (not just titles)
- Specific failure details with root cause
- Files with line numbers
- Exact resume actions

**DON'T include:**
- File contents (can be read on demand)
- More than 10 commits
- Historical sessions in main files
- Verbose explanations

## Failure Documentation Format

Bad:
```
❌ Auth didn't work
```

Good:
```
### ❌ JWT token refresh
- **Attempted:** Added refresh logic in useAuth hook
- **Error:** Token expired still appears after refresh
- **Why:** Refresh happens async, component re-renders before token updates
- **Would need:** Suspense boundary or loading state during refresh
```

## Resume Point Format

Bad:
```
**Next:** Continue working on auth
```

Good:
```
**Next:** Add Suspense boundary around AuthProvider in app/_layout.tsx:12
**Files to read:** lib/auth.ts:45-60, app/_layout.tsx
**Context:** Token refresh is async, need to prevent render during refresh
```

## Commands Reference

| Command | Action |
|---------|--------|
| `/handoff` | Auto-detect start or end |
| `/handoff start` | Gather context (4 parallel agents) |
| `/handoff end` | Archive + update (5 parallel agents) |
| `/handoff status` | Quick status check |
| `/handoff init` | Initialize in current project |
