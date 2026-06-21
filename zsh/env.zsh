# Environment + core zsh options. Sourced first.

# ── XDG base directories — keep $HOME tidy ────────────────────────────
# Export the standard paths so every XDG-aware tool (nvim, atuin, bat, fd, gh,
# zoxide, …) stores under ~/.config · ~/.local/share · ~/.local/state · ~/.cache
# instead of dropping a dotfile in $HOME.
# Spec: https://specifications.freedesktop.org/basedir/latest/
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Put ~/.local/bin on PATH — install.sh links cc-worktree there. Guard against a
# duplicate entry when the shell re-sources this file.
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# ── Redirect tools that ignore XDG on their own ───────────────────────
# Each var is the tool's OWN documented override (verified upstream). These are
# history/cache files (regenerable), so pointing them at a fresh path is safe.
# The tools won't create the parent dir, so make the state dirs once.
# Tools that hold real state or SECRETS (docker, cargo/rustup, aws, gnupg) are
# deliberately NOT auto-redirected — see zsh/README.md for the opt-in vars.
mkdir -p "$XDG_CACHE_HOME" "$XDG_STATE_HOME/zsh" "$XDG_STATE_HOME/less" "$XDG_STATE_HOME/node" "$XDG_STATE_HOME/python"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"            # less      · was ~/.lesshst
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"  # node REPL · was ~/.node_repl_history
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"        # python≥3.13 REPL · ~/.python_history
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"                 # npm cache · was ~/.npm

# ── History — large, shared across panes, de-duped; under XDG_STATE_HOME ──
# A leading space hides a command. Move an existing ~/.zsh_history over once
# (preserves your history while clearing it out of $HOME).
HISTFILE="$XDG_STATE_HOME/zsh/history"
[ -f "$HOME/.zsh_history" ] && [ ! -f "$HISTFILE" ] && mv "$HOME/.zsh_history" "$HISTFILE"
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Navigation + completion (compdump → cache, not $HOME).
setopt AUTO_CD              # `foo/` ≡ `cd foo/`
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zcompdump"
