# Claude Code Integration

Complete integration with Claude Code including slash commands, hooks, skills, and CLI wrapper.

## Quick Install

### 1. Install CLI (recommended)

```bash
# Add to PATH
cp cli/handoff /usr/local/bin/
chmod +x /usr/local/bin/handoff

# Or add alias to .zshrc/.bashrc
alias handoff='/path/to/handoff/cli/handoff'
```

### 2. Install Slash Commands

```bash
# Copy to global commands (available in all projects)
cp -r examples/claude-code/commands/* ~/.claude/commands/

# Or copy to project (available only in this project)
mkdir -p .claude/commands
cp -r examples/claude-code/commands/* .claude/commands/
```

### 3. Install Skills (optional)

```bash
# Copy to global skills
cp -r examples/claude-code/skills/* ~/.claude/skills/

# Or copy to project
mkdir -p .claude/skills
cp -r examples/claude-code/skills/* .claude/skills/
```

## Usage

### CLI Wrapper

```bash
# Start claude with handoff context
handoff

# Resume named session with handoff
handoff --resume my-feature

# Start with a prompt
handoff "continue the auth implementation"

# Initialize handoff in a project
handoff --init

# End session (archive + gather state)
handoff --end

# Quick status
handoff --status
```

### Slash Commands

Inside Claude Code:

```bash
/handoff start           # Gather context with parallel agents
/handoff end             # Archive and update handoff
/handoff status          # Quick status check

# Separate commands also available
/handoff-start           # Full start workflow
/handoff-end             # Full end workflow
```

### Skills

Skills are automatically invoked when relevant:

- "I'm starting a new session" → handoff-start skill
- "Let's wrap up" → handoff-end skill
- "What was I working on?" → reads handoff context

## File Structure

```
.claude/
├── commands/
│   ├── handoff.md           # Main /handoff command
│   ├── handoff-start.md     # /handoff-start
│   └── handoff-end.md       # /handoff-end
├── skills/
│   ├── handoff-start.md     # START workflow skill
│   └── handoff-end.md       # END workflow skill
└── hooks/
    └── (optional hooks)
```

## Parallel Agent Workflow

### START (4 agents)

| Agent | Model | Task |
|-------|-------|------|
| 1 | sonnet | Git state + full commit messages |
| 2 | sonnet | PRs with full bodies |
| 3 | sonnet | Issues with descriptions |
| 4 | opus | Context analysis + resume planning |

### END (5 agents)

| Agent | Model | Task |
|-------|-------|------|
| 1 | sonnet | Git state + PRs + archive |
| 2 | sonnet | Package versions |
| 3 | sonnet | Issue tracker sync |
| 4 | opus | Update HANDOFF.md |
| 5 | opus | Update CONTEXT.md |

## Hooks (Optional)

Add session start reminder:

```bash
# Copy hook
cp examples/claude-code/hooks/session-start.json ~/.claude/hooks/

# Or add to existing hooks config
```

The hook will remind you to run `/handoff start` at the beginning of each session.

## Configuration

### Environment Variables

```bash
export HANDOFF_DIR=".handoff"  # Default handoff directory
```

### Custom Directory

```bash
handoff --dir ~/notes/myproject
/handoff start ~/notes/myproject
```

## Model Selection

| Task Type | Model | Why |
|-----------|-------|-----|
| Git, gh, packages | sonnet | Fast data fetching |
| Issue queries | sonnet | Structured data |
| Analysis, writing | opus | Best reasoning |

## Integration with Claude Flags

The CLI wrapper works with all Claude Code flags:

```bash
# With model selection
handoff --model opus "complex refactoring task"

# With verbose output
handoff --verbose --resume my-feature

# With custom agents
handoff --agents '{"reviewer":{"description":"...", "prompt":"..."}}'
```
