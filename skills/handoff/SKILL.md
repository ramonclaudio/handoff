---
name: handoff
description: Medical-grade session handoff - gather context or archive state
argument-hint: start|end|status|init
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Bash(npm:*)
  - Bash(bun:*)
  - Bash(pnpm:*)
  - Bash(yarn:*)
  - Bash(mkdir:*)
  - Bash(cp:*)
  - Bash(rm:*)
  - Bash(date:*)
  - Bash(ls:*)
  - Bash(test:*)
  - Read
  - Write
  - Edit
  - mcp__plugin_linear_linear__list_issues
---

# Handoff

Medical-grade session continuity. Bad handoffs kill projects.

## Argument: $ARGUMENTS

---

## INIT (`init`)

```bash
mkdir -p .handoff/sessions
```

Write `.handoff/CONTEXT.md` (stack, commands, critical paths, gotchas).
Write `.handoff/HANDOFF.md` (health table, severity, resume point).

---

## START (default or `start`)

1. **Timeline**: Find last session from `.handoff/sessions/*.md`
2. **Context**: Read CONTEXT.md (stack, patterns, gotchas)
3. **State**: Read HANDOFF.md (severity, health, blockers, resume)
4. **Git**: `git branch --show-current && git status -s`
5. **Commits**: `git log --since="[session date]" --format="%h %s%n%b"`
6. **PRs**: Open, merged since, opened since (with bodies)
7. **Linear**: Issues updated since last session
8. **Drift check**: Compare current state vs handoff state
9. **Output**: Structured summary - ready to proceed

---

## END (`end`)

1. **Archive**: `cp .handoff/HANDOFF.md ".handoff/sessions/$(date +%Y-%m-%d-%H%M).md"`
2. **Health**: Run build, test, lint - capture pass/fail
3. **Git**: Branch, status, last 5 commits
4. **Analyze**: Infer from session context (DO NOT ASK):
   - Done: commits, PRs, completed work
   - Failed: errors, non-zero exits, abandoned approaches (with WHY)
   - Blockers: missing deps, permissions, decisions
   - Watch-outs: gotchas discovered, workarounds needed
   - Severity: derive from health checks
   - Resume: next logical step with file:line
5. **Write**: HANDOFF.md with all sections
6. **Validate**: All required fields present?
7. **Confirm**: Output summary

---

## STATUS (`status`)

Read HANDOFF.md. Output: Severity, Branch, Health, Blockers, Resume.

---

## Severity

| Level | Meaning |
|-------|---------|
| 🔴 CRITICAL | Production down, drop everything |
| 🟡 IN PROGRESS | Mid-feature, continue work |
| 🟢 READY | All green, pick up new work |

---

## Required in HANDOFF.md

- Severity (🔴/🟡/🟢)
- Health table (Build/Tests/Lint)
- Git state
- Done (concrete items)
- Failed (with Tried/Error/Why/Need)
- Blockers
- Watch Out For
- Resume (Next + Files + Context)
