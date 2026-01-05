# Handoff

> Session continuity for AI coding assistants.

AI coding assistants have context limits. When you hit that limit mid-feature, the next session starts fresh—losing what was tried, what failed, and exactly where to resume.

Handoff solves this with two markdown files that capture everything needed to continue seamlessly.

## Installation

**Via marketplace** (recommended):
```bash
# Add the marketplace
/plugin marketplace add ramonclaudio/handoff

# Install the plugin
/plugin install handoff@ramonclaudio-handoff
```

**Local development**:
```bash
git clone https://github.com/ramonclaudio/handoff.git ~/Developer/handoff
claude --plugin-dir ~/Developer/handoff
```

## Quick Start

```bash
/handoff init     # Initialize handoff in current project
/handoff start    # Gather context with 4 parallel agents
# ... work on your feature ...
/handoff end      # Archive + update with 5 parallel agents
```

## What It Creates

```
.handoff/
├── CONTEXT.md     # Permanent project knowledge (stack, commands, gotchas)
├── HANDOFF.md     # Session state (git, progress, resume point)
└── sessions/      # Archived handoffs
```

Alternative location: `~/obsidian/projects/<project>/` (auto-detected)

Override with `$HANDOFF_DIR` environment variable.

---

## How It Works

This plugin provides **four components** that work together:

### 1. Command: `/handoff`

**Invocation**: You type `/handoff [subcommand]`

| Command | What It Does |
|---------|--------------|
| `/handoff init` | Create `.handoff/` structure with templates |
| `/handoff start` | Launch 4 parallel agents to gather context |
| `/handoff end` | Launch 5 parallel agents to archive state |
| `/handoff status` | Quick status check (no agents) |
| `/handoff` | Auto-detect: start if beginning, end if wrapping up |

The command auto-injects current context (project name, branch, handoff existence) before running.

### 2. Agent: `handoff-manager`

**Invocation**: Claude delegates to it, or you explicitly ask

```
> Use the handoff-manager agent to start the session
> Have the handoff-manager gather context
```

The agent appears in `/agents` and provides detailed orchestration instructions for parallel agent workflows. Claude may also delegate to it automatically when the task matches its description.

### 3. Skill: `handoff-awareness`

**Invocation**: Model-invoked (Claude decides when to use it)

Claude automatically applies this skill when:
- Working on long sessions that might hit context limits
- Encountering errors that should be documented
- Making decisions that need to be preserved
- You mention "handoff", "session", "context", or "continuity"

The skill reminds Claude to document failures properly, track files touched, and ensure clear resume points.

### 4. Hooks: SessionStart & SessionEnd

**Invocation**: Automatic (runs when Claude Code starts/ends)

**SessionStart** hook:
1. Checks for `.handoff/` or `~/obsidian/projects/<project>/`
2. If found, injects a reminder to run `/handoff start`
3. If not found, suggests running `/handoff init`

**SessionEnd** hook:
1. Checks if handoff files exist
2. If found, reminds to run `/handoff end` to save progress

You don't invoke these—they run automatically.

---

## Parallel Agent Workflow

### START (4 agents)

| Agent | Model | Task |
|-------|-------|------|
| 1 | sonnet | Git state + full commit messages |
| 2 | sonnet | PRs with full bodies |
| 3 | sonnet | Issue tracker (GitHub/Linear) |
| 4 | opus | Read + analyze context files |

All agents run simultaneously. Results are polled, then the resume point is executed.

### END (5 agents)

| Agent | Model | Task |
|-------|-------|------|
| 1 | sonnet | Git state + archive handoff |
| 2 | sonnet | Package version changes |
| 3 | sonnet | Issue tracker sync |
| 4 | opus | Update HANDOFF.md |
| 5 | opus | Update CONTEXT.md (if needed) |

---

## Key Principles

### Get Full Details

```bash
# Full commit messages (not just subject)
git log -10 --format='%h %s%n%b---'

# PRs with full bodies
gh pr list --json number,title,body,mergedAt,commits
```

### Document Failures Properly

**Bad:**
```
❌ Auth didn't work
```

**Good:**
```
### ❌ JWT token refresh
- **Attempted:** Added refresh logic in useAuth hook
- **Error:** Token expired still appears after refresh
- **Why:** Refresh happens async, component re-renders before token updates
- **Would need:** Suspense boundary or loading state during refresh
```

### Be Specific About Resume

**Bad:**
```
**Next:** Continue working on auth
```

**Good:**
```
**Next:** Add Suspense boundary around AuthProvider in app/_layout.tsx:12
**Files to read:** lib/auth.ts:45-60, app/_layout.tsx
**Context:** Token refresh is async, need to prevent render during refresh
```

---

## Configuration

### File Locations

**Default** (project-local):
```
.handoff/
├── CONTEXT.md
├── HANDOFF.md
└── sessions/
```

**Alternative** (Obsidian vault):
```
~/obsidian/projects/<project>/
├── CONTEXT.md
├── HANDOFF.md
└── sessions/
```

**Custom** (environment variable):
```bash
export HANDOFF_DIR=/path/to/handoff
```

### Templates

Templates for CONTEXT.md and HANDOFF.md are included in the `templates/` directory. The `/handoff init` command uses these to create properly structured handoff files.

---

## Continuity Levels in Claude Code

Claude Code provides three levels of continuity. Use all of them:

| Level | Feature | Scope | Use When |
|-------|---------|-------|----------|
| 1 | **Checkpointing** (`/rewind`) | Within session | Made a mistake, want to undo edits |
| 2 | **Session Resume** (`--continue`) | Same Claude Code install | Paused work, same machine, context intact |
| 3 | **Handoff** (`/handoff`) | Across anything | Hit context limit, switching tools, or new machine |

### When to use what

**Checkpointing** - You broke something in the last few edits
```bash
# Press Esc + Esc, or:
/rewind
```

**Session Resume** - You closed the terminal but want to continue
```bash
claude --continue          # Resume most recent
claude --resume auth-work  # Resume named session
```

**Handoff** - Context window is full, or you need to continue elsewhere
```bash
/handoff end    # Save state before ending
# ... later, even on different machine or tool ...
/handoff start  # Restore context
```

### Key difference

Session resume keeps the *exact* conversation in Claude Code's memory. Handoff captures the *essential state* in markdown files that work anywhere—different machines, different AI tools, different team members.

**Tip**: Name your sessions with `/rename` for easy resume. Use handoff when the session gets too long or you're switching contexts.

---

## Git Worktrees

When running parallel Claude Code sessions with [git worktrees](https://git-scm.com/docs/git-worktree), each worktree can have its own `.handoff/` directory:

```bash
# Create worktrees for parallel work
git worktree add ../project-feature-a -b feature-a
git worktree add ../project-bugfix bugfix-123

# Each worktree gets its own handoff state
cd ../project-feature-a && /handoff init
cd ../project-bugfix && /handoff init
```

This lets you:
- Run multiple Claude Code instances with isolated context
- Switch between tasks without losing state
- Hand off individual worktrees to teammates

---

## Works With

- Claude Code (primary target)
- Cursor
- Codex
- GitHub Copilot Chat
- Any AI assistant with git/shell access

## Requirements

- **Claude Code 1.0.33+** (run `claude --version` to check)
- Git
- GitHub CLI (`gh`) for PR details (optional)
- Linear MCP plugin for issue tracking (optional)

## License

MIT
