# Handoff

> Session continuity for AI coding assistants.

## The Problem

AI coding assistants have context limits. When you hit that limit mid-feature, the next session starts fresh. You lose:

- What was tried and failed
- Decisions made and why
- The exact resume point
- Which files were modified

## The Solution

Two markdown files that capture everything needed to continue seamlessly.

```
.handoff/
├── CONTEXT.md     # Project knowledge (permanent)
├── HANDOFF.md     # Session state (updated each session)
└── sessions/      # Archive (optional)
```

## Requirements

- **AI coding assistant** with shell access (Claude Code, Cursor, Codex, etc.)
- **Git** for version control
- **GitHub CLI** (`gh`) for PR details

## Quick Start

```bash
# Initialize in your project
cd your-project
mkdir -p .handoff/sessions

# Copy templates (or download from this repo)
curl -o .handoff/CONTEXT.md https://raw.githubusercontent.com/ramonclaudio/handoff/main/templates/CONTEXT.md
curl -o .handoff/HANDOFF.md https://raw.githubusercontent.com/ramonclaudio/handoff/main/templates/HANDOFF.md

# Or clone and copy
git clone https://github.com/ramonclaudio/handoff.git /tmp/handoff
cp /tmp/handoff/templates/*.md .handoff/
```

Or use the CLI:
```bash
cp handoff/cli/handoff /usr/local/bin/
handoff --init
```

## The Workflow

### START (Every New Session)

```bash
# Get git state with FULL commit messages
git log -10 --format='%h %s%n%b---'
git status
git diff --stat HEAD~5

# Get PRs with FULL bodies
gh pr list --state=open --json number,title,body,headRefName
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt

# Read context files
cat .handoff/CONTEXT.md
cat .handoff/HANDOFF.md

# Continue from RESUME point
```

### DURING

- Document failures **immediately** (not at session end)
- Record decisions with reasoning
- Track files modified with line numbers

### END (Every Session End)

```bash
# Archive current handoff
cp .handoff/HANDOFF.md .handoff/sessions/$(date +%Y-%m-%d-%H%M).md

# Update HANDOFF.md with:
# - Fresh git state (branch, status, recent commits)
# - What was done
# - What failed (and WHY)
# - Decisions made
# - Files touched with line numbers
# - Exact RESUME point (specific next action)
```

## What Goes Where

| CONTEXT.md (permanent) | HANDOFF.md (per-session) |
|------------------------|--------------------------|
| Project description | Session timestamp |
| Repository URL | Git state (branch, status) |
| Stack versions | Recent commits (full messages) |
| Commands (dev, build, test) | Recent PRs (full bodies) |
| What never works | What was done |
| Architecture patterns | What failed (detailed) |
| Constraints/limits | Decisions made |
| | Files touched |
| | Exact resume point |

## Key Principles

### Get Full Details

```bash
# Full commit messages (not just subject)
git log -10 --format='%h %s%n%b---'

# PRs with full bodies
gh pr list --json number,title,body,mergedAt,commits
```

### Document Failures Properly

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

### Be Specific About Resume

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

## CLI Usage

```bash
handoff                    # Start AI assistant with context
handoff --resume NAME      # Resume named session
handoff --init             # Initialize handoff in project
handoff --start            # Gather context (output to paste)
handoff --end              # Archive and gather final state
handoff --status           # Quick status check
handoff --dir PATH         # Use custom handoff directory
```

## Optional: Issue Tracker Integration

Add your issue tracker queries to the workflow:

**GitHub Issues:**
```bash
gh issue list --state open
gh issue view 123
```

**Linear:**
```
mcp__plugin_linear_linear__list_issues project:"<name>"
mcp__plugin_linear_linear__update_issue id:"XXX-123" state:"Done"
```

**Jira, Asana, etc.:** Add your own queries to the workflow.

## For AI Assistants with Parallel Agents

If your AI supports background tasks (like Claude Code), parallelize:

**START (4 agents):**
| Agent | Task |
|-------|------|
| 1 | Git state + full commit messages |
| 2 | PRs with full bodies |
| 3 | Issue tracker (if configured) |
| 4 | Read and analyze context files |

**END (5 agents):**
| Agent | Task |
|-------|------|
| 1 | Git state + archive handoff |
| 2 | Package version changes |
| 3 | Issue tracker sync (if configured) |
| 4 | Update HANDOFF.md |
| 5 | Update CONTEXT.md if needed |

## Anti-Bloat Guidelines

**DO include:**
- Full commit messages (body, not just subject)
- Full PR bodies
- Specific failure details with root cause
- Files with line numbers
- Exact resume actions

**DON'T include:**
- File contents (AI can read on demand)
- More than 10 commits
- Historical sessions in main files
- Verbose explanations

**Size targets:**
- CONTEXT.md: ~100-150 lines
- HANDOFF.md: ~80-120 lines

## Claude Code Integration

See `examples/claude-code/` for:
- **CLI wrapper** - `handoff` command
- **Slash commands** - `/handoff start`, `/handoff end`
- **Skills** - Auto-invoked by context
- **Agents** - Handoff management
- **Hooks** - Session reminders

```bash
# Install slash commands
cp -r examples/claude-code/commands/* ~/.claude/commands/

# Use
/handoff start
/handoff end
```

## Works With

- Claude Code
- Cursor
- Codex
- GitHub Copilot Chat
- Any AI assistant with git/shell access

## License

MIT
