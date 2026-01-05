---
description: Gather context for a new session using parallel background agents
allowed-tools: Bash(git:*), Bash(gh:*), Read, Task, TaskOutput
argument-hint: [handoff-dir]
---

# Handoff Start

Gather context for continuing work from the previous session.

## Handoff Directory

Use the provided directory or default to `.handoff/`:

```
HANDOFF_DIR="${1:-.handoff}"
```

## Execute Parallel Background Agents

Launch 4 agents simultaneously to gather context:

### Agent 1: Git State (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get git state with FULL commit details:
   git branch --show-current
   git status --short
   git log -10 --format='%h %s%n%b---'
   git diff --stat HEAD~5
   git stash list
   Return: branch, status, full commit messages"
```

### Agent 2: GitHub PRs (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Get PRs with FULL bodies:
   gh pr list --state=open --json number,title,body,headRefName,url,commits,files
   gh pr list --state=merged --limit=5 --json number,title,body,mergedAt,commits
   If open PR: gh pr view --json title,body,commits,files
   Return: PRs with full bodies and commits"
```

### Agent 3: Issue Tracker (sonnet)

```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
  "Query issues:
   gh issue list --state=open --json number,title,body,labels
   Separate by: In Progress vs Backlog
   Return: issues with descriptions"
```

### Agent 4: Context Analysis (opus)

```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
  "Read and analyze:
   $HANDOFF_DIR/CONTEXT.md
   $HANDOFF_DIR/HANDOFF.md
   Return:
   - Key gotchas from What Never Works
   - Current resume point (exact next action)
   - Files to read with line numbers
   - Blockers or context needed"
```

## Poll and Report

Poll all agents for results, then:

1. Display git state summary
2. Display PR status (open and recent merged)
3. Display issue tracker status
4. Display resume point and next action
5. List files to read from HANDOFF.md

## Continue from RESUME

After gathering context:
1. Read files listed in "Files Touched"
2. Execute the "Next" action from RESUME section
