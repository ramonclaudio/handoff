#!/usr/bin/env bash
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

# Check for handoff files in project root
HANDOFF_DIR="${HANDOFF_DIR:-.handoff}"

if [ -f "$HANDOFF_DIR/HANDOFF.md" ]; then
    FOUND_HANDOFF="$HANDOFF_DIR"
else
    FOUND_HANDOFF=""
fi

# Output context as plain text (simpler than JSON, per docs recommendation)
# "Plain text stdout (simpler): Any non-JSON text written to stdout is added as context"

if [ -n "$FOUND_HANDOFF" ]; then
    echo "📋 Handoff files detected at: $FOUND_HANDOFF"
    echo "Run /handoff:run start to gather session context with parallel agents."
else
    echo "💡 No handoff files found. Run /handoff:run init to set up session continuity."
fi

exit 0
