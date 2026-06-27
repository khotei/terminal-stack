#!/usr/bin/env bash
# cursor/install.sh — OPT-IN, link-by-demand. The main install.sh never runs
# this; you call it (or `make cursor`) only if you use Cursor (the VS Code fork)
# alongside the terminal stack.
#
# It symlinks three files (Cursor reads — and rewrites — settings.json /
# keybindings.json live, so a symlink keeps the repo in sync both ways, the
# normal VS Code dotfiles pattern):
#   settings.json     → <Cursor User dir>/settings.json
#   keybindings.json  → <Cursor User dir>/keybindings.json
#   init.lua          → ~/.config/cursor/init.lua   (the vscode-neovim config)
#
# init.lua does NOT auto-load: point the asvetliakov.vscode-neovim extension at
# it once (see the printed note + cursor/README.md). On macOS the Cursor User dir
# is ~/Library/Application Support/Cursor/User.
#
# Usage:  ./cursor/install.sh [--dry-run]      (or: make cursor)
#   --dry-run   show what would change, change nothing
# Reference: cursor/README.md
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

# Cursor's User config dir is OS-specific.
case "$(uname -s)" in
  Darwin) USER_DIR="$HOME/Library/Application Support/Cursor/User" ;;
  *)      USER_DIR="$CONFIG/Cursor/User" ;;   # Linux
esac

note() { printf '  %s\n' "$*"; }
short() { printf '%s' "${1/#$HOME/\~}"; }

link() { # link <src> <dest>
  local src="$1" dest="$2"
  [ -e "$src" ] || { note "skip (missing): ${src##*/}"; return 0; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    note "ok: $(short "$dest")"; return 0
  fi
  if $DRY_RUN; then note "would link: $(short "$dest") → ${src#"$DIR"/}"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then mv "$dest" "$dest.bak"; note "backed up: $(short "$dest") → .bak"; fi
  ln -sfn "$src" "$dest"
  note "linked: $(short "$dest") → ${src#"$DIR"/}"
}

echo "Cursor (opt-in) → linking from $DIR"
$DRY_RUN && echo "(dry run — no changes)"

echo "• User settings"; link "$DIR/settings.json"    "$USER_DIR/settings.json"
                        link "$DIR/keybindings.json" "$USER_DIR/keybindings.json"
echo "• IdeaVim-style Neovim config (vscode-neovim)"
                        link "$DIR/init.lua"          "$CONFIG/cursor/init.lua"

cat <<DONE

Done. Next (one-time, in Cursor):
  • Install the extension:  asvetliakov.vscode-neovim  (Cmd+Shift+X)
  • Point it at the init.lua — add to settings.json (the linked one):
      "vscode-neovim.neovimInitVimPaths": { "darwin": "$(short "$CONFIG/cursor/init.lua")" }
  • Reload the window (Cmd+Shift+P → Reload Window).
  • Other extensions the config expects: GitLens, Bookmarks, Catppuccin Icons,
    custom-ui-style — install from the marketplace as wanted.
DONE
