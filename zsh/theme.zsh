# Appearance switch for the tools that cannot follow the terminal themselves.
#
# Ghostty flips its palette with the macOS appearance and reports the change over
# CSI 2031; Zellij and Neovim listen and repaint. bat, delta, fzf, lazygit and Claude
# Code do not — each reads its colours once at process start. So the appearance is
# resolved here, once per prompt, and handed to them through the environment.
# Every palette below is GitHub High Contrast, the same Primer tokens the editor and
# the multiplexer use (nvim/lua/plugins/colorscheme.lua · zellij/themes/).
# macOS-only signal (`defaults read -g AppleInterfaceStyle`); elsewhere the dark
# variant stands, which is what an unconfigured terminal almost always is.

typeset -g _TS_APPEARANCE='' _TS_APPEARANCE_AT=0

_ts_theme_apply() {
  local mode=$1 cfg="${XDG_CONFIG_HOME:-$HOME/.config}"

  # delta: GitHub's own diff colours, defined as features in git/config.
  export DELTA_FEATURES="+github-$mode"

  # lazygit: a comma-separated list is merged left-to-right — its only light/dark hook.
  export LG_CONFIG_FILE="$cfg/lazygit/config.yml,$cfg/lazygit/theme-$mode.yml"

  # Claude Code: read by the claude() wrapper below (its settings hold one theme, and
  # `auto` only picks between the built-in presets — not a custom pair).
  export CLAUDE_THEME="custom:github-$mode-high-contrast"

  # fzf: projekt0n's official GitHub theme (github-theme-contrib/themes/fzf), with two
  # fixes — upstream sets `hl` to the *background* colour, which makes matched
  # characters invisible, and `header` to a near-background grey. gutter:-1 keeps the
  # left rail from painting a block of colour.
  if [[ $mode == light ]]; then
    export FZF_DEFAULT_OPTS='--color=fg:#0e1116,bg:#ffffff,hl:#0349b4,fg+:#0e1116,bg+:#dbe8fb,hl+:#0349b4,info:#744500,prompt:#0349b4,pointer:#622cbc,marker:#055d20,spinner:#744500,header:#66707b,border:#88929d,gutter:-1'
  else
    export FZF_DEFAULT_OPTS='--color=fg:#f0f3f6,bg:#0a0c10,hl:#71b7ff,fg+:#f0f3f6,bg+:#0f1b28,hl+:#71b7ff,info:#f0b72f,prompt:#71b7ff,pointer:#b780ff,marker:#26cd4d,spinner:#f0b72f,header:#9ea7b3,border:#7a828e,gutter:-1'
  fi
}

# Throttled to one `defaults read` (~8ms) every 5s, so a per-prompt hook stays free.
_ts_theme_sync() {
  [[ -n $_TS_APPEARANCE ]] && (( SECONDS - _TS_APPEARANCE_AT < 5 )) && return
  _TS_APPEARANCE_AT=$SECONDS
  local mode=dark
  if command -v defaults >/dev/null 2>&1; then
    [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]] || mode=light
  fi
  [[ $mode == $_TS_APPEARANCE ]] && return
  _TS_APPEARANCE=$mode
  _ts_theme_apply $mode
}

# `--settings` is an additive layer, so this overrides only the theme; everything else
# still comes from ~/.claude/settings.json.
if command -v claude >/dev/null 2>&1; then
  claude() { command claude --settings "{\"theme\":\"${CLAUDE_THEME:-auto}\"}" "$@" }
fi

autoload -Uz add-zsh-hook
add-zsh-hook precmd _ts_theme_sync
_ts_theme_sync
