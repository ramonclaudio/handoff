#!/bin/bash

# Hook script to remind about handoff at session start
# Add to your hooks configuration

HANDOFF_DIR="${HANDOFF_DIR:-.handoff}"

if [ -f "$HANDOFF_DIR/HANDOFF.md" ]; then
    echo "📋 Handoff available at $HANDOFF_DIR/HANDOFF.md"
    echo "   Run: /handoff start"
    echo ""

    # Show quick resume point if available
    if grep -q "## Resume" "$HANDOFF_DIR/HANDOFF.md"; then
        echo "📌 Quick resume:"
        sed -n '/## Resume/,/^##/p' "$HANDOFF_DIR/HANDOFF.md" | head -6
    fi
fi
