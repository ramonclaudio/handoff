# Handoff

> Session continuity for AI coding assistants.

Inspired by medical handoffs, the critical process of transferring patient care between providers. This plugin ensures nothing gets lost when switching contexts, ending sessions, or resuming work.

Two markdown files capture everything needed to continue seamlessly: what's done, what failed, and exactly where to resume.

## Installation

**Via marketplace:**
```bash
/plugin install handoff@ramonclaudio-handoff
```

**Local development:**
```bash
git clone https://github.com/ramonclaudio/handoff.git ~/Developer/handoff
claude --plugin-dir ~/Developer/handoff
```

## Quick Start

```bash
/handoff init     # Create .handoff/ structure
/handoff start    # Gather context (4 parallel agents)
# ... work ...
/handoff end      # Archive state (5 parallel agents)
/handoff clean    # Reset to clean slate
```

## Commands

| Command | Action |
|---------|--------|
| `/handoff` | Auto-detect: start or end based on context |
| `/handoff init` | Create `.handoff/` with templates |
| `/handoff start` | Gather git, PRs, issues with parallel agents |
| `/handoff end` | Archive session, update handoff files |
| `/handoff status` | Quick status check (no agents) |
| `/handoff clean` | Delete sessions, reset to templates |

## Structure

```
.handoff/
├── CONTEXT.md     # Permanent: stack, commands, gotchas
├── HANDOFF.md     # Session: git state, progress, resume point
└── sessions/      # Archived handoffs
```

Override with `$HANDOFF_DIR` environment variable.

## Parallel Agents

### START (4 agents)

| Agent | Model | Task |
|-------|-------|------|
| 1 | sonnet | Git state + full commit messages |
| 2 | sonnet | PRs with full bodies |
| 3 | sonnet | Issues (GitHub/Linear) |
| 4 | opus | Analyze context, plan resume |

### END (5 agents)

| Agent | Model | Task |
|-------|-------|------|
| 1 | sonnet | Git state + archive |
| 2 | sonnet | Package version changes |
| 3 | sonnet | Issue tracker sync |
| 4 | opus | Update HANDOFF.md |
| 5 | opus | Update CONTEXT.md |

## Key Principles

**Get full details:**
```bash
git log -10 --format='%h %s%n%b---'  # Full commit messages
gh pr list --json number,title,body   # Full PR bodies
```

**Document failures properly:**
```markdown
### ❌ JWT token refresh
- **Attempted:** Added refresh logic in useAuth hook
- **Error:** Token expired still appears after refresh
- **Why:** Refresh happens async, component re-renders before token updates
- **Would need:** Suspense boundary or loading state during refresh
```

**Be specific about resume:**
```markdown
**Next:** Add Suspense boundary around AuthProvider in app/_layout.tsx:12
**Files to read:** lib/auth.ts:45-60, app/_layout.tsx
**Context:** Token refresh is async, need to prevent render during refresh
```

## Components

| Component | Type | Invocation |
|-----------|------|------------|
| `/handoff` | Command | User types it |
| `handoff-manager` | Agent | Claude delegates or user requests |
| `handoff-awareness` | Skill | Claude auto-applies during long sessions |
| SessionStart/End | Hooks | Automatic reminders |

## Continuity Levels

| Level | Feature | When |
|-------|---------|------|
| 1 | `/rewind` | Undo recent edits |
| 2 | `--continue` | Resume paused session |
| 3 | `/handoff` | Context full, switching tools, new machine |

## Requirements

**Required:**
- Claude Code 1.0.33+
- Git

**Optional:**
- `gh` - PR details with full bodies
- Linear MCP - Issue tracking
- `jq` - JSON parsing in hooks

## License

MIT
