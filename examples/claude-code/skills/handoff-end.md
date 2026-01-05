---
name: handoff-end
description: End a session by archiving and updating handoff with parallel background agents
---

# Handoff End

Run this at the end of every conversation to preserve context for the next session.

## Workflow

Launch 5 parallel background agents, then poll for results:

### Agent 1: Git State + Archive (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get final git state with FULL commit details:

   git branch --show-current
   git status --short
   git log -10 --format='%h %s%n%b---'
   git diff --stat HEAD~5
   git stash list

   PRs with full bodies:
   gh pr list --state=open --json number,title,body,headRefName,url,commits
   gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

   Archive handoff:
   cp .handoff/HANDOFF.md .handoff/sessions/$(date +%Y-%m-%d-%H%M).md

   Return: all git/PR data for HANDOFF.md update"
```

### Agent 2: Package Versions (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get current package versions:

   For Node.js:
   cat package.json | jq -r '.dependencies | to_entries | .[:15] | .[] | \"\(.key): \(.value)\"'

   For Python:
   cat requirements.txt or pip freeze | head -15

   Compare with CONTEXT.md stack section
   Return: any version changes with old → new"
```

### Agent 3: Issue Tracker Sync (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Sync issue tracker state:

   Query current issues
   Identify:
   - Orphaned 'In Progress' issues (should they be done or blocked?)
   - Issues completed this session
   - New issues to create from work done

   Update issue states as needed
   Return: full issue details including descriptions"
```

### Agent 4: Update HANDOFF.md (opus)

```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Update .handoff/HANDOFF.md with comprehensive session state:

   Include:
   - Session timestamp and task description
   - Git state with FULL commit messages (from Agent 1)
   - PRs with FULL bodies (from Agent 1)
   - Issue tracker status with descriptions (from Agent 3)
   - DONE: checklist of completed items with detail
   - FAILED: each failure with attempted, error, why, would need, workaround
   - DECISIONS: table with choice, alternatives, reasoning
   - FILES TOUCHED: table with path, lines, what changed
   - RESUME: exact next action, files to read, context needed, blockers

   Be specific in RESUME - the next session should know exactly what to do"
```

### Agent 5: Update CONTEXT.md (opus)

```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Analyze if CONTEXT.md needs updates:

   Check:
   - Stack versions changed? (from Agent 2)
   - New 'What Never Works' entries from session failures?
   - New architecture patterns discovered?
   - New environment variables added?
   - New commands added?

   If updates needed, modify .handoff/CONTEXT.md with reasoning
   If no updates needed, return 'No changes required'"
```

### Poll and Verify

```
TaskOutput(task_id="agent1") → Git + PRs with full details + archive done
TaskOutput(task_id="agent2") → Version changes (if any)
TaskOutput(task_id="agent3") → Issues synced with descriptions
TaskOutput(task_id="agent4") → HANDOFF.md updated
TaskOutput(task_id="agent5") → CONTEXT.md updated (if needed)
```

## HANDOFF.md Must Include

| Section | Content |
|---------|---------|
| Status | IN PROGRESS / BLOCKED / IDLE |
| Git State | Branch, status, stash, open PR URL |
| Recent Commits | Full messages with bodies |
| Recent PRs | Table with body summaries |
| Issue Tracker | In Progress, Done, Backlog with descriptions |
| Done | Checklist with details |
| Failed | Attempted, error, why, would need, workaround |
| Decisions | Choice, alternatives, reasoning |
| Files Touched | Path, lines, what changed |
| Resume | Next (exact), Then, Files to read, Context, Blockers |
