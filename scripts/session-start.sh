#!/bin/bash
# Handoff SessionStart hook
# Checks for handoff files and adds context to session
#
# Input (JSON via stdin):
#   session_id, transcript_path, permission_mode, hook_event_name, source
#
# Output:
#   Exit 0 with JSON for additionalContext
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

# Output context as plain text (simpler than JSON, per docs recommendation)
# "Plain text stdout (simpler): Any non-JSON text written to stdout is added as context"

if [ -n "$FOUND_HANDOFF" ]; then
    echo "📋 Handoff files detected at: $FOUND_HANDOFF"
    echo "Run /handoff start to gather session context with parallel agents."
else
    echo "💡 No handoff files found. Run /handoff init to set up session continuity."
fi

exit 0
