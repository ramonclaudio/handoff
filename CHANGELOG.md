# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-01-05

### Added
- `marketplace.json` for proper plugin distribution via `/plugin marketplace add`

### Fixed
- README install instructions now use correct marketplace syntax

## [1.0.0] - 2025-01-05

### Added
- Initial plugin release
- `/handoff` command with subcommands: `start`, `end`, `status`, `init`
- `handoff-manager` agent for parallel workflow orchestration
- `handoff-awareness` skill for auto-invoked session continuity
- `SessionStart` hook for handoff file detection reminders
- Templates for CONTEXT.md and HANDOFF.md

### Changed
- Converted from example files to proper Claude Code plugin format
- Restructured to follow official plugin directory structure

### Plugin Structure
```
handoff/
├── .claude-plugin/
│   └── plugin.json
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
│   └── session-start.sh
├── templates/
│   ├── CONTEXT.md
│   └── HANDOFF.md
├── README.md
├── CHANGELOG.md
└── LICENSE
```
