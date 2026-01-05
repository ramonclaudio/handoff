#!/bin/bash
# Handoff SessionEnd hook
# Reminds user to save session state before ending
#
# Input (JSON via stdin):
#   session_id, transcript_path, hook_event_name, source
#
# Output:
#   stdout is added as context to the conversation

set -e

# Read JSON input from stdin (consume it even if we don't use it)
cat > /dev/null

# Check common handoff locations
HANDOFF_DIR="${HANDOFF_DIR:-.handoff}"
OBSIDIAN_PROJECT=""

# Try to get project name from git
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
    PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    OBSIDIAN_PROJECT="$HOME/obsidian/projects/$PROJECT_NAME"
fi

# Check for handoff files
FOUND_HANDOFF=""

if [ -f "$HANDOFF_DIR/HANDOFF.md" ]; then
    FOUND_HANDOFF="$HANDOFF_DIR"
elif [ -n "$OBSIDIAN_PROJECT" ] && [ -f "$OBSIDIAN_PROJECT/HANDOFF.md" ]; then
    FOUND_HANDOFF="$OBSIDIAN_PROJECT"
fi

# Output reminder as plain text
if [ -n "$FOUND_HANDOFF" ]; then
    echo "💾 Session ending. Consider running /handoff end to save your progress."
fi

exit 0
