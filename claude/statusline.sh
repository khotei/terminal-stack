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
# text as shown, and the extra cells an emoji takes (one char, two cells wide). Icons are
# one-colour Nerd Font glyphs, so they take the theme's colours like the text. Two spaces
# follow each: Ghostty draws a glyph followed by a space over two cells, so one space would
# leave it touching the text.
keys=() ; plain=() ; shown=() ; extra=()
add() { keys+=("$1"); plain+=("$2"); shown+=("$3"); extra+=("${4:-0}"); }

# Vim mode as one letter, like the nvim statusline; settings.json hides the built-in
# `-- INSERT --` so the mode isn't shown twice.
case "${vim_mode:-}" in
  NORMAL) add mode N "${b}N${r}" ;;
  INSERT) add mode I "${g}I${r}" ;;
  VISUAL) add mode V "${m}V${r}" ;;
  "VISUAL LINE") add mode VL "${m}VL${r}" ;;
esac

[ -n "$branch" ] && add git "$branch" "${m}${branch}${r}"
[ -n "${wt:-}" ] && add wt "󰘬  ${wt}" "${y}󰘬  ${wt}${r}"

# Model dimmed — least load-bearing, so it doesn't lead the eye.
add model "$model" "${dim}${model}${r}"

[ -n "${eff:-}" ] && add eff "⚡ ${eff}" "${p}⚡ ${eff}${r}" 1

# Context used: a gauge whose needle rises with the fill, yellow from half full, red near
# the auto-compact. A snowflake once the prompt cache has gone cold — the next message
# re-reads the whole context into the cache, which costs usage-window budget.
if [ -n "${ctx:-}" ]; then
  if   [ "$ctx" -lt 50 ]; then c=$g;  gauge="󰡵"
  elif [ "$ctx" -lt 80 ]; then c=$y;  gauge="󰊚"
  else                         c=$rd; gauge="󰡴"
  fi
  t="${gauge}  ${ctx}%" ; s="${c}${t}${r}"
  [ -n "${cold:-}" ] && { t="${t} 󰜗 "; s="${s} ${p}󰜗${r} "; }
  add ctx "$t" "$s"
fi

# 5-hour usage window — % of the plan's rate-limit budget still REMAINING (not
# used), then the time it refills. Max/Pro only, and only after the session's first
# API response (else omitted). A clock time, not a countdown: the line re-renders on
# events only, so a countdown would go stale between messages.
if [ -n "${rl5:-}" ]; then
  if   [ "$rl5" -gt 40 ]; then c=$g
  elif [ "$rl5" -gt 15 ]; then c=$y
  else                         c=$rd
  fi
  t="󰊘  ${rl5}%" ; s="${c}${t}${r}"
  reset=""
  if [ -n "${rl5_reset:-}" ]; then
    reset=$(date -r "$rl5_reset" +%H:%M 2>/dev/null || date -d "@$rl5_reset" +%H:%M 2>/dev/null || true)
  fi
  add usage "$t" "$s"
  [ -n "$reset" ] && add reset "󰚰  ${reset}" "${p}󰚰${r}  ${dim}${reset}${r}"
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
  [ -n "$waka" ] && add waka "󰔛  ${waka}" "${p}󰔛${r}  ${waka}"
fi

# Model and effort, then the refill time and WakaTime, sit flush right, the two groups held
# apart by a wider gap; the rest reads from the left. A narrow pane first drops the least
# needed segments, instead of letting Claude Code cut the line off. The width comes in
# COLUMNS: tput can't read it from inside the script. Four cells stay free for Claude
# Code's own margin.
gap="    "
in_group() { # $1: segment key, $2: left, mid or end
  local g=left
  case "$1" in eff | model) g=mid ;; reset | waka) g=end ;; esac
  [ "$g" = "$2" ]
}
width() { # $1: left, mid or end
  local w=0 n=0 i
  for i in "${!keys[@]}"; do
    [ -n "${keys[$i]}" ] && in_group "${keys[$i]}" "$1" || continue
    w=$((w + ${#plain[$i]} + ${extra[$i]}))
    n=$((n + 1))
  done
  [ "$n" -gt 1 ] && w=$((w + 3 * (n - 1)))
  echo "$w"
}
join() { # $1: left, mid or end
  local out="" i
  for i in "${!keys[@]}"; do
    [ -n "${keys[$i]}" ] && in_group "${keys[$i]}" "$1" || continue
    out="${out:+${out}${sep}}${shown[$i]}"
  done
  printf '%s' "$out"
}
right_width() {
  local m e
  m=$(width mid) ; e=$(width end)
  if [ "$m" -gt 0 ] && [ "$e" -gt 0 ]; then echo $((m + ${#gap} + e)); else echo $((m + e)); fi
}
cols=${COLUMNS:-0}
max=$((cols - 4))
fits() { [ $(($(width left) + 3 + $(right_width))) -le "$max" ]; }
if [ "$cols" -gt 4 ]; then
  for k in model eff; do
    fits && break
    for i in "${!keys[@]}"; do
      [ "${keys[$i]}" = "$k" ] && keys[$i]=""
    done
  done
fi

left=$(join left)
mid=$(join mid)
end=$(join end)
if [ "$cols" -gt 4 ] && [ -n "${mid}${end}" ] && fits; then
  right="${mid}${mid:+${end:+${gap}}}${end}"
  printf '%s%*s%s' "$left" $((max - $(width left) - $(right_width))) "" "$right"
else
  out="$left"
  for part in "$mid" "$end"; do
    [ -n "$part" ] && out="${out:+${out}${sep}}${part}"
  done
  printf '%s' "$out"
fi
