---
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

Medical-grade session continuity. Like hospital shift changes - bad handoffs kill projects.

## Argument: $ARGUMENTS

---

## INIT

If `$ARGUMENTS` = "init":

```bash
mkdir -p .handoff/sessions
```

Write `.handoff/CONTEXT.md`:
```markdown
# Project Name

> One-line description

## Stack
| Layer | Tech | Version |
|-------|------|---------|

## Commands
| Command | Purpose |
|---------|---------|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run test` | Run tests |
| `npm run lint` | Lint check |

## Critical Paths
Files/areas that are high-risk or complex:
-

## What Never Works
| Problem | Solution |
|---------|----------|

## Patterns
Key patterns and conventions used in this codebase.
```

Write `.handoff/HANDOFF.md`:
```markdown
# Handoff

> Session: YYYY-MM-DD HH:MM
> Severity: 🟢 READY

## Health
| Check | Status |
|-------|--------|
| Build | ⏸️ not run |
| Tests | ⏸️ not run |
| Lint | ⏸️ not run |

## Git
- Branch: main
- Status: clean

## Done
_Nothing yet._

## Failed
_None._

## Blockers
_None._

## Watch Out For
_None yet._

## Resume
**Next:** Run `/handoff:run start` to begin
**Files:** -
**Context:** Fresh initialization
```

Done. Run `/handoff:run start` to begin first session.

---

## START

If `$ARGUMENTS` is empty or = "start":

### Phase 1: Establish Timeline

```bash
ls -1 .handoff/sessions/*.md 2>/dev/null | sort -r | head -1
```

Extract timestamp from filename (`YYYY-MM-DD-HHMM.md`).
If no sessions, this is first start - use all available history.

### Phase 2: Gather State

**2a. Project Identity**
```
Read .handoff/CONTEXT.md
```
Extract: stack, commands, critical paths, patterns, gotchas.

**2b. Last Handoff State**
```
Read .handoff/HANDOFF.md
```
Extract: severity, health status, done, failed, blockers, watch-out-for, resume point.

**2c. Current Git State**
```bash
git branch --show-current
git status -s | head -20
```

**2d. Commits Since Last Session**
```bash
git log --since="YYYY-MM-DD HH:MM" --format="%h %s%n%b" 2>/dev/null
```
If no session history, use `git log -10 --format="%h %s%n%b"`.

**2e. PR Activity Since Last Session**
```bash
# Currently open
gh pr list --state=open --json number,title,body,headRefName 2>/dev/null

# Merged since
gh pr list --state=merged --search "merged:>YYYY-MM-DD" --json number,title,body 2>/dev/null

# Opened since
gh pr list --state=all --search "created:>YYYY-MM-DD" --json number,title,body,state 2>/dev/null
```

**2f. Linear Issues (if configured)**
```
mcp__plugin_linear_linear__list_issues
```
Filter to issues updated since last session.

### Phase 3: Assess Current Health

Check if state has drifted since handoff:
- Did git status change? (new commits from elsewhere?)
- Are there uncommitted changes not in handoff?

### Phase 4: Output Read-Back

```
╔══════════════════════════════════════════════════════════════╗
║  HANDOFF RECEIVED                                            ║
╠══════════════════════════════════════════════════════════════╣
║  Project: [name]                                             ║
║  Stack: [from CONTEXT.md]                                    ║
║  Severity: [🔴 CRITICAL | 🟡 IN PROGRESS | 🟢 READY]         ║
╚══════════════════════════════════════════════════════════════╝

SINCE LAST SESSION ([date], [N] days ago)
├─ Commits: [N]
├─ PRs: [N] merged, [N] opened, [N] open
└─ Issues: [N] updated

HEALTH AT HANDOFF
├─ Build: [✓|✗|⏸️]
├─ Tests: [✓ N/N | ✗ N failed | ⏸️]
└─ Lint: [✓|✗|⏸️]

CURRENT STATE
├─ Branch: [branch]
├─ Status: [clean | N modified, N untracked]
└─ Drift: [none | ⚠️ changed since handoff]

⚠️  WATCH OUT FOR
[bulleted list from HANDOFF.md]

🚫 BLOCKERS ([N])
[bulleted list from HANDOFF.md]

❌ FAILED (Don't Retry)
[list of failed items with reasons]

▶️  RESUME
[Next action from HANDOFF.md]
[Files to read]
[Context/reasoning]

────────────────────────────────────────────────────────────────
Ready. What would you like to work on?
```

**Context loaded. Ready to proceed with user's task.**

---

## END

If `$ARGUMENTS` = "end":

### Phase 1: Archive Current State

```bash
cp .handoff/HANDOFF.md ".handoff/sessions/$(date +%Y-%m-%d-%H%M).md"
```

### Phase 2: Capture Health Status

Run health checks using commands from CONTEXT.md:

```bash
# Build (capture exit code and last 5 lines)
npm run build 2>&1 | tail -5; echo "EXIT:$?"

# Tests (capture exit code and summary)
npm run test 2>&1 | tail -10; echo "EXIT:$?"

# Lint (capture exit code and issues)
npm run lint 2>&1 | tail -5; echo "EXIT:$?"
```

Detect package manager from lockfile:
- `bun.lockb` → bun
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn
- `package-lock.json` → npm

### Phase 3: Capture Git State

```bash
git branch --show-current
git status -s | head -20
git log -5 --format="%h %s"
```

### Phase 4: Analyze Session (Automated)

**Infer from conversation context - DO NOT ASK USER:**

1. **Severity** - Derive from health checks:
   - 🔴 CRITICAL - Build failing OR tests failing with blocking errors
   - 🟡 IN PROGRESS - Tests failing OR uncommitted work OR mid-feature
   - 🟢 READY - Build ✓, Tests ✓, Lint ✓, git clean

2. **Done** - Extract from session:
   - Commits made this session (from git log)
   - PRs created/merged
   - Files successfully modified
   - Features/fixes completed

3. **Failed** - Extract from session:
   - Commands that returned non-zero exit codes
   - Error messages encountered
   - Approaches that were abandoned
   - ALWAYS include: Tried / Error / Why / Need

4. **Blockers** - Extract from session:
   - External dependencies mentioned as unavailable
   - Permissions/credentials that were missing
   - Decisions that couldn't be made
   - APIs/services that were down

5. **Watch Out For** - Extract from session:
   - Gotchas discovered (things that surprised us)
   - Workarounds that were needed
   - Environment-specific behaviors
   - Edge cases encountered

6. **Resume Point** - Derive from session:
   - If mid-feature: next logical step in current work
   - If blocked: what to do when blocker resolves
   - If complete: next item from backlog/issues
   - ALWAYS include specific file:line when possible

### Phase 5: Write HANDOFF.md

```markdown
# Handoff

> Session: [YYYY-MM-DD HH:MM]
> Severity: [🔴 CRITICAL | 🟡 IN PROGRESS | 🟢 READY]

## Health
| Check | Status | Detail |
|-------|--------|--------|
| Build | [✓\|✗\|⏸️] | [pass/fail/error message] |
| Tests | [✓\|✗\|⏸️] | [N/N passing or failure info] |
| Lint | [✓\|✗\|⏸️] | [clean/N warnings/N errors] |

## Git
- Branch: [branch]
- Status: [clean/dirty]
- Last commits:
  ```
  [hash] [message]
  [hash] [message]
  [hash] [message]
  ```

## Done
- [x] [Concrete accomplishment with PR/commit ref]
- [x] [Another accomplishment]

## Failed
### [Issue Name]
- **Tried:** [What was attempted]
- **Error:** [Exact error message]
- **Why:** [Root cause analysis]
- **Need:** [What would fix it]

## Blockers
- [ ] [Blocker with context]
- [ ] [Another blocker]

## Watch Out For
- [Gotcha or warning]
- [Another gotcha]

## Resume
**Next:** [Specific action at file:line]
**Files:** [comma-separated list of files to read first]
**Context:** [Why this is the right next step]
```

### Phase 6: Validate Handoff Quality

**REQUIRED (fail if missing):**
- [ ] Severity is set
- [ ] Health status captured
- [ ] Resume has specific file:line
- [ ] Resume has files to read
- [ ] If failures exist, they have root cause analysis

**WARNINGS:**
- [ ] File exceeds 100 lines (bloat risk)
- [ ] Resume is vague ("continue working on X")
- [ ] No watch-out-for items (really nothing learned?)
- [ ] Health checks all skipped

### Phase 7: Confirm

```
╔══════════════════════════════════════════════════════════════╗
║  HANDOFF COMPLETE                                            ║
╠══════════════════════════════════════════════════════════════╣
║  Archived: sessions/[timestamp].md                           ║
║  Severity: [emoji + label]                                   ║
╚══════════════════════════════════════════════════════════════╝

HEALTH
├─ Build: [status]
├─ Tests: [status]
└─ Lint: [status]

SESSION SUMMARY
├─ Done: [N] items
├─ Failed: [N] items (documented)
├─ Blockers: [N] active
└─ Watch-outs: [N] added

RESUME POINT
[Next action]

────────────────────────────────────────────────────────────────
Safe to end session.
```

---

## STATUS

If `$ARGUMENTS` = "status":

Quick check, no health runs:

```
Read .handoff/HANDOFF.md
```

Output:
```
Severity: [emoji]
Branch: [branch]
Health: Build [status] | Tests [status] | Lint [status]
Blockers: [N]
Resume: [next action]
```

---

## Severity Guide

| Level | When | Meaning |
|-------|------|---------|
| 🔴 CRITICAL | Production down, data loss risk, security issue | Drop everything, fix now |
| 🟡 IN PROGRESS | Mid-feature, tests failing, WIP | Continue current work |
| 🟢 READY | All green, clean state | Pick up new work |

---

## Health Check Commands

Detect from CONTEXT.md or infer from lockfile:

| Lockfile | Build | Test | Lint |
|----------|-------|------|------|
| bun.lockb | `bun run build` | `bun test` | `bun run lint` |
| package-lock.json | `npm run build` | `npm test` | `npm run lint` |
| pnpm-lock.yaml | `pnpm build` | `pnpm test` | `pnpm lint` |
| yarn.lock | `yarn build` | `yarn test` | `yarn lint` |

---

## Anti-Patterns

**DON'T:**
- Skip health checks on END (you're leaving blind)
- Write vague resume points ("keep working on auth")
- Omit failure root cause (next session repeats mistake)
- Ignore blockers (they don't disappear)
- Leave severity at 🟢 when tests are failing

**DO:**
- Capture exact error messages in failures
- Reference specific file:line in resume
- Document gotchas immediately when discovered
- Be honest about severity
- Validate handoff before ending
