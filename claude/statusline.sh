#!/usr/bin/env bash
# Claude Code status line for terminal-stack — installs to ~/.claude/statusline.sh.
# Reads session JSON on stdin and prints one line: model · dir · git · context% ·
# cost · 5-hour usage-window headroom remaining.
# Schema: https://code.claude.com/docs/en/statusline
# Wire it up via ~/.claude/settings.json (see ./README.md).
set -euo pipefail

input=$(cat)

# Prefer jq; fall back to grep so the line still renders without jq installed.
if command -v jq >/dev/null 2>&1; then
  model=$(jq -r '.model.display_name // "?"' <<<"$input")
  dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
  ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
  cost=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
  rl5=$(jq -r 'if .rate_limits.five_hour.used_percentage != null then (100 - .rate_limits.five_hour.used_percentage | floor) else empty end' <<<"$input")
else
  model=$(grep -o '"display_name":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  dir=$(grep -o '"current_dir":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  ctx="" ; cost="" ; rl5=""
fi

dir=${dir:-$PWD}
dirname=$(basename "$dir")

# git branch (+ * when dirty), scoped to the session's directory.
branch=""
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null || true)
  [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ] && branch="${branch}*"
fi

# Accents from the terminal's 16 ANSI slots (no hardcoded palette) so the line
# tracks Ghostty's live theme, the same way the Starship prompt does.
b=$'\033[34m'; m=$'\033[35m'; p=$'\033[36m'; g=$'\033[32m'
dim=$'\033[2m'; r=$'\033[0m'; y=$'\033[33m'; rd=$'\033[31m'

# A dim middle-dot joins every segment so they breathe instead of blurring together.
sep=" ${dim}·${r} "

line="${p}${model}${r}${sep}${b}${dirname}${r}"
[ -n "$branch" ] && line="${line}${sep}${m}${branch}${r}"
[ -n "${ctx:-}" ] && line="${line}${sep}${g}🧠 ${ctx}%${r}"
[ -n "${cost:-}" ] && line="${line}${sep}${dim}💰 \$$(printf '%.2f' "$cost")${r}"

# 5-hour usage window — % of the plan's rate-limit budget still REMAINING (not
# used). Max/Pro only, and only after the session's first API response (else omitted).
if [ -n "${rl5:-}" ]; then
  if   [ "$rl5" -gt 40 ]; then c=$g; bat="🔋"
  elif [ "$rl5" -gt 15 ]; then c=$y; bat="🔋"
  else                         c=$rd; bat="🪫"
  fi
  line="${line}${sep}${bat} ${c}${rl5}%${r}"
fi

printf '%s' "$line"
