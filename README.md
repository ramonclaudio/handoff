<p align="center">
  <img src=".github/assets/logo.png" alt="Handoff" width="400">
</p>

<p align="center">
  <strong>Medical-grade session continuity for AI coding assistants.</strong>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#sbar-framework">SBAR Framework</a>
</p>

---

Like hospital shift changes, bad handoffs kill projects. This plugin ensures the incoming AI session has full situational awareness: what's done, what failed (and WHY), what to watch out for, and exactly where to resume.

**The AI has no memory.** You remember what you were working on. Claude doesn't. This is Claude's memory.

## Installation

| Method | Install | Invoke |
|--------|---------|--------|
| **Plugin** | `/plugin install handoff@ramonclaudio-handoff` | `/handoff:run start` |
| **Skill** | `cp -r skills/handoff ~/.claude/skills/` | `/handoff start` |
| **Agent** | `cp agents/handoff.md ~/.claude/agents/` | "Use handoff agent" |

## Usage

```
init      Create .handoff/ structure
start     Gather context, output read-back, wait for confirmation
end       Run health checks, archive state, validate handoff quality
status    Quick status check
```

## Structure

```
.handoff/
├── CONTEXT.md     # Permanent: stack, commands, critical paths, gotchas
├── HANDOFF.md     # Session: severity, health, done, failed, blockers, resume
└── sessions/      # Archived handoffs with timestamps
```

## How It Works

### START

1. Find last session timestamp
2. Read CONTEXT.md (project identity)
3. Read HANDOFF.md (session state)
4. Get commits/PRs/issues since last session
5. Check for drift (state changed since handoff?)
6. Output structured read-back
7. **Wait for confirmation**

### END

1. Archive current HANDOFF.md
2. Run health checks (build/test/lint)
3. Capture git state
4. Document: done, failed (with WHY), blockers, watch-outs
5. Set severity and resume point
6. Validate handoff quality
7. Confirm

## SBAR Framework

Adapted from medical handoffs:

| Component | Code Equivalent |
|-----------|-----------------|
| **S**ituation | Severity + current git state |
| **B**ackground | CONTEXT.md + commits/PRs since |
| **A**ssessment | Health status + blockers + failures |
| **R**ecommendation | Resume point + watch-out-for |

## Severity Levels

| Level | When | Meaning |
|-------|------|---------|
| 🔴 CRITICAL | Production down, security issue | Drop everything |
| 🟡 IN PROGRESS | Mid-feature, tests failing | Continue current work |
| 🟢 READY | All green, clean state | Pick up new work |

## HANDOFF.md Structure

```markdown
# Handoff

> Session: 2026-01-11 14:30
> Severity: 🟡 IN PROGRESS

## Health
| Check | Status | Detail |
|-------|--------|--------|
| Build | ✓ | pass |
| Tests | ✗ | 2 failing |
| Lint | ✓ | clean |

## Git
- Branch: feature/auth
- Status: 3 modified

## Done
- [x] Implemented login flow (PR #42)

## Failed
### Token refresh race condition
- **Tried:** Mutex lock
- **Error:** Deadlock in async context
- **Why:** Can't hold mutex across await
- **Need:** Actor model or queue

## Blockers
- [ ] Waiting for OAuth credentials

## Watch Out For
- Token expires after 1h in dev
- Hot reload breaks on config changes

## Resume
**Next:** Implement refresh in lib/auth.ts:67
**Files:** lib/auth.ts, hooks/useAuth.ts
**Context:** User auth works, need to handle token expiry
```

## Requirements

- Claude Code 2.1+
- Git
- Optional: `gh` (GitHub CLI), Linear MCP

## License

MIT
