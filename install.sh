#!/usr/bin/env bash
# terminal-stack installer — symlink every config layer into place. Idempotent:
# re-running is safe; an existing non-symlink target is backed up to <path>.bak.
# Usage:  ./install.sh [--dry-run]
# Reference: docs/install.md
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

note() { printf '  %s\n' "$*"; }

link() { # link <src> <dest>
  local src="$1" dest="$2"
  [ -e "$src" ] || { note "skip (missing): ${src#"$REPO"/}"; return 0; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    note "ok: ${dest/#$HOME/\~}"; return 0
  fi
  if $DRY_RUN; then note "would link: ${dest/#$HOME/\~} → ${src#"$REPO"/}"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  # Back up a real file/dir that isn't already our symlink.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then mv "$dest" "$dest.bak"; note "backed up: ${dest/#$HOME/\~} → .bak"; fi
  ln -sfn "$src" "$dest"
  note "linked: ${dest/#$HOME/\~} → ${src#"$REPO"/}"
}

echo "terminal-stack → installing from $REPO"
$DRY_RUN && echo "(dry run — no changes)"

echo "• Ghostty";    link "$REPO/ghostty/config"     "$CONFIG/ghostty/config"
echo "• Zellij";     link "$REPO/zellij"             "$CONFIG/zellij"
echo "• Neovim";     link "$REPO/nvim"               "$CONFIG/nvim"
echo "• Shell";      link "$REPO/zsh/.zshrc"         "$HOME/.zshrc"
                     link "$REPO/zsh/starship.toml"  "$CONFIG/starship.toml"
                     for f in "$REPO"/zsh/*.zsh; do link "$f" "$CONFIG/zsh/$(basename "$f")"; done
echo "• Claude Code"; link "$REPO/claude/statusline.sh" "$HOME/.claude/statusline.sh"
                      link "$REPO/claude/cc-worktree.sh" "$HOME/.local/bin/cc-worktree"

cat <<'DONE'

Done. Next:
  • brew bundle                      # install the toolchain (if not yet)
  • add the statusLine block to ~/.claude/settings.json   (see claude/README.md)
  • open a new terminal, then:  zellij --layout dev
DONE
