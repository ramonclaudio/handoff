# Handoff Workflow

Complete documentation for the handoff system.

---

## Overview

The handoff system solves context loss between AI coding sessions. It uses two files:

- **CONTEXT.md** - Permanent project knowledge (what is this, how does it work)
- **HANDOFF.md** - Session state (what happened, what's next)

---

## START (Every New Session)

### 1. Get Git State

```bash
# Branch and status
git branch --show-current
git status --short

# Full commit messages (not just titles)
git log -10 --format='%h %s%n%b---'

# Files changed recently
git diff --stat HEAD~5

# Check for stashed work
git stash list
```

### 2. Get PR Details (GitHub)

```bash
# Open PRs (work in progress)
gh pr list --state=open --json number,title,body,headRefName,url,commits,files

# Merged PRs (recent completed work)
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

# If open PR exists, get full details
gh pr view --json title,body,commits,files,comments
```

### 3. Get Issue Tracker State

Query your issue tracker (GitHub Issues, Linear, Jira, etc.) for:
- Issues "In Progress"
- Issues in current sprint/milestone
- Recently completed issues

### 4. Read Context Files

```
Read CONTEXT.md (permanent project knowledge)
Read HANDOFF.md (session state)
```

### 5. Read Files from HANDOFF

- Read each file listed in "Files Touched"
- Focus on the line numbers mentioned
- If there's an open PR, read those files too

### 6. Continue from RESUME

- Execute the "Next" action specified
- Reference "Files to read" for context

---

## DURING (Throughout Session)

### Track Progress in Real-Time

- Mark tasks done immediately (don't batch)
- Document failures AS THEY HAPPEN with full detail
- Record decisions with reasoning as you make them
- Note any new "What Never Works" discoveries

### Update Issue Tracker

```bash
# Starting a task
Move issue to "In Progress"

# Completed a task
Move issue to "Done"

# Discovered new issue
Create new issue with details
```

### On Failure (Document Immediately)

```markdown
### ❌ What was tried
- **Attempted:** Exact approach taken
- **Error:** Error message or symptom
- **Why:** Root cause analysis
- **Tried also:** Other approaches attempted
- **Would need:** What would have to change to work
- **Workaround:** If any exists
```

### On Decision (Document Immediately)

```markdown
| Decision | Choice | Alternatives | Reasoning |
|----------|--------|--------------|-----------|
| How to do X | Option A | B, C | Because Y |
```

---

## END (Every Session End)

### 1. Get Final Git State

```bash
# Current state
git branch --show-current
git status --short
git stash list

# Full commit messages
git log -10 --format='%h %s%n%b---'

# Files changed
git diff --stat HEAD~5

# PR state
gh pr list --state=open --json number,title,body,headRefName,url,commits
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits
```

### 2. Check Package Versions (if changed)

```bash
# Node.js
cat package.json | jq '.dependencies'

# Python
cat requirements.txt
# or
pip freeze
```

### 3. Archive Current Handoff

```bash
cp HANDOFF.md sessions/$(date +%Y-%m-%d-%H%M).md
```

### 4. Update HANDOFF.md

Include ALL of:

**Git State:**
- Branch name
- Clean/dirty status
- Any stashed work
- Open PR (if any) with URL

**Recent Commits:**
- Paste full `git log` output with bodies

**Recent PRs:**
- Table with titles AND body summaries

**Issue Tracker:**
- Issues In Progress
- Issues completed this session
- Backlog summary

**Done (This Session):**
- Checklist with details

**Failed (Don't Retry):**
- Each failure with: attempted, error, why, would need, workaround

**Decisions:**
- Table: decision, choice, alternatives, reasoning

**Files Touched:**
- Table: file path, lines changed, what was modified

**Resume:**
- **Next:** Exact action (specific, not vague)
- **Then:** What comes after
- **Files to read:** Specific files with line numbers
- **Context:** Background needed for next action
- **Blockers:** Anything blocking progress

### 5. Update CONTEXT.md (if needed)

- Stack versions if packages changed
- New "What Never Works" entries from failures
- New architecture patterns discovered

### 6. Sync Issue Tracker

- Mark completed issues as Done
- Create new issues discovered during session
- Update any blocked issues

---

## CONTEXT.md Structure

Permanent project knowledge. Rarely changes.

```markdown
# Project Name

> One-line description

## Links
- Repository, Issues, Docs, Local path

## Stack (Updated: date)
- Runtime, Framework, Database, Auth, Styling with versions

## Commands
- Dev, Build, Test, Lint, Other

## Environment Variables
- Local and Production variables

## What Never Works
- Known gotchas with solutions

## Architecture Patterns
- Auth, Data fetching, State management patterns

## Constraints
- Rate limits, file sizes, platform limitations
```

---

## HANDOFF.md Structure

Session-specific state. Updated every session.

```markdown
# Handoff: Project Name

> Session: date/time
> Task: what we're working on
> Issue: reference

## Status
IN PROGRESS | BLOCKED | IDLE

## Git State
Branch, status, stash, open PR

## Recent Commits
Full messages with bodies

## Recent PRs
With body summaries

## Issue Tracker
In Progress, Done, Backlog

## Done (This Session)
Checklist with details

## Failed (Don't Retry)
Detailed failure documentation

## In Progress
Half-done work

## Decisions
Choice, alternatives, reasoning

## Files Touched
Path, lines, what changed

## Resume
Next, Then, Files to read, Context, Blockers

## Session Chain
For multi-session features
```

---

## What Goes Where

| Information | CONTEXT.md | HANDOFF.md |
|-------------|------------|------------|
| Project description | ✓ | |
| Links | ✓ | |
| Stack versions | ✓ | |
| Commands | ✓ | |
| Environment vars | ✓ | |
| What never works | ✓ | |
| Architecture patterns | ✓ | |
| Current git state | | ✓ |
| Recent commits/PRs | | ✓ |
| Issue tracker status | | ✓ |
| Session progress | | ✓ |
| Failures this session | | ✓ |
| Decisions this session | | ✓ |
| Files touched | | ✓ |
| Resume point | | ✓ |

---

## Anti-Bloat Guidelines

**DO include:**
- Full commit messages (body, not just title)
- Full PR bodies (or summaries)
- Issue descriptions
- Files with line numbers
- Specific failure details
- Exact resume actions

**DON'T include:**
- File contents (read on demand)
- More than 10 commits
- All branches (just current + open PRs)
- Historical sessions in main files
- Verbose explanations

**Size targets:**
- CONTEXT.md: ~100-150 lines
- HANDOFF.md: ~80-120 lines
- Total read at session start: <300 lines

---

## Git Commands Reference

```bash
# Full commit messages
git log -10 --format='%h %s%n%b---'

# Oneline (less detail)
git log --oneline -10

# Files changed
git diff --stat HEAD~5

# Current status
git status --short

# Stash list
git stash list
```

---

## GitHub CLI Reference

```bash
# Open PRs with full details
gh pr list --state=open --json number,title,body,headRefName,url,commits,files

# Merged PRs with full details
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

# View specific PR
gh pr view <number> --json title,body,commits,files,comments

# Create PR
gh pr create --title "..." --body "..."
```

---

## Directory Options

**In-repo:**
```
project/
├── .handoff/
│   ├── CONTEXT.md
│   ├── HANDOFF.md
│   └── sessions/
└── src/
```

**Separate directory:**
```
~/handoff/
├── project-a/
│   ├── CONTEXT.md
│   ├── HANDOFF.md
│   └── sessions/
└── project-b/
```

**With notes app:**
```
~/Notes/projects/
├── project-a/
└── project-b/
```

Choose based on your preference. In-repo is easier to track, separate is better for multiple projects.
