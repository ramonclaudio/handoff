<p align="center">
  <img src=".github/assets/logo.png" alt="Handoff" width="400">
</p>

<p align="center">
  <strong>Session continuity for AI coding assistants.</strong>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#how-it-works">How It Works</a>
</p>

---

Inspired by medical handoffs, this plugin ensures nothing gets lost when switching contexts, ending sessions, or resuming work.

Two markdown files capture everything needed to continue seamlessly: what's done, what failed, and exactly where to resume.

## Installation

Choose one:

| Method | Install | Invoke |
| :--- | :--- | :--- |
| **Plugin** | `/plugin install handoff@ramonclaudio-handoff` | `/handoff:run start` |
| **Skill** | `cp -r skills/handoff ~/.claude/skills/` | `/handoff start` |
| **Agent** | `cp agents/handoff.md ~/.claude/agents/` | "Use the handoff agent to start" |

## Usage

```
init      Create .handoff/ structure
start     Gather context (4 parallel agents)
end       Archive state (5 parallel agents)
status    Quick status check
clean     Reset to templates
```

## Structure

```
.handoff/
├── CONTEXT.md     # Permanent: stack, patterns, gotchas
├── HANDOFF.md     # Session: git state, progress, resume point
└── sessions/      # Archived handoffs
```

## How It Works

### START (4 parallel agents)

| Agent | Model | Task |
| :---: | :---: | :--- |
| 1 | sonnet | Git state + full commit messages |
| 2 | sonnet | PRs with full bodies |
| 3 | sonnet | Issues (GitHub/Linear) |
| 4 | opus | Analyze context, plan resume |

### END (5 parallel agents)

| Agent | Model | Task |
| :---: | :---: | :--- |
| 1 | sonnet | Git state + archive session |
| 2 | sonnet | Package version changes |
| 3 | sonnet | Issue tracker sync |
| 4 | opus | Update HANDOFF.md |
| 5 | opus | Update CONTEXT.md if needed |

## Requirements

- Claude Code 1.0.33+
- Git

**Optional:** `gh` (GitHub CLI), Linear MCP

## License

MIT
