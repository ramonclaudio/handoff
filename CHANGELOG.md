# Changelog

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
