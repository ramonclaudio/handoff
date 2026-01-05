# Handoff System

> Session continuity for Claude Code across 200K context windows.

---

## Structure

```
~/Notes/dev/projects/<project>/
├── CONTEXT.md     # Permanent: what is this project, how does it work
├── HANDOFF.md     # Session: what happened, what's next
└── sessions/      # Archive: historical handoffs
```

---

## START (Every New Conversation)

### Launch All in Parallel (Background Agents)

```
# Agent 1: Git state + commit details (sonnet)
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get git state with FULL commit details:
   git branch --show-current
   git status --short
   git log -10 --format='%h %s%n%b---'  # Hash, subject, AND body
   git diff --stat HEAD~5
   git stash list

   Return: branch, status, and commits with full descriptions"

# Agent 2: GitHub PRs with full details (sonnet)
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get PRs with FULL body and commit details:

   Open PRs:
   gh pr list --state=open --json number,title,body,headRefName,url,commits,files

   Merged PRs (last 5):
   gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

   If open PR exists, get full view:
   gh pr view --json title,body,commits,files,comments

   Return: PR numbers, titles, FULL bodies, commit messages, files changed"

# Agent 3: Linear tasks (sonnet)
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Query Linear for project issues:
   mcp__plugin_linear_linear__list_issues project:'<project>'

   Separate by state: In Progress vs Backlog vs Done
   Include issue descriptions, not just titles"

# Agent 4: Read context + analyze (opus for reasoning)
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Read and analyze context files:
   ~/Notes/dev/projects/<project>/CONTEXT.md
   ~/Notes/dev/projects/<project>/HANDOFF.md

   Return:
   - Key gotchas to remember
   - Current resume point
   - Files to read with specific lines
   - Any blockers or context needed"
```

### Poll All Agents → Gather Results

```
TaskOutput(task_id="agent1") → Git state + full commit messages
TaskOutput(task_id="agent2") → PRs with bodies + commit details
TaskOutput(task_id="agent3") → Linear tasks with descriptions
TaskOutput(task_id="agent4") → Analyzed context + resume plan
```

### Then: Read FILES TOUCHED + Execute RESUME

- Read each file in "FILES TOUCHED" (focus on line numbers)
- If open PR exists, read PR files
- Execute the "Next" action from RESUME

---

## DURING (Throughout Session)

### Track Progress Real-Time
- Mark tasks done immediately (don't batch)
- Document failures AS THEY HAPPEN with full detail
- Record decisions with reasoning as you make them
- Note any new "What Never Works" discoveries

### Linear Sync (as work progresses)
```bash
# Starting a task
mcp__plugin_linear_linear__update_issue id:"RAY-xxx" state:"In Progress"

# Completed a task
mcp__plugin_linear_linear__update_issue id:"RAY-xxx" state:"Done"

# Discovered new issue
mcp__plugin_linear_linear__create_issue title:"..." team:"RMNCLDYO" project:"..."
```

### On Failure (Document Immediately)
```markdown
### ❌ <What was tried>
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
| How to X | Option A | B, C | Because Y |
```

### Mid-Session Checkpoint (for long sessions)
If session is getting long, do a quick state capture:
```bash
git status --short
git log --oneline -3
# Mental note: what's done, what's left, any blockers
```

---

## END (Every Conversation End)

### Launch All in Parallel (Background Agents)

```
# Agent 1: Git state + full details (sonnet)
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get final git state with FULL commit details:
   git branch --show-current
   git status --short
   git log -10 --format='%h %s%n%b---'  # Full commit messages
   git diff --stat HEAD~5
   git stash list

   PRs with full bodies:
   gh pr list --state=open --json number,title,body,headRefName,url,commits
   gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

   Archive handoff:
   cp ~/Notes/dev/projects/<project>/HANDOFF.md \
      ~/Notes/dev/projects/<project>/sessions/$(date +%Y-%m-%d-%H%M).md"

# Agent 2: Package versions (sonnet)
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get current package versions:
   cat package.json | jq -r '.dependencies | to_entries | .[:15] | .[] | \"\(.key): \(.value)\"'
   Compare with CONTEXT.md stack section
   Return: any version changes with old → new"

# Agent 3: Linear sync (sonnet)
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Check Linear state for project '<project>':
   mcp__plugin_linear_linear__list_issues
   Identify: orphaned 'In Progress', completed this session, new issues to create
   Mark completed issues as Done
   Create any new issues discovered
   Return full issue details including descriptions"

# Agent 4: Update HANDOFF.md (opus for reasoning)
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Update ~/Notes/dev/projects/<project>/HANDOFF.md with:
   - Git state with FULL commit messages (from Agent 1)
   - PRs with FULL bodies (from Agent 1)
   - Linear task status with descriptions (from Agent 3)
   - Session progress (DONE items with detail)
   - Failures with full detail: attempted, error, why, would need
   - Decisions with alternatives + reasoning
   - Files touched with line numbers
   - Exact RESUME point with specific next action"

# Agent 5: Update CONTEXT.md (opus for reasoning)
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Analyze if CONTEXT.md needs updates:
   - Stack versions changed? (from Agent 2)
   - New 'What Never Works' entries from session failures?
   - New architecture patterns discovered?
   If yes, update ~/Notes/dev/projects/<project>/CONTEXT.md with reasoning"
```

### Poll All Agents → Verify Complete

```
TaskOutput(task_id="agent1") → Git + PRs with full details
TaskOutput(task_id="agent2") → Version changes
TaskOutput(task_id="agent3") → Linear synced with descriptions
TaskOutput(task_id="agent4") → HANDOFF.md updated (opus quality)
TaskOutput(task_id="agent5") → CONTEXT.md updated if needed (opus quality)
```

### HANDOFF.md Must Include:

| Section | Content |
|---------|---------|
| GIT STATE | Branch, status, stash, open PR URL |
| RECENT COMMITS | `git log --oneline -10` output |
| RECENT PRs | Table: PR#, title, date |
| LINEAR TASKS | In Progress, Done this session, Backlog summary |
| DONE | Checklist with details |
| FAILED | Attempted, error, why, would need, workaround |
| DECISIONS | Choice, alternatives, reasoning |
| FILES TOUCHED | Path, lines, what changed |
| RESUME | Next (exact), Then, Files to read, Context needed, Blockers |

---

## CONTEXT.md Template

What is this project and how does it work. Permanent reference.

```markdown
# <project>

> <One-line description>

## Links

| Resource | URL |
|----------|-----|
| GitHub | https://github.com/... |
| Linear | https://linear.app/... |
| Local | /Users/ramonclaudio/Developer/<project> |
| Docs | ~/Notes/dev/projects/<project>/ |

## Stack (Updated: YYYY-MM-DD)

| Layer | Package | Version |
|-------|---------|---------|
| Runtime | node/bun | x.x.x |
| Framework | expo/next | x.x.x |
| Backend | convex | x.x.x |
| ... | ... | ... |

## Commands

```bash
# Development
npm run dev          # Start dev server
npm run convex       # Backend (if separate)

# Quality
npm run lint         # Lint
npm run typecheck    # Type check
npm run test         # Tests

# Build
npm run build        # Production build
```

## Environment Variables

**Local (.env.local):**
- `VAR_NAME` - description

**Server (dashboard):**
- `VAR_NAME` - description

## What Never Works

| Problem | Solution |
|---------|----------|
| Issue description | How to fix/avoid |

## Architecture Patterns

**Pattern Name:**
```typescript
// Code example
```

## Constraints

- Rate limits, quotas, etc.
- Platform limitations
- Known issues
```

---

## HANDOFF.md Template

What happened and what's next. Session-specific.

```markdown
# HANDOFF: <project>

> Session: YYYY-MM-DD HH:MM
> Task: <what we're working on>
> Linear: RAY-xxx

## STATUS: IN PROGRESS | BLOCKED | IDLE

## GIT STATE

- **Branch:** feature/branch-name
- **Status:** clean | N uncommitted
- **PR:** #N or none

### Recent Commits
```
<git log --oneline -10 output>
```

### Recent PRs
| PR | Title | Merged |
|----|-------|--------|
| #N | Title | Date |

## LINEAR TASKS

| Issue | Title | Status |
|-------|-------|--------|
| RAY-xxx | Task title | In Progress |
| RAY-xxx | Task title | Backlog |

## DONE (This Session)

- [x] Completed item with detail
- [x] Another completed item

## FAILED (DON'T RETRY)

### ❌ What was tried
- **Attempted:** Description of what was tried
- **Error:** What went wrong
- **Why:** Root cause
- **Would need:** What would have to change

## IN PROGRESS

- [ ] Current half-done task
  - What's done: ...
  - What's left: ...

## DECISIONS

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| How to do X | Option A | Because Y |

## FILES TOUCHED

| File | Lines | What Changed |
|------|-------|--------------|
| path/file.ts | new | Created component |
| path/other.ts | 45-60 | Added function |
| path/third.ts | 12 | Fixed bug |

## RESUME

**Next:** Exact next action (be specific)
**Then:** What comes after that
**Files to read:** file1.ts:45-60, file2.ts
**Context needed:** Any background for next action

## SESSION CHAIN (multi-session features)

| Session | Progress |
|---------|----------|
| Jan 5 14:30 | Started, scaffolded |
| Jan 5 18:00 | THIS SESSION |
```

---

## What Goes Where

| Information | CONTEXT.md | HANDOFF.md |
|-------------|------------|------------|
| Project description | ✓ | |
| Links (GitHub, Linear) | ✓ | |
| Stack versions | ✓ | |
| Commands | ✓ | |
| Environment vars | ✓ | |
| What never works | ✓ | |
| Architecture patterns | ✓ | |
| Current git state | | ✓ |
| Recent commits/PRs | | ✓ |
| Linear task status | | ✓ |
| Session progress | | ✓ |
| Failures this session | | ✓ |
| Decisions this session | | ✓ |
| Files touched | | ✓ |
| Resume point | | ✓ |

---

## Linear Integration

Team: `RMNCLDYO`

```bash
# Query
mcp__plugin_linear_linear__list_issues project:"<name>"
mcp__plugin_linear_linear__list_teams
mcp__plugin_linear_linear__list_projects

# Update
mcp__plugin_linear_linear__update_issue id:"RAY-xxx" state:"Done"
mcp__plugin_linear_linear__update_issue id:"RAY-xxx" state:"In Progress"

# Create
mcp__plugin_linear_linear__create_issue title:"..." team:"RMNCLDYO" project:"<name>"
```

---

## Directory Map

| Location | Purpose |
|----------|---------|
| `~/.claude/CLAUDE.md` | Global instructions |
| `~/.claude/agents/` | Custom subagents |
| `~/.claude/skills/` | Custom skills |
| `~/Workflows/` | Templates |
| `~/Notes/dev/projects/` | Per-project handoffs |

---

## Anti-Bloat Guidelines

**DO include:**
- Recent 10 commits (context)
- Recent 5 merged PRs (completed work)
- Open PRs (work in progress)
- Files changed with line numbers
- Specific failure details
- Exact resume actions

**DON'T include:**
- Full PR bodies (truncate to 500 chars max)
- Full Linear issue descriptions (titles only)
- More than 10 commits (noise)
- File contents (read on demand)
- All branches (just current + open PRs)
- Historical sessions (reference on demand)

**Size targets:**
- CONTEXT.md: ~100-150 lines
- HANDOFF.md: ~80-120 lines
- Total read at START: <300 lines

---

## Quick Reference

**Model Selection:**
| Task Type | Model | Why |
|-----------|-------|-----|
| Data fetching (git, gh, packages) | sonnet | Fast, accurate for commands |
| Linear queries | sonnet | Structured data retrieval |
| Reasoning, analysis, writing | opus | Best quality for thinking |

**START (4 parallel agents):**
```
Agent 1 (sonnet): git log with FULL messages, status, diff, stash
Agent 2 (sonnet): gh pr list with FULL bodies + commits
Agent 3 (sonnet): Linear list_issues with descriptions
Agent 4 (opus): Read + analyze CONTEXT + HANDOFF, plan resume

→ Poll all → Read FILES TOUCHED → Execute RESUME
```

**DURING:**
```
- Document failures IMMEDIATELY with full detail
- Update Linear: state:"In Progress" / state:"Done"
- Record decisions with alternatives + reasoning
- Mid-session checkpoint if long
```

**END (5 parallel agents):**
```
Agent 1 (sonnet): git state + PRs with FULL bodies + archive
Agent 2 (sonnet): package versions, compare with CONTEXT
Agent 3 (sonnet): Linear sync with full descriptions
Agent 4 (opus): Update HANDOFF.md (reasoning for resume)
Agent 5 (opus): Update CONTEXT.md if needed (reasoning)

→ Poll all → Verify complete
```

**Git Commands for Full Details:**
```bash
# Full commit messages (not just titles)
git log -10 --format='%h %s%n%b---'

# PRs with full bodies
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits
gh pr list --state=open --json number,title,body,headRefName,url,commits,files
```

**Agent Launch Pattern:**
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true): "..."
Task(subagent_type="general-purpose", model="opus", run_in_background=true): "..."
# Then poll:
TaskOutput(task_id="...") for each
```
