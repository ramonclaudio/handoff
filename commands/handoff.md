---
description: Session continuity - gather context at start, archive state at end
argument-hint: start|end|status|init|clean [path]
allowed-tools:
  # Git (read-only operations only)
  - Bash(git branch:*)
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git stash list:*)
  - Bash(git rev-parse:*)
  # GitHub CLI (read + PR comments)
  - Bash(gh pr list:*)
  - Bash(gh pr view:*)
  - Bash(gh issue list:*)
  - Bash(gh issue view:*)
  # File operations (safe)
  - Bash(mkdir -p:*)
  - Bash(cp:*)
  - Bash(mv:*)
  - Bash(rm -f .handoff/sessions/*.md)
  - Bash(date:*)
  - Bash(ls:*)
  - Bash(basename:*)
  - Bash(test:*)
  # Core tools
  - Read
  - Write
  - Edit
  - TodoWrite
  - Task
  - TaskOutput
  # Linear integration
  - mcp__plugin_linear_linear__list_issues
  - mcp__plugin_linear_linear__update_issue
  - mcp__plugin_linear_linear__create_issue
---

# Handoff System

Session continuity across context windows.

## Current Context

- Project: !`basename $(git rev-parse --show-toplevel 2>/dev/null || pwd)`
- Branch: !`git branch --show-current 2>/dev/null || echo "not a git repo"`
- Handoff exists: !`test -f .handoff/HANDOFF.md && echo "yes" || echo "no"`

## Commands

| Command | Action |
|---------|--------|
| `/handoff` | Auto-detect: start if beginning, end if wrapping up |
| `/handoff start` | Gather context with 4 parallel agents |
| `/handoff end` | Archive + update with 5 parallel agents |
| `/handoff status` | Quick status check |
| `/handoff init` | Initialize handoff in current project |
| `/handoff clean` | Reset to clean slate (deletes sessions, resets templates) |

## Arguments

$ARGUMENTS

## File Locations

Default (project-local):
```
.handoff/
├── CONTEXT.md     # Permanent project knowledge
├── HANDOFF.md     # Session state (updated each session)
└── sessions/      # Archived handoffs
```

Or custom via `$HANDOFF_DIR` environment variable.

## INIT Workflow

If `$ARGUMENTS` contains "init":

1. Create handoff structure:
```bash
mkdir -p .handoff/sessions
```

2. Read and copy the CONTEXT.md template:
```
Read ${CLAUDE_PLUGIN_ROOT}/templates/CONTEXT.md
```
Copy to `.handoff/CONTEXT.md`, replacing placeholder values with project info.

3. Read and copy the HANDOFF.md template:
```
Read ${CLAUDE_PLUGIN_ROOT}/templates/HANDOFF.md
```
Copy to `.handoff/HANDOFF.md`, replacing placeholder values.

4. Confirm creation and suggest running `/handoff start`.

---

## START Workflow (4 Parallel Agents)

If `$ARGUMENTS` is empty or contains "start":

**Show progress to user:**
```
📊 Phase 1/4: Launching context gathering agents...
```

Launch 4 background agents simultaneously:

### Agent 1: Git State (sonnet)
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
"Get complete git state:
- git branch --show-current
- git status --short
- git log -10 --format='%h %s%n%b---'
- git diff --stat HEAD~5
- git stash list
Return structured summary."
```

### Agent 2: GitHub PRs (sonnet)
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
"Get PR information:
- gh pr list --state=open --json number,title,body,headRefName,commits
- gh pr list --state=merged --limit=5 --json number,title,body,mergedAt
Return full PR bodies, not just titles."
```

### Agent 3: Issue Tracker (sonnet)
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
"Get issue tracker state. Try GitHub first:
- gh issue list --state=open --json number,title,body

If Linear is configured (check for mcp__plugin_linear), also query:
- mcp__plugin_linear_linear__list_issues

Return issues with full descriptions."
```

### Agent 4: Context Analysis (opus)
```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
"Read and analyze handoff files:
- Read .handoff/CONTEXT.md (or HANDOFF_DIR path)
- Read .handoff/HANDOFF.md
- Extract the RESUME section
- Identify files that need to be read
- Create action plan for session

Return:
1. Key context points
2. Resume point with specific actions
3. Files to read immediately
4. Suggested first task"
```

**Then:**
```
⏳ Phase 2/4: Agents working in parallel...
```
1. Poll all agents with TaskOutput

```
✅ Phase 3/4: All agents complete. Analyzing results...
```
2. Read FILES TOUCHED from HANDOFF.md
3. **Present resume plan to user:**
   ```
   📋 Session Context Gathered

   Resume Point: [from Agent 4]
   Files to Read: [list]
   Suggested First Task: [action]

   Ready to proceed? (y/n)
   ```
4. **WAIT for user approval before executing RESUME action**
5. Only after approval: Execute RESUME action

```
🚀 Phase 4/4: Ready to resume
```

**CRITICAL:** Do NOT auto-execute. Always ask for confirmation.

---

## STATUS Workflow

If `$ARGUMENTS` contains "status":

Quick status without full agent workflow:
1. Read .handoff/HANDOFF.md
2. Show: Status, Branch, Last Done, Resume point
3. No agents needed

---

## CLEAN Workflow

If `$ARGUMENTS` contains "clean":

**⚠️ Destructive operation - confirm with user first:**
```
⚠️ This will delete all session history and reset handoff files.
Continue? (y/n)
```

After confirmation:
1. Delete all session archives:
```bash
rm -f .handoff/sessions/*.md
```

2. Reset CONTEXT.md to template:
```
Read ${CLAUDE_PLUGIN_ROOT}/templates/CONTEXT.md
Write to .handoff/CONTEXT.md
```

3. Reset HANDOFF.md to template:
```
Read ${CLAUDE_PLUGIN_ROOT}/templates/HANDOFF.md
Write to .handoff/HANDOFF.md
```

4. Confirm:
```
✅ Handoff reset to clean slate
   - Sessions deleted: [count]
   - CONTEXT.md: reset to template
   - HANDOFF.md: reset to template
```

---

## END Workflow (5 Parallel Agents)

If `$ARGUMENTS` contains "end":

**Show progress to user:**
```
📊 Phase 1/5: Launching archive agents...
```

Launch 5 background agents simultaneously:

### Agent 1: Git + Archive (sonnet)
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
"Get git state and archive:
1. Get current git state (branch, status, log -5)
2. Get open PRs with full bodies
3. Archive .handoff/HANDOFF.md to .handoff/sessions/$(date +%Y-%m-%d-%H%M).md
Return git summary for handoff update."
```

### Agent 2: Package Versions (sonnet)
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
"Compare package versions:
1. Read package.json (or pyproject.toml, Cargo.toml, etc.)
2. Read .handoff/CONTEXT.md stack section
3. Report any version changes since last session
Return version diff if any."
```

### Agent 3: Issue Sync (sonnet)
```
Task(subagent_type="general-purpose", model="sonnet", run_in_background=true):
"Sync issue tracker:
1. Check what was done this session
2. Update issue states if needed:
   - mcp__plugin_linear_linear__update_issue state:'Done'
   - Or gh issue close
3. Create new issues for discovered work
Return sync summary."
```

### Agent 4: Update HANDOFF.md (opus)
```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
"Update .handoff/HANDOFF.md with complete session state:

## Status
[🟢 Ready / 🟡 In Progress / 🔴 Blocked]

## Git State
- Branch: [from agent 1]
- Status: [clean/dirty]
- Recent commits: [last 3-5 with full messages]

## Recent PRs
[From agent 1, with full bodies]

## Done
- [What was accomplished this session]

## Failed
### ❌ [Issue name]
- **Attempted:** [What was tried]
- **Error:** [Exact error message]
- **Why:** [Root cause analysis]
- **Would need:** [What would fix it]

## Decisions
| Decision | Alternatives | Reasoning |
|----------|--------------|-----------|
| [Choice made] | [Other options] | [Why this choice] |

## Files Touched
| File | Lines | Change |
|------|-------|--------|
| [path] | [line range] | [what changed] |

## Resume
**Next:** [Specific action with file:line reference]
**Files to read:** [comma-separated list of files to read first]
**Context:** [Why this is the right next step]

Write the complete updated file."
```

### Agent 5: Update CONTEXT.md (opus)
```
Task(subagent_type="general-purpose", model="opus", run_in_background=true):
"Review if .handoff/CONTEXT.md needs updates:

Check for:
1. Stack version changes (from agent 2)
2. New 'What Never Works' discoveries
3. New patterns or architecture changes
4. New commands or workflows

Only update if there are meaningful changes.
If updating, preserve existing content and add new sections.

Return: 'No updates needed' or the specific changes made."
```

**Then:**
```
⏳ Phase 2/5: Agents working in parallel...
```
1. Poll all agents with TaskOutput

```
✅ Phase 3/5: All agents complete. Validating quality...
```
2. **Launch validation agent (opus):**
   ```
   Task(subagent_type="general-purpose", model="opus", run_in_background=false):
   "Validate handoff quality. Read .handoff/HANDOFF.md and check:

   REQUIRED (fail if missing):
   - Resume section has specific file:line reference
   - Files to read list is non-empty
   - Status is one of: 🟢 🟡 🔴

   WARNINGS (report but don't fail):
   - File exceeds 120 lines (bloat risk)
   - Resume is vague ('continue working on X')
   - No failures documented despite errors in session

   Return: PASS with summary, or FAIL with specific issues to fix."
   ```
3. If validation FAILS: Fix issues before proceeding

```
📝 Phase 4/5: Verifying files updated...
```
4. Verify HANDOFF.md was updated
5. Confirm session archived to `.handoff/sessions/`

```
🎉 Phase 5/5: Session archived successfully
```
6. **Present summary to user:**
   ```
   ✅ Session Archived

   Done: [count] items
   Failed: [count] items (documented)
   Resume: [specific action]

   Safe to end session.
   ```

---

## Model Selection

| Task | Model | Why |
|------|-------|-----|
| Git, gh, packages | sonnet | Fast, structured data |
| Issue queries | sonnet | Structured data |
| Analysis, writing | opus | Quality reasoning |

---

## Anti-Bloat Guidelines

**DO include:**
- Full commit messages (body, not just subject)
- Full PR bodies
- Specific failure details with root cause
- Files with line numbers
- Exact resume actions

**DON'T include:**
- File contents (AI can read on demand)
- More than 10 commits
- Historical sessions in main files
- Verbose explanations

**Size targets:**
- CONTEXT.md: ~100-150 lines
- HANDOFF.md: ~80-120 lines
