#!/usr/bin/env bash
# Claude Code status line script
# Shows: model | context remaining % | tokens used/available | effort level

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown model"')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
effort=$(echo "$input" | jq -r '.effort.level // empty')

# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Format context section
ctx_section=""
if [ -n "$remaining_pct" ]; then
  remaining_fmt=$(printf "%.0f" "$remaining_pct")
  tokens_k=$(awk "BEGIN { printf \"%.0f\", $total_input / 1000 }")
  size_k=$(awk "BEGIN { printf \"%.0f\", $ctx_size / 1000 }")

  # Color code based on remaining percentage
  if [ "$remaining_fmt" -le 40 ]; then
    color="$RED"
  elif [ "$remaining_fmt" -le 65 ]; then
    color="$YELLOW"
  else
    color="$GREEN"
  fi

  ctx_section="${color}${remaining_fmt}% remaining${RESET} | ${tokens_k}k/${size_k}k tokens"
fi

# Format effort section
effort_section=""
if [ -n "$effort" ]; then
  effort_section="effort:${effort}"
fi

# Build output
parts=()
parts+=("$model")
[ -n "$ctx_section" ] && parts+=("$ctx_section")
[ -n "$effort_section" ] && parts+=("$effort_section")

printf '%b' "$(IFS=' | '; echo "${parts[*]}")"
