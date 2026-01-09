<p align="center">
  <img src=".github/assets/logo.png" alt="Handoff" width="400">
</p>

<p align="center">
  <strong>Session continuity for AI coding assistants.</strong>
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#commands">Commands</a> •
  <a href="#how-it-works">How It Works</a>
</p>

---

Inspired by medical handoffs, the critical process of transferring patient care between providers. This plugin ensures nothing gets lost when switching contexts, ending sessions, or resuming work.

Two markdown files capture everything needed to continue seamlessly: what's done, what failed, and exactly where to resume.

## Installation

### Option A: As a Plugin (recommended)

**Via marketplace:**

```bash
/plugin install handoff@ramonclaudio-handoff
```

**Local development:**

```bash
git clone https://github.com/ramonclaudio/handoff.git ~/Developer/handoff
claude --plugin-dir ~/Developer/handoff
```

Commands: `/handoff:run`, `/handoff:run start`, `/handoff:run end`, etc.

### Option B: As a Standalone Skill

Copy the skill to your personal skills directory:

```bash
mkdir -p ~/.claude/skills
cp -r path/to/handoff/skills/handoff ~/.claude/skills/
```

Commands: `/handoff`, `/handoff start`, `/handoff end`, etc.

## Quick Start

**Plugin users:**
```bash
/handoff:run init     # Create .handoff/ structure
/handoff:run start    # Gather context (4 parallel agents)
# ... work ...
/handoff:run end      # Archive state (5 parallel agents)
```

**Standalone skill users:**
```bash
/handoff init         # Create .handoff/ structure
/handoff start        # Gather context (4 parallel agents)
# ... work ...
/handoff end          # Archive state (5 parallel agents)
```

## Commands

| Plugin | Standalone | Action |
| :--- | :--- | :--- |
| `/handoff:run` | `/handoff` | Auto-detect: start or end based on context |
| `/handoff:run init` | `/handoff init` | Create `.handoff/` with templates |
| `/handoff:run start` | `/handoff start` | Gather git, PRs, issues with parallel agents |
| `/handoff:run end` | `/handoff end` | Archive session, update handoff files |
| `/handoff:run status` | `/handoff status` | Quick status check (no agents) |
| `/handoff:run clean` | `/handoff clean` | Delete sessions, reset to templates |

## Structure

```text
.handoff/
├── CONTEXT.md     # Permanent: stack, commands, gotchas
├── HANDOFF.md     # Session: git state, progress, resume point
└── sessions/      # Archived handoffs
```

> [!TIP]
> Override the default location with the `$HANDOFF_DIR` environment variable.

## How It Works

<details>
<summary><strong>Parallel Agents: START (4 agents)</strong></summary>

| Agent | Model | Task |
| :---: | :---: | :--- |
| 1 | sonnet | Git state + full commit messages |
| 2 | sonnet | PRs with full bodies |
| 3 | sonnet | Issues (GitHub/Linear) |
| 4 | opus | Analyze context, plan resume |

</details>

<details>
<summary><strong>Parallel Agents: END (5 agents)</strong></summary>

| Agent | Model | Task |
| :---: | :---: | :--- |
| 1 | sonnet | Git state + archive |
| 2 | sonnet | Package version changes |
| 3 | sonnet | Issue tracker sync |
| 4 | opus | Update HANDOFF.md |
| 5 | opus | Update CONTEXT.md |

</details>

## Key Principles

<details>
<summary><strong>Get full details</strong></summary>

```bash
git log -10 --format='%h %s%n%b---'  # Full commit messages
gh pr list --json number,title,body   # Full PR bodies
```

</details>

<details>
<summary><strong>Document failures properly</strong></summary>

```markdown
### ❌ JWT token refresh
- **Attempted:** Added refresh logic in useAuth hook
- **Error:** Token expired still appears after refresh
- **Why:** Refresh happens async, component re-renders before token updates
- **Would need:** Suspense boundary or loading state during refresh
```

</details>

<details>
<summary><strong>Be specific about resume</strong></summary>

```markdown
**Next:** Add Suspense boundary around AuthProvider in app/_layout.tsx:12
**Files to read:** lib/auth.ts:45-60, app/_layout.tsx
**Context:** Token refresh is async, need to prevent render during refresh
```

</details>

## Components

| Component | Type | Invocation |
| :--- | :--- | :--- |
| `/handoff:run` or `/handoff` | Command/Skill | User types it |
| `handoff-manager` | Agent | Claude delegates or user requests |
| `handoff-awareness` | Skill | Claude auto-applies during long sessions |
| SessionStart/End | Hooks | Automatic reminders (plugin only) |

## Continuity Levels

| Level | Feature | When |
| :---: | :--- | :--- |
| 1 | `/rewind` | Undo recent edits |
| 2 | `--continue` | Resume paused session |
| 3 | `/handoff:run` | Context full, switching tools, new machine |

## Requirements

**Required:**

- Claude Code 1.0.33+
- Git

**Optional:**

- `gh` - PR details with full bodies
- Linear MCP - Issue tracking
- `jq` - JSON parsing in hooks

## License

MIT
