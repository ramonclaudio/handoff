#!/usr/bin/env bash
set -euo pipefail

FILE=$(jq -r '.tool_input.file_path // empty')

case "$FILE" in
  *HANDOFF.md) MAX=120 ;;
  *CONTEXT.md) MAX=150 ;;
  *) exit 0 ;;
esac

CONTENT=$(jq -r '.tool_input.content // .tool_input.new_string // empty')
[[ -z "$CONTENT" ]] && exit 0

LINES=$(wc -l <<< "$CONTENT" | tr -d ' ')
[[ $LINES -gt $MAX ]] && echo "⚠️ Exceeds ${MAX} lines (${LINES}). Trim."

FENCES=$(grep -c '```' <<< "$CONTENT" || true)
[[ $FENCES -gt 4 ]] && echo "⚠️ Too many code blocks. Reference files, don't embed."

if [[ "$FILE" == *HANDOFF.md ]] && grep -qiE '\*\*Next:\*\*.*continue' <<< "$CONTENT"; then
  grep -qE '\*\*Next:\*\*.*:[0-9]+' <<< "$CONTENT" || echo "⚠️ Vague resume. Include file:line."
fi
