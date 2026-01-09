#!/usr/bin/env bash
cat > /dev/null

DIR="${HANDOFF_DIR:-.handoff}"
[[ -f "$DIR/HANDOFF.md" ]] && echo "💾 Session ending. Run /handoff:run end to save progress."
