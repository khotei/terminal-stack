#!/usr/bin/env bash
# Claude Code status line for terminal-stack — installs to ~/.claude/statusline.sh.
# Reads session JSON on stdin and prints one line: vim mode · git · worktree ·
# reasoning effort · model · context% · 5-hour usage-window headroom · WakaTime today.
# Schema: https://code.claude.com/docs/en/statusline
# Wire it up via ~/.claude/settings.json (see ./README.md).
set -euo pipefail

input=$(cat)

# Prefer jq; fall back to grep so the line still renders without jq installed.
if command -v jq >/dev/null 2>&1; then
  model=$(jq -r '.model.display_name // "?"' <<<"$input")
  dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
  wt=$(jq -r '.workspace.git_worktree // empty' <<<"$input")
  ctx=$(jq -r '.context_window.used_percentage // empty | floor' <<<"$input")
  eff=$(jq -r '.effort.level // empty' <<<"$input")
  rl5=$(jq -r 'if .rate_limits.five_hour.used_percentage != null then (100 - .rate_limits.five_hour.used_percentage | floor) else empty end' <<<"$input")
  rl5_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty | floor' <<<"$input")
  cold=$(jq -r 'if .prompt_cache.caching_observed == true and .prompt_cache.warm == false then "1" else empty end' <<<"$input")
  vim_mode=$(jq -r '.vim.mode // empty' <<<"$input")
else
  model=$(grep -o '"display_name":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  dir=$(grep -o '"current_dir":"[^"]*"' <<<"$input" | head -1 | cut -d'"' -f4)
  wt="" ; ctx="" ; eff="" ; rl5="" ; rl5_reset="" ; cold="" ; vim_mode=""
fi

dir=${dir:-$PWD}

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

# Segments in display order: a key, the text without colour (to measure the width), the
# text as shown, and the extra cells its emoji take (one char, two cells wide).
keys=() ; plain=() ; shown=() ; extra=()
add() { keys+=("$1"); plain+=("$2"); shown+=("$3"); extra+=("$4"); }

# Vim mode as one letter, like the nvim statusline; settings.json hides the built-in
# `-- INSERT --` so the mode isn't shown twice.
case "${vim_mode:-}" in
  NORMAL) add mode N "${b}N${r}" 0 ;;
  INSERT) add mode I "${g}I${r}" 0 ;;
  VISUAL) add mode V "${m}V${r}" 0 ;;
  "VISUAL LINE") add mode VL "${m}VL${r}" 0 ;;
esac

[ -n "$branch" ] && add git "$branch" "${m}${branch}${r}" 0
[ -n "${wt:-}" ] && add wt "🌳 ${wt}" "${y}🌳 ${wt}${r}" 1

[ -n "${eff:-}" ] && add eff "⚡ ${eff}" "${p}⚡ ${eff}${r}" 1

# Model dimmed — least load-bearing, so it doesn't lead the eye.
add model "$model" "${dim}${model}${r}" 0

# Context used: yellow from half full, red near the auto-compact. ❄ once the prompt cache
# has gone cold — the next message re-reads the whole context into the cache, which
# costs usage-window budget.
if [ -n "${ctx:-}" ]; then
  if   [ "$ctx" -lt 50 ]; then c=$g
  elif [ "$ctx" -lt 80 ]; then c=$y
  else                         c=$rd
  fi
  t="🧠 ${ctx}%" ; s="${c}${t}${r}"
  [ -n "${cold:-}" ] && { t="${t} ❄"; s="${s} ${p}❄${r}"; }
  add ctx "$t" "$s" 1
fi

# 5-hour usage window — % of the plan's rate-limit budget still REMAINING (not
# used), then the time it refills. Max/Pro only, and only after the session's first
# API response (else omitted). A clock time, not a countdown: the line re-renders on
# events only, so a countdown would go stale between messages.
if [ -n "${rl5:-}" ]; then
  if   [ "$rl5" -gt 40 ]; then c=$g; bat="🔋"
  elif [ "$rl5" -gt 15 ]; then c=$y; bat="🔋"
  else                         c=$rd; bat="🪫"
  fi
  t="${bat} ${rl5}%" ; s="${bat} ${c}${rl5}%${r}"
  reset=""
  if [ -n "${rl5_reset:-}" ]; then
    reset=$(date -r "$rl5_reset" +%H:%M 2>/dev/null || date -d "@$rl5_reset" +%H:%M 2>/dev/null || true)
  fi
  add usage "$t" "$s" 1
  # nf-md-update, a clock in a circular arrow. Two spaces: Ghostty draws a Nerd Font icon
  # followed by a space over two cells, so one space would leave it touching the time.
  [ -n "$reset" ] && add reset "󰚰  ${reset}" "${p}󰚰${r}  ${dim}${reset}${r}" 0
fi

# WakaTime's coding time today, all editors and Claude Code together. wakatime-cli asks the
# server (~1 s), longer than an update may wait, so the line shows the cached answer and
# refreshes it in the background at most once a minute.
waka_cli="$HOME/.wakatime/wakatime-cli"
waka_cache="${TMPDIR:-/tmp}/claude-statusline-wakatime"
if [ -x "$waka_cli" ]; then
  waka=$(cat "$waka_cache" 2>/dev/null || true)
  if [ -z "$(find "$waka_cache" -mmin -1 2>/dev/null)" ]; then
    touch "$waka_cache" # claims the refresh, so the next update doesn't start a second one
    (
      out=$("$waka_cli" --today --today-hide-categories true 2>/dev/null) &&
        printf '%s' "$out" >"$waka_cache"
    ) </dev/null >/dev/null 2>&1 &
  fi
  [ -n "$waka" ] && add waka "⏳ ${waka}" "⏳ ${waka}" 1
fi

# The refill time and WakaTime sit flush right; the rest reads from the left. A narrow
# pane first drops the least needed segments, instead of letting Claude Code cut the line
# off. The width comes in COLUMNS: tput can't read it from inside the script. Four cells
# stay free for Claude Code's own margin.
is_right() { case "$1" in reset | waka) return 0 ;; *) return 1 ;; esac; }
width() { # $1: left or right
  local w=0 n=0 i
  for i in "${!keys[@]}"; do
    [ -n "${keys[$i]}" ] || continue
    if is_right "${keys[$i]}"; then [ "$1" = right ] || continue; else [ "$1" = left ] || continue; fi
    w=$((w + ${#plain[$i]} + ${extra[$i]}))
    n=$((n + 1))
  done
  [ "$n" -gt 1 ] && w=$((w + 3 * (n - 1)))
  echo "$w"
}
join() { # $1: left or right
  local out="" i
  for i in "${!keys[@]}"; do
    [ -n "${keys[$i]}" ] || continue
    if is_right "${keys[$i]}"; then [ "$1" = right ] || continue; else [ "$1" = left ] || continue; fi
    out="${out:+${out}${sep}}${shown[$i]}"
  done
  printf '%s' "$out"
}
cols=${COLUMNS:-0}
max=$((cols - 4))
fits() { [ $(($(width left) + 3 + $(width right))) -le "$max" ]; }
if [ "$cols" -gt 4 ]; then
  for k in model eff; do
    fits && break
    for i in "${!keys[@]}"; do
      [ "${keys[$i]}" = "$k" ] && keys[$i]=""
    done
  done
fi

left=$(join left)
right=$(join right)
if [ "$cols" -gt 4 ] && [ -n "$right" ] && fits; then
  printf '%s%*s%s' "$left" $((max - $(width left) - $(width right))) "" "$right"
else
  printf '%s' "${left}${right:+${left:+${sep}}${right}}"
fi
