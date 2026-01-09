#!/usr/bin/env bash
set -euo pipefail

TRANSCRIPT=$(jq -r '.transcript_path // empty')
[[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]] && exit 0

PATTERN='rate.?limit|too.?many.?requests|quota.?exceeded|usage.?limit'
MATCH=$(tail -50 "$TRANSCRIPT" 2>/dev/null | grep -Eio "$PATTERN" | head -1) || true
[[ -z "$MATCH" ]] && exit 0

H=$((10#$(date +%H) % 5))
M=$((10#$(date +%M)))
WAIT_H=$((5 - H - (M > 0 ? 1 : 0)))
WAIT_M=$(((60 - M) % 60))

cat <<EOF
⏳ Rate limit detected: $MATCH
⏰ Wait: ${WAIT_H}h ${WAIT_M}m
💡 Run /handoff end to save progress
EOF
