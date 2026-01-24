# Changelog

## [1.2.0] - 2026-01-24

Task system migration and subagent tracking. Requires Claude Code 2.1.16+.

### Changed
- **Task system**: Replaced deprecated `TodoWrite` with new Task tools (`TaskCreate`, `TaskUpdate`, `TaskGet`, `TaskList`)
- Resume points now persist in `~/.claude/tasks` with `handoff: true` metadata
- Previous session tasks marked complete on START instead of cleared

### Added
- **Subagent tracking**: New `SubagentStart`/`SubagentStop` hooks log subagent activity to `.handoff/.subagents.log`
- START phase now shows which subagents ran during previous session
- END phase clears subagent log after archiving

### Fixed
- Session end message now shows `/handoff end` instead of legacy `/handoff:run end`

### Why
- `TodoWrite` deprecated in Claude Code 2.1.16 in favor of persistent Task system
- Tasks support dependencies, blockers, and cross-session persistence in `~/.claude/tasks`
- Subagent activity tracking provides richer context for complex sessions

---

## [1.1.0] - 2026-01-16

Session ID integration. Requires Claude Code 2.1.9+.

### Changed
- Archive naming uses `${CLAUDE_SESSION_ID}` instead of timestamps
- Session metadata includes session ID for correlation
- Hook script parses and displays session ID

### Why
- Timestamps can collide (multiple sessions in same minute)
- Session IDs enable direct correlation with Claude transcripts
- No more guessing which archive matches which conversation

---

## [1.0.0] - 2026-01-11

First stable release. Skill-first architecture with SBAR framework.

### Features
- **SBAR framework**: Structured handoffs (Situation, Background, Assessment, Recommendation)
- **Severity levels**: 🔴 CRITICAL, 🟡 IN PROGRESS, 🟢 READY
- **Health checks**: Build/test/lint status captured on END
- **Drift detection**: Detect if state changed since last handoff
- **Handoff validation**: Required fields checked before END completes
- **Session archiving**: Timestamped archives in `.handoff/sessions/`

### Architecture
- **Skill as source of truth**: `/handoff` skill contains full implementation
- **Thin agent wrapper**: Agent uses `tools: Skill` to invoke `/handoff`
- **Inline execution**: No background agents, direct tool calls
- **Timeline-scoped**: All queries scoped to "since last session"

### HANDOFF.md Structure
- Severity (required)
- Health table (Build/Tests/Lint)
- Git state
- Done (concrete items with refs)
- Failed (with Tried/Error/Why/Need)
- Blockers
- Watch Out For
- Resume (Next + Files + Context)

---

## [0.x] - 2026-01-05 to 2026-01-10

Alpha releases. Experimental parallel agent architecture.

- 4-5 background agents for START/END operations
- High token usage (~55k per START)
- Command-based invocation (`/handoff:run`)
