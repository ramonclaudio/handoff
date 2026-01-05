#!/bin/bash

# Handoff Start Script
# Gathers context for a new AI coding session
# Run this at the beginning of each session

set -e

HANDOFF_DIR="${HANDOFF_DIR:-.handoff}"

echo "=== Handoff Start ==="
echo ""

# Git State
echo "## Git State"
echo ""
echo "Branch: $(git branch --show-current)"
echo "Status:"
git status --short
echo ""

echo "### Recent Commits (with full messages)"
echo '```'
git log -10 --format='%h %s%n%b---'
echo '```'
echo ""

echo "### Files Changed Recently"
echo '```'
git diff --stat HEAD~5 2>/dev/null || echo "Less than 5 commits"
echo '```'
echo ""

echo "### Stashed Work"
STASH=$(git stash list)
if [ -z "$STASH" ]; then
    echo "None"
else
    echo "$STASH"
fi
echo ""

# GitHub PRs (if gh is installed)
if command -v gh &> /dev/null; then
    echo "## GitHub PRs"
    echo ""

    echo "### Open PRs"
    gh pr list --state=open --json number,title,headRefName --jq '.[] | "#\(.number) \(.title) (\(.headRefName))"' 2>/dev/null || echo "None"
    echo ""

    echo "### Recent Merged PRs"
    gh pr list --state=merged --limit=5 --json number,title,mergedAt --jq '.[] | "#\(.number) \(.title) (\(.mergedAt | split("T")[0]))"' 2>/dev/null || echo "None"
    echo ""
fi

# Context Files
echo "## Context Files"
echo ""

if [ -f "$HANDOFF_DIR/CONTEXT.md" ]; then
    echo "### CONTEXT.md"
    echo '```'
    cat "$HANDOFF_DIR/CONTEXT.md"
    echo '```'
    echo ""
else
    echo "No CONTEXT.md found at $HANDOFF_DIR/CONTEXT.md"
    echo ""
fi

if [ -f "$HANDOFF_DIR/HANDOFF.md" ]; then
    echo "### HANDOFF.md"
    echo '```'
    cat "$HANDOFF_DIR/HANDOFF.md"
    echo '```'
    echo ""
else
    echo "No HANDOFF.md found at $HANDOFF_DIR/HANDOFF.md"
    echo ""
fi

echo "=== Ready to Continue ==="
