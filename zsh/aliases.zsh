# Aliases. Conservative — we do NOT shadow standard tools (grep/find) so scripts
# and muscle memory keep working; the modern CLIs get their own short names.

# ls — eza when installed (icons, git status, tree); plain ls otherwise.
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first --git'
  alias la='eza -a --group-directories-first'
  alias lt='eza --tree --level=2'
else
  alias ll='ls -lah'
  alias la='ls -A'
fi

alias ..='cd ..'
alias ...='cd ../..'

# git shortcuts
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# stack tools (guarded — alias only if installed)
command -v lazygit >/dev/null && alias lg='lazygit'
command -v yazi    >/dev/null && alias y='yazi'

# Claude Code with all permission checks off — a named, opt-in alias, NOT a shadow
# of bare `claude`: `--dangerously-skip-permissions` runs with zero guardrails, so
# it must never be the silent default. `yolo` for a trusted session; `claude` prompts.
command -v claude >/dev/null && alias yolo='claude --dangerously-skip-permissions'
