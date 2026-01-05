---
name: handoff-start
description: Start a new session by gathering context with parallel background agents
---

# Handoff Start

Run this at the beginning of every new conversation to gather context efficiently.

## Workflow

Launch 4 parallel background agents, then poll for results:

### Agent 1: Git State (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get git state with FULL commit details:

   git branch --show-current
   git status --short
   git log -10 --format='%h %s%n%b---'
   git diff --stat HEAD~5
   git stash list

   Return: branch, status, full commit messages, changed files, any stashes"
```

### Agent 2: GitHub PRs (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get PRs with FULL body and commit details:

   Open PRs:
   gh pr list --state=open --json number,title,body,headRefName,url,commits,files

   Merged PRs (last 5):
   gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits

   If open PR exists:
   gh pr view --json title,body,commits,files,comments

   Return: PR numbers, titles, FULL bodies, commit messages, files changed"
```

### Agent 3: Issue Tracker (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Query issue tracker for current project:

   For GitHub Issues:
   gh issue list --state=open --json number,title,body,labels

   For Linear (if configured):
   mcp__plugin_linear_linear__list_issues project:'<project>'

   Separate by state: In Progress vs Backlog vs Done
   Include issue descriptions, not just titles"
```

### Agent 4: Read Context (opus)

```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Read and analyze handoff context files:

   Read: .handoff/CONTEXT.md (or your handoff location)
   Read: .handoff/HANDOFF.md

   Return:
   - Key gotchas to remember (from What Never Works)
   - Current resume point (exact next action)
   - Files to read with specific lines
   - Any blockers or context needed
   - Decisions from last session that matter"
```

### Poll and Gather

```
TaskOutput(task_id="agent1") → Git state + full commit messages
TaskOutput(task_id="agent2") → PRs with bodies + commit details
TaskOutput(task_id="agent3") → Issues with descriptions
TaskOutput(task_id="agent4") → Analyzed context + resume plan
```

### Then Execute

1. Read files listed in "Files Touched" from HANDOFF.md
2. Focus on line numbers mentioned
3. Execute the "Next" action from RESUME
