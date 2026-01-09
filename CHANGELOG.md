# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-09

Initial public release.

### Commands
- `/handoff:run init` - Create `.handoff/` structure with templates
- `/handoff:run start` - Gather context with 4 parallel agents
- `/handoff:run end` - Archive state with 5 parallel agents
- `/handoff:run status` - Quick status check
- `/handoff:run clean` - Reset to clean slate

### Components
- `handoff` agent for standalone use
- `handoff-explorer` agent for lightweight codebase discovery
- `handoff` skill for skill-only installation
- `SessionStart` hook to remind about `/handoff:run start`
- `SessionEnd` hook to remind about `/handoff:run end`

### Features
- Parallel agent workflows (sonnet for data, opus for reasoning)
- Quality validation for handoff files
- Inline templates for CONTEXT.md and HANDOFF.md
- Three installation methods: plugin, skill, or agent
