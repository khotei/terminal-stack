#!/usr/bin/env bash
# Claude Code status line for terminal-stack — installs to ~/.claude/statusline.sh.
# Reads session JSON on stdin and prints one line: dir · git · worktree · context% ·
# reasoning effort · 5-hour usage-window headroom · model (trailing, de-emphasized).
# Schema: https://code.claude.com/docs/en/statusline
# Wire it up via ~/.claude/settings.json (see ./README.md).
set -euo pipefail

input=$(cat)

# Prefer jq; fall back to grep so the line still renders without jq installed.
if command -v jq >/dev/null 2>&1; then
  model=$(jq -r '.model.display_name // "?"' <<<"$input")
  dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
  wt=$(jq -r '.workspace.git_worktree // empty' <<<"$input")
  ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
  eff=$(jq -r '.effort.level // empty' <<<"$input")
  rl5=$(jq -r 'if .rate_limits.five_hour.used_percentage != null then (100 - .rate_limits.five_hour.used_percentage | floor) else empty end' <<<"$input")
else
  model=$(grep -o '"display_name":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  dir=$(grep -o '"current_dir":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  wt="" ; ctx="" ; eff="" ; rl5=""
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

line="${b}${dirname}${r}"
[ -n "$branch" ] && line="${line}${sep}${m}${branch}${r}"
[ -n "${wt:-}" ] && line="${line}${sep}${y}🌳 ${wt}${r}"
[ -n "${ctx:-}" ] && line="${line}${sep}${g}🧠 ${ctx}%${r}"
[ -n "${eff:-}" ] && line="${line}${sep}${p}⚡ ${eff}${r}"

# 5-hour usage window — % of the plan's rate-limit budget still REMAINING (not
# used). Max/Pro only, and only after the session's first API response (else omitted).
if [ -n "${rl5:-}" ]; then
  if   [ "$rl5" -gt 40 ]; then c=$g; bat="🔋"
  elif [ "$rl5" -gt 15 ]; then c=$y; bat="🔋"
  else                         c=$rd; bat="🪫"
  fi
  line="${line}${sep}${bat} ${c}${rl5}%${r}"
fi

# Model trails, dimmed — least load-bearing, so it doesn't lead the eye.
line="${line}${sep}${dim}${model}${r}"

printf '%s' "$line"
