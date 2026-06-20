# Aliases. Conservative — we do NOT shadow standard tools (grep/find) so scripts
# and muscle memory keep working; the modern CLIs get their own short names.

alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

# git shortcuts
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# stack tools (guarded — alias only if installed)
command -v lazygit >/dev/null && alias lg='lazygit'
command -v yazi    >/dev/null && alias y='yazi'
