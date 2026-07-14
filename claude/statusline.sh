#!/usr/bin/env bash
# Claude Code status line for terminal-stack — installs to ~/.claude/statusline.sh.
# Reads session JSON on stdin and prints one line: model · dir · git · context% · cost.
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
else
  model=$(grep -o '"display_name":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  dir=$(grep -o '"current_dir":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  ctx="" ; cost=""
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
dim=$'\033[2m'; r=$'\033[0m'

line="${p}${model}${r} ${b} ${dirname}${r}"
[ -n "$branch" ] && line="${line} ${m} ${branch}${r}"
[ -n "${ctx:-}" ] && line="${line} ${g}${ctx}% ctx${r}"
[ -n "${cost:-}" ] && line="${line} ${dim}\$$(printf '%.2f' "$cost")${r}"

printf '%s' "$line"
