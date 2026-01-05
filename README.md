# Handoff

> Session continuity for Claude Code across 200K context windows.

## Problem

Context window fills mid-feature. Next session starts fresh. You lose:
- What was tried and failed
- Decisions made and why
- Exact resume point
- Files that were modified

## Solution

Two files per project + parallel background agents for speed.

```
~/Notes/dev/projects/<project>/
├── CONTEXT.md     # Permanent: stack, commands, gotchas, patterns
├── HANDOFF.md     # Session: git state, progress, failures, resume
└── sessions/      # Archive: historical handoffs
```

## Quick Start

### 1. Create project directory

```bash
mkdir -p ~/Notes/dev/projects/<your-project>/sessions
```

### 2. Copy templates

```bash
cp templates/CONTEXT.md ~/Notes/dev/projects/<your-project>/
cp templates/HANDOFF.md ~/Notes/dev/projects/<your-project>/
```

### 3. Fill in CONTEXT.md

- Project links (GitHub, Linear, local path)
- Stack with versions
- Commands (dev, build, test)
- Environment variables
- Known gotchas ("What Never Works")
- Architecture patterns

### 4. Use the workflow

**START** - 4 parallel agents (sonnet + opus):
```
Agent 1 (sonnet): git log with FULL messages, status, diff
Agent 2 (sonnet): gh pr list with FULL bodies + commits
Agent 3 (sonnet): Linear list_issues with descriptions
Agent 4 (opus): Read + analyze CONTEXT + HANDOFF, plan resume
```

**END** - 5 parallel agents:
```
Agent 1 (sonnet): git state + PRs + archive handoff
Agent 2 (sonnet): package versions
Agent 3 (sonnet): Linear sync
Agent 4 (opus): Update HANDOFF.md
Agent 5 (opus): Update CONTEXT.md if needed
```

## Model Selection

| Task | Model | Why |
|------|-------|-----|
| Data fetching (git, gh, packages) | sonnet | Fast, accurate |
| Linear queries | sonnet | Structured data |
| Reasoning, analysis, writing | opus | Best quality |

## Key Commands

### Git with full details

```bash
# Full commit messages (not just titles)
git log -10 --format='%h %s%n%b---'

# PRs with full bodies
gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits
gh pr list --state=open --json number,title,body,headRefName,url,commits,files
```

### Linear

```bash
mcp__plugin_linear_linear__list_issues project:"<name>"
mcp__plugin_linear_linear__update_issue id:"RAY-xxx" state:"Done"
mcp__plugin_linear_linear__create_issue title:"..." team:"<team>"
```

## File Reference

| File | Purpose | Update When |
|------|---------|-------------|
| `CONTEXT.md` | Permanent project knowledge | Stack changes, new gotchas |
| `HANDOFF.md` | Session state | Every session end |
| `sessions/*.md` | Archived handoffs | Auto-archived at session end |

## Anti-Bloat Guidelines

**DO include:**
- Full commit messages (body, not just title)
- Full PR bodies
- Issue descriptions
- Files touched with line numbers
- Specific failure details
- Exact resume actions

**DON'T include:**
- File contents (read on demand)
- More than 10 commits
- All branches (just current + open PRs)
- Historical sessions in main files

**Size targets:**
- CONTEXT.md: ~100-150 lines
- HANDOFF.md: ~80-120 lines

## License

MIT
