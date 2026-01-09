# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-09

Initial public release.

### Commands
- `/handoff init` - Create `.handoff/` structure with templates
- `/handoff start` - Gather context with 4 parallel agents
- `/handoff end` - Archive state with 5 parallel agents
- `/handoff status` - Quick status check
- `/handoff clean` - Reset to clean slate

### Components
- `handoff-manager` agent for parallel workflow orchestration
- `handoff-explorer` agent for lightweight codebase discovery
- `handoff-awareness` skill for model-invoked session continuity
- `SessionStart` hook to remind about `/handoff start`
- `SessionEnd` hook to remind about `/handoff end`
- `Stop` hook for rate limit detection
- `PreToolUse` hook for quality validation

### Features
- Parallel agent workflows (sonnet for data, opus for reasoning)
- Rate limit detection with wait time calculation
- Quality validation for handoff files
- Templates for CONTEXT.md and HANDOFF.md
