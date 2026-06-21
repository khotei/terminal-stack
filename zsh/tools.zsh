# Tool integrations. Each is guarded with `command -v` so a missing tool can
# never break the shell startup (graceful degradation, like the rest of the stack).

# zoxide — smarter cd (`z foo` jumps by frecency). Provides `z` and `zi`.
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# atuin — searchable, syncable shell history (rebinds Ctrl-R / Up).
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# fzf — fuzzy finder shell integration (Ctrl-T files, Ctrl-R history, Alt-C cd).
# `fzf --zsh` ships the bindings in fzf ≥ 0.48 (Homebrew is current).
if command -v fzf >/dev/null; then
  source <(fzf --zsh 2>/dev/null) 2>/dev/null
fi

# bat — syntax-highlighted pager. Used as the man pager only; we do NOT alias `cat`
# (that breaks `cat > file` and piping into programs that expect plain output).
if command -v bat >/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"   # colourful man pages via bat
  export MANROFFOPT="-c"
fi
