---
name: handoff
description: Medical-grade session handoff. Use when user says "handoff", "save progress", "context full", or wants to start/end a coding session.
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
---

# Handoff Agent

Medical-grade session continuity. Like hospital shift changes - bad handoffs kill projects.

## Detect Action

- "start", "resume", "begin", "pick up" → START
- "end", "save", "archive", "done for now" → END
- "status", "check", "where are we" → STATUS
- "init", "setup", "initialize" → INIT

---

## INIT

```bash
mkdir -p .handoff/sessions
```

Write `.handoff/CONTEXT.md` (stack, commands, critical paths, gotchas).
Write `.handoff/HANDOFF.md` (health table, severity, resume).

---

## START

1. **Timeline**: `ls -1 .handoff/sessions/*.md | sort -r | head -1`
2. **Context**: Read CONTEXT.md
3. **State**: Read HANDOFF.md
4. **Git**: `git branch --show-current && git status -s`
5. **Commits**: `git log --since="[session date]" --format="%h %s%n%b"`
6. **PRs**: `gh pr list` - open, merged since, opened since
7. **Linear**: `mcp__plugin_linear_linear__list_issues` if configured
8. **Drift**: Compare current vs handoff state
9. **Output**: Structured summary - ready to proceed

---

## END

1. **Archive**: `cp .handoff/HANDOFF.md ".handoff/sessions/$(date +%Y-%m-%d-%H%M).md"`
2. **Health**: Run build/test/lint, capture status
3. **Git**: `git branch --show-current && git status -s && git log -5 --oneline`
4. **Analyze**: Infer from session (DO NOT ASK USER):
   - Done: commits made, PRs, completed work
   - Failed: errors encountered (with Tried/Error/Why/Need)
   - Blockers: missing deps, permissions, decisions needed
   - Watch-outs: gotchas discovered
   - Severity: derive from health checks
   - Resume: next logical step with file:line
5. **Write**: HANDOFF.md with all sections
6. **Validate**: Required fields present?
7. **Confirm**: Summary output

---

## STATUS

Read HANDOFF.md → Output: Severity, Branch, Health, Blockers, Resume.

---

## Severity Guide

| 🔴 CRITICAL | Production down, security issue, data loss risk |
| 🟡 IN PROGRESS | Mid-feature, tests failing, WIP |
| 🟢 READY | All green, clean state |

---

## Failed Section Format

```markdown
### [Issue Name]
- **Tried:** [What was attempted]
- **Error:** [Exact error message]
- **Why:** [Root cause analysis]
- **Need:** [What would fix it]
```

Never skip the WHY. Next session will repeat the mistake.

---

## Resume Format

```markdown
**Next:** [Specific action at file:line]
**Files:** [files to read first]
**Context:** [why this is next]
```

Vague resume = lost context = wasted time.
