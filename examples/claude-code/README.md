# Claude Code Implementation

Optimized handoff workflow using Claude Code's background agents and parallel execution.

## Key Features

- **Parallel background agents** - Run multiple data-gathering tasks simultaneously
- **Model selection** - Sonnet for data fetching, Opus for reasoning
- **Polling** - Launch agents, continue work, poll when needed
- **Skills** - Reusable workflows for START/END

## Model Selection

| Task Type | Model | Why |
|-----------|-------|-----|
| Git commands, file reads | sonnet | Fast, accurate for data |
| GitHub/Linear queries | sonnet | Structured data retrieval |
| Analysis, writing, planning | opus | Best reasoning quality |

## Directory Structure

```
.claude/
├── skills/
│   ├── handoff-start.md    # START workflow skill
│   └── handoff-end.md      # END workflow skill
└── CLAUDE.md               # Project instructions (reference handoff)
```

## Usage

### Quick Commands

```
/handoff-start              # Run START workflow
/handoff-end                # Run END workflow
```

### Manual Execution

The skills can also be invoked by asking Claude to run the handoff workflow.
