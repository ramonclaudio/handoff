# Changelog

## [2.0.0] - 2026-01-11

Medical-grade handoff system. SBAR framework. Zero agents.

### Added
- **Severity levels**: 🔴 CRITICAL, 🟡 IN PROGRESS, 🟢 READY
- **Health checks**: Build/test/lint status captured on END
- **Watch Out For**: Anticipatory guidance section
- **Blockers**: Explicit blocking issues tracking
- **Drift detection**: Detect if state changed since last handoff
- **Read-back confirmation**: Structured output on START, wait for confirmation
- **Handoff validation**: Required fields checked before END completes
- **SBAR framework**: Situation, Background, Assessment, Recommendation

### Changed
- **No agents**: All operations inline (was 4-5 background agents)
- **Scoped queries**: All data fetched since last session only
- **Failed section**: Now requires Tried/Error/Why/Need structure
- **Resume section**: Now requires Next/Files/Context structure
- **Timeline-based**: Uses session archive timestamps, not arbitrary limits

### Removed
- `handoff-explorer` agent (use built-in Explore)
- Background agent spawning
- Arbitrary commit/PR limits

### Token Impact
| Operation | v1.0 | v2.0 |
|-----------|------|------|
| START | ~55k tokens | ~5-10k tokens |
| Definition | ~4k tokens | ~1.5k tokens |

---

## [1.0.0] - 2026-01-09

Initial release with parallel agent architecture.

### Features
- 4 parallel agents for START
- 5 parallel agents for END
- CONTEXT.md and HANDOFF.md structure
- Session archiving
