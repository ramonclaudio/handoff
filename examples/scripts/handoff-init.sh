#!/bin/bash

# Handoff Init Script
# Initialize handoff for a new project
# Copies templates and creates directory structure

set -e

HANDOFF_DIR="${HANDOFF_DIR:-.handoff}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${TEMPLATES_DIR:-$SCRIPT_DIR/../../templates}"

echo "=== Handoff Init ==="
echo ""

# Create directories
mkdir -p "$HANDOFF_DIR/sessions"
echo "✓ Created $HANDOFF_DIR/"
echo "✓ Created $HANDOFF_DIR/sessions/"

# Copy templates if they exist
if [ -f "$TEMPLATES_DIR/CONTEXT.md" ]; then
    cp "$TEMPLATES_DIR/CONTEXT.md" "$HANDOFF_DIR/CONTEXT.md"
    echo "✓ Copied CONTEXT.md template"
else
    # Create minimal template
    cat > "$HANDOFF_DIR/CONTEXT.md" << 'EOF'
# Project Name

> One-line description

## Links

| Resource | URL |
|----------|-----|
| Repository | |
| Issues | |

## Stack

| Layer | Package | Version |
|-------|---------|---------|
| | | |

## Commands

```bash
# Development
npm run dev

# Build
npm run build

# Test
npm run test
```

## What Never Works

| Problem | Solution |
|---------|----------|
| | |

## Architecture Patterns

<!-- Add key patterns here -->
EOF
    echo "✓ Created minimal CONTEXT.md"
fi

if [ -f "$TEMPLATES_DIR/HANDOFF.md" ]; then
    cp "$TEMPLATES_DIR/HANDOFF.md" "$HANDOFF_DIR/HANDOFF.md"
    echo "✓ Copied HANDOFF.md template"
else
    # Create minimal template
    cat > "$HANDOFF_DIR/HANDOFF.md" << 'EOF'
# Handoff: Project Name

> Session: $(date +%Y-%m-%d)
> Task: Initial setup

## Status: IDLE

## Git State

- **Branch:** main
- **Status:** clean

## Done (This Session)

- [x] Initialized handoff

## Resume

**Next:** Fill in CONTEXT.md with project details
**Files to read:** (none yet)
EOF
    echo "✓ Created minimal HANDOFF.md"
fi

# Add to .gitignore if it exists
if [ -f ".gitignore" ]; then
    if ! grep -q "\.handoff/sessions/" .gitignore; then
        echo "" >> .gitignore
        echo "# Handoff session archives (optional - remove if you want to track)" >> .gitignore
        echo ".handoff/sessions/" >> .gitignore
        echo "✓ Added sessions/ to .gitignore"
    fi
fi

echo ""
echo "=== Handoff Initialized ==="
echo ""
echo "Next steps:"
echo "1. Edit $HANDOFF_DIR/CONTEXT.md with your project details"
echo "2. Run handoff-start.sh at the beginning of each AI session"
echo "3. Run handoff-end.sh at the end of each session"
