---
name: handoff-awareness
description: |
  Session continuity for AI coding sessions. Use this skill when the user says "handoff", "session continuity", "context is full", "continue tomorrow", "save my progress", "where did I leave off", "pick up where I left off", "checkpoint this session", "archive my work", or mentions hitting token/context limits. Also use when documenting failures that should persist across sessions, making architectural decisions that need to be recorded, or noticing the conversation is getting long.
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
- Check for `.handoff/` directory in project root
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

## Handoff File Location

```
.handoff/                    # Project root
├── CONTEXT.md              # Permanent project knowledge
├── HANDOFF.md              # Session state
├── sessions/               # Archived handoffs
└── specs/                  # Feature specifications (optional)
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

## Quality Validation

Before ending a session, validate HANDOFF.md meets these requirements:

**REQUIRED (fail validation if missing):**
- Resume section has specific `file:line` reference
- Files to read list is non-empty
- Status is one of: 🟢 Ready, 🟡 In Progress, 🔴 Blocked

**WARNINGS (report but allow):**
- File exceeds 120 lines (bloat risk)
- Resume is vague ("continue working on X" without file:line)
- No failures documented despite errors occurring in session

## Decision Gates

**START workflow:** After gathering context, ALWAYS present a summary and ask for user approval before executing the resume action. Never auto-execute.

**END workflow:** After agents update files, run validation. If validation fails, fix issues before allowing session to end.

## Commands Reference

| Command | Action |
|---------|--------|
| `/handoff` | Auto-detect start or end |
| `/handoff start` | Gather context (4 parallel agents) |
| `/handoff end` | Archive + update (5 parallel agents) + validation |
| `/handoff status` | Quick status check |
| `/handoff init` | Initialize in current project |

## Model Selection

| Task | Model | Why |
|------|-------|-----|
| Git, gh, packages | sonnet | Fast, structured data |
| Issue queries | sonnet | Structured data |
| Context analysis | opus | Quality reasoning |
| Validation | opus | Catch subtle issues |
