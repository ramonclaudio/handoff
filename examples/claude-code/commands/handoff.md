---
description: Handoff workflow - start, end, or status
allowed-tools: Bash(git:*), Bash(gh:*), Bash(cat:*), Bash(ls:*), Read, Task, TaskOutput
argument-hint: start | end | status [handoff-dir]
---

# Handoff

Manage session handoffs for context continuity.

## Commands

Based on $1:

### `start` - Begin new session

Run the full START workflow:
- Launch 4 parallel agents (git, PRs, issues, context analysis)
- Gather fresh state
- Display resume point
- Read files from HANDOFF.md

### `end` - End current session

Run the full END workflow:
- Launch 5 parallel agents
- Archive current HANDOFF.md
- Update HANDOFF.md with session state
- Update CONTEXT.md if needed
- Sync issue tracker

### `status` - Quick status check

Show current handoff state without full agent workflow:
- Current branch and git status
- Open PRs
- Resume point from HANDOFF.md

## Usage

```
/handoff start           # Start new session
/handoff end             # End current session
/handoff status          # Quick status
/handoff start .handoff  # Use custom directory
```

## Default Directory

Uses `.handoff/` unless specified as second argument.
