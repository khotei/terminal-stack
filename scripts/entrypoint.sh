#!/usr/bin/env bash
# Sandbox entrypoint: symlink whatever config layers the mounted repo (/work)
# actually contains into the container's ~/.config, then exec the command.
# Absent layers are skipped — the sandbox lands before the configs it tests and
# grows as features merge (F-META-001, AC-3).
set -euo pipefail

REPO="${REPO:-/work}"
CFG="$HOME/.config"
mkdir -p "$CFG"

link() { # link <src> <dest> — only if src exists
  [ -e "$1" ] || return 0
  mkdir -p "$(dirname "$2")"
  ln -sfn "$1" "$2"
  echo "linked: ${1#"$REPO"/} → ${2#"$HOME"/}"
}

# Ghostty: host-only GUI; link the config so `+show-config` could validate it,
# but the binary isn't in this image (documented).
link "$REPO/ghostty/config"     "$CFG/ghostty/config"
# Zellij / Neovim: link the directory only when it carries a real entry file.
[ -f "$REPO/zellij/config.kdl" ] && link "$REPO/zellij" "$CFG/zellij"
[ -f "$REPO/nvim/init.lua" ]     && link "$REPO/nvim"   "$CFG/nvim"
# Shell: repo .zshrc + Starship config + the role files (env/aliases/tools/prompt).
link "$REPO/zsh/.zshrc"         "$HOME/.zshrc"
link "$REPO/zsh/starship.toml"  "$CFG/starship.toml"
for _zf in "$REPO"/zsh/*.zsh; do [ -e "$_zf" ] && link "$_zf" "$CFG/zsh/$(basename "$_zf")"; done
# Git: additive ~/.config/git/config (delta pager + defaults; never touches identity).
link "$REPO/git/config"         "$CFG/git/config"

# Fallback .zshrc so the sandbox has a working prompt before the Shell feature
# lands: init Starship + zoxide if the repo didn't provide its own .zshrc.
if [ ! -e "$HOME/.zshrc" ]; then
  cat > "$HOME/.zshrc" <<'EOF'
# sandbox fallback — replaced once zsh/.zshrc ships (F-SHELL-*)
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
EOF
  echo "linked: (none) → .zshrc (sandbox fallback)"
fi

exec "$@"
