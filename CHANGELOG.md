# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-05

### Added
- **Rate limit detection**: New `Stop` hook detects rate limit errors in transcript
  - Recognizes patterns: `rate.limit`, `429`, `quota.exceeded`, etc.
  - Integrates with `ccusage` CLI for accurate timing info
  - Shows wait time and suggested resume time
- **Explorer agent**: `handoff-explorer` - lightweight haiku-based codebase exploration
  - Uses Glob/Grep instead of Read for efficient discovery
  - Reports file patterns and structure without loading contents
  - Cyan color indicator in UI
- **Session rotation**: Automatically keeps last 30 archived sessions
  - Older sessions auto-deleted on SessionEnd hook
  - Prevents `.handoff/sessions/` from growing unbounded
- **Progress indicators**: Visual progress during workflows
  - START: 4 phases with emoji indicators
  - END: 5 phases with emoji indicators
- **Improved agent examples**: Added 4 `<example>` blocks to handoff-manager
  - Explicit trigger scenarios for better auto-invocation
  - Covers: resume, end session, context full, explicit command
- **Improved skill triggers**: Added quoted trigger phrases
  - More specific: "handoff", "context is full", "save my progress", etc.
  - Better model-invoked activation

### Changed
- Updated README with comprehensive requirements section
  - Required vs optional dependencies
  - Environment variables table
  - MCP configuration guide

## [1.1.0] - 2026-01-05

### Changed
- **BREAKING:** Restricted `allowed-tools` to specific subcommands for security
  - Git: read-only operations only (branch, status, log, diff, stash list)
  - GitHub CLI: read + list operations only
  - No more wildcard `Bash(git:*)` that allowed destructive commands
- Added decision gates to workflows (no auto-execution)
  - START: Must confirm before executing resume action
  - END: Runs validation before allowing session end
- Fixed shebangs to be portable (`#!/usr/bin/env bash`)

### Added
- `PreToolUse` hook with quality checker for HANDOFF.md/CONTEXT.md writes
- Validation agent in END workflow checks:
  - Resume section has file:line reference
  - Files to read list is non-empty
  - Status emoji is present
  - File doesn't exceed size limits
- Timeouts on all hooks (5-10 seconds)
- `quality-check.sh` script for anti-bloat validation
- Model selection table in skill documentation

### Fixed
- Scripts now use portable `#!/usr/bin/env bash` shebang
- Hooks now have explicit timeouts

## [1.0.0] - 2025-01-05

Initial release as a Claude Code plugin.

### Added
- `/handoff` command with subcommands: `init`, `start`, `end`, `status`
- `handoff-manager` agent for parallel workflow orchestration
- `handoff-awareness` skill for model-invoked session continuity
- `SessionStart` hook to remind about `/handoff start`
- `SessionEnd` hook to remind about `/handoff end`
- `marketplace.json` for distribution via `/plugin marketplace add`
- Templates for CONTEXT.md and HANDOFF.md

### Plugin Structure
```
handoff/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── commands/
│   └── handoff.md
├── agents/
│   └── handoff-manager.md
├── skills/
│   └── handoff-awareness/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── scripts/
│   ├── session-start.sh
│   ├── session-end.sh
│   └── quality-check.sh
├── templates/
│   ├── CONTEXT.md
│   └── HANDOFF.md
├── README.md
├── CHANGELOG.md
└── LICENSE
```
