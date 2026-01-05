#!/bin/bash

# Handoff End Script
# Archives current handoff and gathers state for update
# Run this at the end of each session, then update HANDOFF.md

set -e

HANDOFF_DIR="${HANDOFF_DIR:-.handoff}"
SESSIONS_DIR="$HANDOFF_DIR/sessions"
TIMESTAMP=$(date +%Y-%m-%d-%H%M)

echo "=== Handoff End ==="
echo ""

# Create sessions directory if it doesn't exist
mkdir -p "$SESSIONS_DIR"

# Archive current handoff
if [ -f "$HANDOFF_DIR/HANDOFF.md" ]; then
    cp "$HANDOFF_DIR/HANDOFF.md" "$SESSIONS_DIR/$TIMESTAMP.md"
    echo "✓ Archived HANDOFF.md to sessions/$TIMESTAMP.md"
    echo ""
else
    echo "⚠ No HANDOFF.md to archive"
    echo ""
fi

# Git State
echo "## Current Git State"
echo ""
echo "Branch: $(git branch --show-current)"
echo "Status:"
git status --short
echo ""

echo "### Recent Commits (copy to HANDOFF.md)"
echo '```'
git log -10 --format='%h %s%n%b---'
echo '```'
echo ""

echo "### Files Changed"
echo '```'
git diff --stat HEAD~5 2>/dev/null || echo "Less than 5 commits"
echo '```'
echo ""

# GitHub PRs
if command -v gh &> /dev/null; then
    echo "## GitHub PRs (copy to HANDOFF.md)"
    echo ""

    echo "### Open PRs"
    gh pr list --state=open --json number,title,headRefName,url --jq '.[] | "| #\(.number) | \(.title) | \(.url) |"' 2>/dev/null || echo "None"
    echo ""

    echo "### Recent Merged PRs"
    gh pr list --state=merged --limit=5 --json number,title,mergedAt --jq '.[] | "| #\(.number) | \(.title) | \(.mergedAt | split("T")[0]) |"' 2>/dev/null || echo "None"
    echo ""
fi

# Package versions
echo "## Package Versions"
if [ -f "package.json" ]; then
    echo "### Node.js Dependencies"
    cat package.json | jq -r '.dependencies | to_entries | .[:10] | .[] | "| \(.key) | \(.value) |"' 2>/dev/null || echo "Could not read package.json"
fi

if [ -f "requirements.txt" ]; then
    echo "### Python Dependencies"
    head -10 requirements.txt
fi
echo ""

echo "=== Now Update HANDOFF.md ==="
echo ""
echo "Update $HANDOFF_DIR/HANDOFF.md with:"
echo "- Session timestamp: $TIMESTAMP"
echo "- Git state above"
echo "- What was DONE this session"
echo "- What FAILED (with details)"
echo "- DECISIONS made"
echo "- FILES touched"
echo "- RESUME point for next session"
