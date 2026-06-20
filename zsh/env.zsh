# Environment + core zsh options. Sourced first.

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# History — large, shared across panes, de-duped. A leading space hides a command.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Navigation + completion.
setopt AUTO_CD              # `foo/` ≡ `cd foo/`
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
