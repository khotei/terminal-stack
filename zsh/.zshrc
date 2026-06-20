#!/usr/bin/env zsh
# terminal-stack — zsh entrypoint. Installs to ~/.zshrc.
# Stays thin: sources role files from ~/.config/zsh in a deliberate order.
# Machine-local, secret, or per-host tweaks go in ~/.zshrc.local (git-ignored).
# Reference: zsh/README.md

ZSH_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Order matters: env (exports, options) → aliases → tools (integrations that may
# read $EDITOR etc.) → prompt (starship, last so it wraps a ready shell).
for _f in env aliases tools prompt; do
  [ -r "$ZSH_DIR/$_f.zsh" ] && source "$ZSH_DIR/$_f.zsh"
done
unset _f

[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
