# Handoff

> Session continuity for AI-assisted coding across context window limits.

## The Problem

AI coding assistants have context window limits. When you hit that limit mid-feature, the next session starts fresh. You lose:

- What was tried and failed (so you retry the same broken approaches)
- Decisions made and why (so you re-debate the same choices)
- The exact resume point (so you waste time figuring out where you left off)
- Which files were modified (so you re-read everything)

## The Solution

Two markdown files per project that capture everything needed to continue seamlessly.

```
your-project/
├── CONTEXT.md     # Permanent: stack, commands, gotchas, patterns
├── HANDOFF.md     # Session: git state, progress, failures, resume
└── sessions/      # Archive: historical handoffs
```

**CONTEXT.md** = "What is this project and how does it work"
**HANDOFF.md** = "What happened and what's next"

## Quick Start

### 1. Create handoff directory in your project

```bash
mkdir -p .handoff/sessions
```

Or keep it separate:
```bash
mkdir -p ~/handoff/<project-name>/sessions
```

### 2. Copy templates

```bash
cp templates/CONTEXT.md .handoff/
cp templates/HANDOFF.md .handoff/
```

### 3. Fill in CONTEXT.md once

- Project links (repo, issue tracker)
- Stack with versions
- Commands (dev, build, test)
- Known gotchas ("What Never Works")
- Architecture patterns

### 4. Update HANDOFF.md each session

**At session START:**
- Get fresh git state
- Get recent PRs/commits with full details
- Read CONTEXT.md and HANDOFF.md
- Continue from the RESUME point

**At session END:**
- Archive current HANDOFF.md to `sessions/`
- Update HANDOFF.md with:
  - What was done
  - What failed (and why - so you don't retry)
  - Decisions made
  - Files touched
  - Exact next action

## The Workflow

### START (Every New Session)

```bash
# Get git state with FULL commit messages
git log -10 --format='%h %s%n%b---'
git status
git diff --stat HEAD~5

# Get PRs with FULL bodies (GitHub)
gh pr list --state=open --json number,title,body,headRefName,commits
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt

# Read context files
# Then continue from RESUME point in HANDOFF.md
```

### DURING

- Document failures **immediately** (not at end)
- Record decisions with reasoning
- Track files you modify with line numbers

### END (Every Session End)

```bash
# Archive current handoff
cp .handoff/HANDOFF.md .handoff/sessions/$(date +%Y-%m-%d-%H%M).md

# Update HANDOFF.md with:
# - Fresh git state
# - What was done
# - What failed
# - Decisions made
# - Files touched
# - Exact RESUME point
```

## What Goes Where

| Information | CONTEXT.md | HANDOFF.md |
|-------------|------------|------------|
| Project description | ✓ | |
| Links (repo, issues) | ✓ | |
| Stack versions | ✓ | |
| Commands | ✓ | |
| What never works | ✓ | |
| Architecture patterns | ✓ | |
| Current git state | | ✓ |
| Recent commits/PRs | | ✓ |
| Session progress | | ✓ |
| Failures (detailed) | | ✓ |
| Decisions made | | ✓ |
| Files touched | | ✓ |
| Resume point | | ✓ |

## Key Principles

### Get Full Details

Don't just capture titles - get the full context:

```bash
# Full commit messages (not just subject lines)
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
- **Error:** "Token expired" still appears after refresh
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

## Anti-Bloat Guidelines

**DO include:**
- Full commit messages (body, not just title)
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

## For AI Assistants with Background Agents

If your AI assistant supports parallel background tasks, you can speed up the workflow:

**START - parallel data gathering:**
```
Agent 1: git state + commit details
Agent 2: PR details with bodies
Agent 3: Issue tracker status
Agent 4: Read and analyze context files
```

**END - parallel updates:**
```
Agent 1: git state + archive handoff
Agent 2: package version changes
Agent 3: Issue tracker sync
Agent 4: Update HANDOFF.md
Agent 5: Update CONTEXT.md if needed
```

## Works With

- Claude (Anthropic)
- ChatGPT (OpenAI)
- Cursor
- GitHub Copilot Chat
- Any AI coding assistant with context limits

## Directory Options

**In-repo (recommended for solo projects):**
```
your-project/
├── .handoff/
│   ├── CONTEXT.md
│   ├── HANDOFF.md
│   └── sessions/
└── src/
```

**Separate directory (for multiple projects or team use):**
```
~/handoff/
├── project-a/
│   ├── CONTEXT.md
│   ├── HANDOFF.md
│   └── sessions/
└── project-b/
    └── ...
```

**With Obsidian/notes app:**
```
~/Notes/projects/
├── project-a/
│   └── ...
```

## Examples

### Shell Scripts

Basic scripts for any AI assistant:

```bash
# Initialize handoff in a project
./examples/scripts/handoff-init.sh

# Run at session start (outputs context to paste)
./examples/scripts/handoff-start.sh

# Run at session end (archives and outputs state)
./examples/scripts/handoff-end.sh
```

### Claude Code

Optimized implementation using parallel background agents:

- `examples/claude-code/skills/handoff-start.md` - START workflow skill
- `examples/claude-code/skills/handoff-end.md` - END workflow skill
- `examples/claude-code/CLAUDE.md.example` - Project instructions template

**Key features:**
- 4 parallel agents at START, 5 at END
- Sonnet for data fetching, Opus for reasoning
- Full commit messages and PR bodies
- Automatic polling and aggregation

```
# Copy skills to your project
cp -r examples/claude-code/skills .claude/

# Add to your CLAUDE.md
cat examples/claude-code/CLAUDE.md.example >> CLAUDE.md
```

### Custom Integrations

The pattern works with any AI assistant that supports:
- Running shell commands
- Reading/writing files
- Some form of task parallelization (optional but faster)

Adapt the workflow to your tool's capabilities.

## Contributing

Contributions welcome! Ideas:
- Examples for other AI tools (Cursor, Copilot, etc.)
- Integrations with issue trackers (Linear, Jira, etc.)
- GUI tools for managing handoffs
- VS Code extension

## License

MIT
