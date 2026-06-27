#!/usr/bin/env bash
# jetbrains/install.sh — OPT-IN, link-by-demand. The main install.sh never runs
# this; you call it (or `make jetbrains`) only if you still use a JetBrains IDE
# (IntelliJ / WebStorm / PyCharm / …) alongside the terminal stack.
#
# It does two things:
#   1. symlinks .ideavimrc → ~/.ideavimrc   (live: IdeaVim re-reads it; <leader>Ss re-sources)
#   2. points you at settings.zip to IMPORT through the IDE (see why below)
#
# Why import the settings, not symlink them: a JetBrains IDE REWRITES its config
# files on exit, and the config dir is versioned+product-specific
# (~/Library/Application Support/JetBrains/<Product><ver>/). Symlinking it would
# write machine state — and the private project paths in trusted-paths.xml — back
# through the link into this PUBLIC repo. Import is one-way and version-agnostic.
#
# Usage:  ./jetbrains/install.sh [--dry-run]      (or: make jetbrains)
#   --dry-run   show what would change, change nothing
# Reference: jetbrains/README.md
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

note() { printf '  %s\n' "$*"; }
short() { printf '%s' "${1/#$HOME/\~}"; }

# Same link semantics as the top-level install.sh: idempotent, backs up a real
# file to <path>.bak, leaves our own symlink untouched.
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

echo "JetBrains (opt-in) → linking from $DIR"
$DRY_RUN && echo "(dry run — no changes)"

echo "• IdeaVim";  link "$DIR/.ideavimrc" "$HOME/.ideavimrc"

echo "• IDE settings (import — not symlinked, see header)"
note "import once via the IDE:  Settings → Manage IDE Settings → Import Settings…"
note "then pick:  $(short "$DIR/settings.zip")"

cat <<DONE

Done. Next:
  • IdeaVim: open any project — ~/.ideavimrc is live (reload with  :source ~/.ideavimrc).
  • Settings: import settings.zip (path above); restart the IDE to apply.
  • Plugins ~/.ideavimrc expects: IdeaVim, AceJump/EasyMotion, IdeaVim-EasyMotion,
    which-key, IdeaVim-Sneak, NERDTree — install from Settings → Plugins.
DONE
