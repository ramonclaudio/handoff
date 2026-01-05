# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
│   └── session-end.sh
├── templates/
│   ├── CONTEXT.md
│   └── HANDOFF.md
├── README.md
├── CHANGELOG.md
└── LICENSE
```
