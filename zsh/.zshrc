#!/usr/bin/env zsh
# terminal-stack — zsh entrypoint. Installs to ~/.zshrc.
# Stays thin: sources role files from ~/.config/zsh in a deliberate order.
# Machine-local, secret, or per-host tweaks go in ~/.zshrc.local (git-ignored).
# Reference: zsh/README.md

ZSH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Order matters: env (exports, options) → vi-mode (rebinds keymaps, so it must
# precede anything that binds keys) → aliases → tools (fzf/atuin bind AFTER vi-mode
# so they survive) → prompt (starship, over a ready shell) → plugins (load LAST:
# zsh-syntax-highlighting must be the final thing sourced to wrap every other widget).
for _f in env vi-mode aliases tools prompt plugins; do
  [ -r "$ZSH_DIR/$_f.zsh" ] && source "$ZSH_DIR/$_f.zsh"
done
unset _f

[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
