#!/usr/bin/env bash
# scripts/doctor.sh — "is my terminal-stack setup healthy?"
# Checks three things on THIS machine: the tools are installed, the configs are
# symlinked into place, and the bundled assets (fonts) are present.
# It does NOT change anything — read-only. Run:  make doctor
#
# Legend:  ✓ good   ✗ a problem (with the fix)   ↷ optional / not installed
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
problems=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\033[2m — %s\033[0m\n' "$1" "$2"; problems=$((problems+1)); }
soft() { printf '  \033[33m↷\033[0m %s \033[2m(%s)\033[0m\n' "$1" "$2"; }
section() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# tool "<label>" <binary> <hint-if-missing> [soft]
tool() {
  if command -v "$2" >/dev/null 2>&1; then ok "$1 ($2)"
  elif [ "${4:-}" = soft ]; then soft "$1" "$2 not installed"
  else bad "$1" "$3"; fi
}
# link "<label>" <path>  — expect a symlink (what install.sh creates)
linkcheck() {
  if [ -L "$2" ]; then ok "$1 → $(readlink "$2" | sed "s#$PWD#.#")"
  elif [ -e "$2" ]; then soft "$1" "exists but isn't our symlink"
  else bad "$1" "missing — run ./install.sh"; fi
}

printf '\033[1mterminal-stack doctor\033[0m — checking %s\n' "$(uname -s) · $(pwd)"

section "Tools — core (brew bundle)"
tool "Zellij"   zellij   "brew bundle (or brew install zellij)"
tool "Neovim"   nvim     "brew bundle"
tool "zsh"      zsh      "ships with macOS"
tool "Starship" starship "brew bundle"
tool "git"      git      "xcode-select --install / brew bundle"

section "Tools — companions"
tool "zoxide" zoxide "brew bundle"
tool "atuin"  atuin  "brew bundle"
tool "fzf"    fzf    "brew bundle"
tool "fd"     fd     "brew bundle"
tool "ripgrep" rg    "brew bundle"
tool "lazygit" lazygit "brew bundle"
tool "yazi"   yazi   "brew bundle"
tool "jq"     jq     "brew bundle"
tool "eza"    eza    "brew bundle"
tool "bat"    bat    "brew bundle"
tool "delta"  delta  "brew bundle (git-delta)"

section "Tools — agent & terminal (casks)"
if command -v claude >/dev/null 2>&1; then ok "Claude Code (claude)"; else bad "Claude Code" "brew bundle (cask claude-code), then run claude to log in"; fi
if command -v ghostty >/dev/null 2>&1 || [ -d /Applications/Ghostty.app ]; then ok "Ghostty"; else soft "Ghostty" "host GUI app — brew bundle (cask), not needed in a sandbox"; fi

section "Tools — validators (optional)"
tool "stylua" stylua "brew bundle" soft
tool "shfmt"  shfmt  "brew bundle" soft

section "Config symlinks (install.sh)"
linkcheck "Ghostty config" "$CONFIG/ghostty/config"
linkcheck "Zellij"         "$CONFIG/zellij"
linkcheck "Neovim"         "$CONFIG/nvim"
linkcheck ".zshrc"         "$HOME/.zshrc"
linkcheck "zsh role files" "$CONFIG/zsh/env.zsh"
linkcheck "Starship"       "$CONFIG/starship.toml"
linkcheck "git config"     "$CONFIG/git/config"
linkcheck "Claude statusline" "$HOME/.claude/statusline.sh"
linkcheck "cc-worktree"    "$HOME/.local/bin/cc-worktree"

section "Bundled assets"
fontdir="$HOME/Library/Fonts"; [ "$(uname -s)" = Darwin ] || fontdir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
if [ -e "$fontdir/DankMono-Regular.otf" ]; then ok "Dank Mono font installed"; else soft "Dank Mono font" "run ./install.sh; or use JetBrainsMono Nerd Font"; fi
if [ -e "$CONFIG/zellij/plugins/zellij-choose-tree.wasm" ]; then ok "zellij-choose-tree plugin"; else soft "zellij-choose-tree plugin" "fetched by ./install.sh; Ctrl+o f is a no-op without it"; fi
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ok "~/.local/bin on \$PATH" ;;
  *) bad "PATH" "~/.local/bin not on \$PATH — cc-worktree won't be found; add it in zsh/env.zsh" ;;
esac

section "Verdict"
if [ "$problems" -eq 0 ]; then
  printf '\033[32m✓ Healthy.\033[0m Validate config contents with: make check\n'
else
  printf '\033[31m✗ %d problem(s) above.\033[0m Fix per the hints, then re-run: make doctor\n' "$problems"
fi
exit "$problems"
