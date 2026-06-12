#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')

parts=""

[ -n "$model" ] && parts="$model"

if [ -n "$used" ]; then
  pct=$(printf "%.0f" "$used")
  filled=$(( pct / 10 ))
  empty=$(( 10 - filled ))
  bar=""
  i=0
  while [ $i -lt $filled ]; do bar="${bar}█"; i=$(( i + 1 )); done
  i=0
  while [ $i -lt $empty ];  do bar="${bar}░"; i=$(( i + 1 )); done
  ctx="[${bar}] ${pct}%"
  [ -n "$parts" ] && parts="$parts  $ctx" || parts="$ctx"
fi

if [ -n "$five_hour" ]; then
  five_pct=$(printf "%.0f" "$five_hour")
  five_seg="5h: ${five_pct}% used"
  [ -n "$parts" ] && parts="$parts  $five_seg" || parts="$five_seg"
fi

if [ -n "$effort" ]; then
  [ -n "$parts" ] && parts="$parts  effort:$effort" || parts="effort:$effort"
fi

printf "%s" "$parts"
