#!/usr/bin/env bash
# terminal-stack installer — symlink every config layer into place. Idempotent:
# re-running is safe; an existing non-symlink target is backed up to <path>.bak.
#
# Usage:  ./install.sh [--dry-run] [--prune]
#   --dry-run   show what would change, change nothing
#   --prune     also remove our symlinks that now dangle (config deleted from the
#               repo) — makes the live setup a true mirror of the repo
#
# Reference: docs/install.md
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=false
PRUNE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --prune)   PRUNE=true ;;
    -h|--help)
      cat <<'USAGE'
terminal-stack installer — symlink every config layer into place (idempotent).

Usage:  ./install.sh [--dry-run] [--prune]
  --dry-run   show what would change, change nothing
  --prune     also remove our symlinks that now dangle (config deleted from the
              repo) — makes the live setup a true mirror of the repo

Update everything (pull + upgrade tools + prune):  make update
USAGE
      exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

note() { printf '  %s\n' "$*"; }
short() { printf '%s' "${1/#$HOME/\~}"; }   # ~-abbreviated path

link() { # link <src> <dest>
  local src="$1" dest="$2"
  [ -e "$src" ] || { note "skip (missing): ${src#"$REPO"/}"; return 0; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    note "ok: $(short "$dest")"; return 0
  fi
  if $DRY_RUN; then note "would link: $(short "$dest") → ${src#"$REPO"/}"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  # Back up a real file/dir that isn't already our symlink.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then mv "$dest" "$dest.bak"; note "backed up: $(short "$dest") → .bak"; fi
  ln -sfn "$src" "$dest"
  note "linked: $(short "$dest") → ${src#"$REPO"/}"
}

# Every fixed path the installer manages (single files + whole-dir links).
MANAGED=(
  "$CONFIG/ghostty/config"
  "$CONFIG/zellij"
  "$CONFIG/nvim"
  "$HOME/.zshrc"
  "$CONFIG/starship.toml"
  "$CONFIG/git/config"
  "$HOME/.claude/statusline.sh"
  "$HOME/.claude/settings.json"
  "$HOME/.local/bin/cc-worktree"
)

prune_one() { # remove $1 iff it's OUR symlink (into $REPO) whose target is gone
  local p="$1" tgt
  [ -L "$p" ] || return 0
  tgt=$(readlink "$p")
  case "$tgt" in "$REPO"/*) ;; *) return 0 ;; esac   # only links pointing into the repo
  [ -e "$p" ] && return 0                            # target still exists → keep
  if $DRY_RUN; then note "would prune: $(short "$p") (stale → ${tgt#"$REPO"/})"
  else rm "$p"; note "pruned: $(short "$p") (stale → ${tgt#"$REPO"/})"; fi
}

prune() {
  echo "• Prune (stale links → configs removed from the repo)"
  for p in "${MANAGED[@]}"; do prune_one "$p"; done
  # the per-file zsh + claude/rules role dirs are dynamic — sweep them for our dangling links
  [ -d "$CONFIG/zsh" ] && for p in "$CONFIG"/zsh/*; do [ -L "$p" ] && prune_one "$p"; done
  [ -d "$HOME/.claude/rules" ] && for p in "$HOME"/.claude/rules/*; do [ -L "$p" ] && prune_one "$p"; done
  return 0
}

# Fonts are COPIED (not symlinked) into the OS font dir — macOS Font Book and many
# tools don't follow symlinks, and a moved repo shouldn't break installed fonts.
# So --prune does not manage them. Skips a font already present (idempotent).
install_fonts() {
  echo "• Fonts (Dank Mono)"
  local dest; case "$(uname -s)" in
    Darwin) dest="$HOME/Library/Fonts" ;;
    *)      dest="${XDG_DATA_HOME:-$HOME/.local/share}/fonts" ;;
  esac
  local did=false
  for f in "$REPO"/fonts/*.otf "$REPO"/fonts/*.ttf; do
    [ -e "$f" ] || continue
    local base; base=$(basename "$f")
    if [ -e "$dest/$base" ]; then note "ok: $base already installed"; continue; fi
    if $DRY_RUN; then note "would install font: $base → $(short "$dest")/"; continue; fi
    mkdir -p "$dest"; cp "$f" "$dest/$base"; note "installed font: $base"; did=true
  done
  $did && command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$dest" >/dev/null 2>&1
  return 0
}

# Fetch the zellij-choose-tree plugin wasm (best-effort) — it backs Ctrl+o f
# (fuzzy-jump to any tab/pane). ~/.config/zellij is a symlink to the repo's
# zellij/, so this lands in zellij/plugins/ (git-ignored, like every plugin wasm).
# If it fails (offline), Ctrl+o f is a no-op until you re-run install; every other
# key is unaffected. Skipped on --dry-run.
install_zellij_plugins() {
  local dir="$CONFIG/zellij/plugins" f="$CONFIG/zellij/plugins/zellij-choose-tree.wasm"
  [ -f "$f" ] && { note "ok: zellij-choose-tree.wasm already present"; return 0; }
  if $DRY_RUN; then note "would fetch: zellij-choose-tree.wasm → ~/.config/zellij/plugins/"; return 0; fi
  mkdir -p "$dir"
  if command -v curl >/dev/null 2>&1 && curl -fsSL -o "$f" \
      https://github.com/laperlej/zellij-choose-tree/releases/latest/download/zellij-choose-tree.wasm; then
    note "fetched: zellij-choose-tree.wasm (Ctrl+o f enabled)"
  else
    note "skipped: zellij-choose-tree.wasm fetch failed (Ctrl+o f is a no-op until re-run; harmless)"
  fi
}

# Register the user-scope MCP servers (Notion, Context7) via claude/mcp-setup.sh.
# Best-effort: needs the claude CLI + network, so a missing CLI or an offline
# machine just skips — the install never fails on it. Skipped on --dry-run. The
# script is idempotent (a server already present is left as-is).
install_claude_mcp() {
  echo "• Claude Code — MCP servers"
  if $DRY_RUN; then note "would run: claude/mcp-setup.sh (register Notion + Context7, user scope)"; return 0; fi
  if ! command -v claude >/dev/null 2>&1; then note "skipped: claude CLI not found (run after 'brew bundle')"; return 0; fi
  "$REPO/claude/mcp-setup.sh" || note "skipped: mcp-setup.sh did not complete (harmless; re-run later)"
}

# Install the user-scope plugins (enabled in settings.json) via claude/plugins-setup.sh.
# Same best-effort contract as install_claude_mcp: needs the claude CLI, idempotent,
# skipped on --dry-run. enabledPlugins only *enables* — it does not fetch on a fresh machine.
install_claude_plugins() {
  echo "• Claude Code — plugins"
  if $DRY_RUN; then note "would run: claude/plugins-setup.sh (install 4 plugins, user scope)"; return 0; fi
  if ! command -v claude >/dev/null 2>&1; then note "skipped: claude CLI not found (run after 'brew bundle')"; return 0; fi
  "$REPO/claude/plugins-setup.sh" || note "skipped: plugins-setup.sh did not complete (harmless; re-run later)"
}

echo "terminal-stack → installing from $REPO"
$DRY_RUN && echo "(dry run — no changes)"

echo "• Ghostty";    link "$REPO/ghostty/config"     "$CONFIG/ghostty/config"
echo "• Zellij";     link "$REPO/zellij"             "$CONFIG/zellij"; install_zellij_plugins
echo "• Neovim";     link "$REPO/nvim"               "$CONFIG/nvim"
echo "• Shell";      link "$REPO/zsh/.zshrc"         "$HOME/.zshrc"
                     link "$REPO/zsh/starship.toml"  "$CONFIG/starship.toml"
                     for f in "$REPO"/zsh/*.zsh; do link "$f" "$CONFIG/zsh/$(basename "$f")"; done
echo "• Git";        link "$REPO/git/config"          "$CONFIG/git/config"
echo "• Claude Code"; link "$REPO/claude/statusline.sh" "$HOME/.claude/statusline.sh"
                      link "$REPO/claude/settings.json"  "$HOME/.claude/settings.json"
                      link "$REPO/claude/cc-worktree.sh" "$HOME/.local/bin/cc-worktree"
                      # each rule links on its own (like zsh/*.zsh) so machine-local rules can coexist
                      for f in "$REPO"/claude/rules/*.md; do link "$f" "$HOME/.claude/rules/$(basename "$f")"; done

install_fonts
install_claude_plugins
install_claude_mcp
$PRUNE && prune

cat <<'DONE'

Done. Next:
  • brew bundle                      # install the toolchain (if not yet)
  • sign in to Notion's MCP once:  open `claude`, then  /mcp → notion → Authenticate
  • open a new terminal, then:  zellij --layout dev
  • to update later:  make update    (pull + upgrade tools + prune)
DONE
