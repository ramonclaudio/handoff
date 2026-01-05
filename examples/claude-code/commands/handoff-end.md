---
description: Archive and update handoff with session state using parallel background agents
allowed-tools: Bash(git:*), Bash(gh:*), Bash(cp:*), Bash(mkdir:*), Bash(cat:*), Bash(date:*), Read, Edit, Write, Task, TaskOutput
argument-hint: [handoff-dir]
---

# Handoff End

Archive current session and update handoff files for the next session.

## Handoff Directory

Use the provided directory or default to `.handoff/`:

```
HANDOFF_DIR="${1:-.handoff}"
```

## Execute Parallel Background Agents

Launch 5 agents simultaneously:

### Agent 1: Git State + Archive (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get final git state:
   git branch --show-current
   git status --short
   git log -10 --format='%h %s%n%b---'
   git diff --stat HEAD~5
   git stash list
   gh pr list --state=open --json number,title,body,headRefName,url,commits
   gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

   Archive handoff:
   mkdir -p $HANDOFF_DIR/sessions
   cp $HANDOFF_DIR/HANDOFF.md $HANDOFF_DIR/sessions/$(date +%Y-%m-%d-%H%M).md

   Return: all git/PR data for update"
```

### Agent 2: Package Versions (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Check package versions:
   If package.json: cat package.json | jq '.dependencies'
   If requirements.txt: cat requirements.txt
   Compare with CONTEXT.md stack
   Return: version changes (old → new)"
```

### Agent 3: Issue Tracker Sync (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Sync issue tracker:
   gh issue list --state=open --json number,title,body,labels
   Identify: completed this session, orphaned In Progress, new issues needed
   Return: issue status with descriptions"
```

### Agent 4: Update HANDOFF.md (opus)

```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Update $HANDOFF_DIR/HANDOFF.md with:
   - Session timestamp
   - Git state with FULL commit messages
   - PRs with FULL bodies
   - Issue status with descriptions
   - DONE: completed items with detail
   - FAILED: each failure with attempted, error, why, would need, workaround
   - DECISIONS: choice, alternatives, reasoning
   - FILES TOUCHED: path, lines, what changed
   - RESUME: exact next action, files to read, context, blockers"
```

### Agent 5: Update CONTEXT.md (opus)

```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Check if $HANDOFF_DIR/CONTEXT.md needs updates:
   - Stack versions changed?
   - New What Never Works entries?
   - New architecture patterns?
   If yes, update the file"
```

## Poll and Verify

Poll all agents, then confirm:

1. ✓ Handoff archived to sessions/
2. ✓ Git state captured
3. ✓ Issues synced
4. ✓ HANDOFF.md updated with resume point
5. ✓ CONTEXT.md updated (if needed)

Report summary of session: what was done, what failed, next steps.
