# Tool integrations. Each is guarded with `command -v` so a missing tool can
# never break the shell startup (graceful degradation, like the rest of the stack).

# zoxide — smarter cd (`z foo` jumps by frecency). Provides `z` and `zi`.
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# atuin — searchable, syncable shell history (rebinds Ctrl-R / Up).
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# fnm — fast Node version manager. `--use-on-cd` auto-switches per .node-version/.nvmrc.
# Puts the active Node on PATH so editor tooling launched from this shell (Neovim's
# mason → vtsls) finds a runtime; without it the TypeScript LSP never starts.
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# fzf — fuzzy finder shell integration (Ctrl-T files, Ctrl-R history, Alt-C cd).
# `fzf --zsh` ships the bindings in fzf ≥ 0.48 (Homebrew is current).
if command -v fzf >/dev/null; then
  source <(fzf --zsh 2>/dev/null) 2>/dev/null
  # The base16 scheme paints in ANSI slots, so Ghostty's light/dark flip repaints an
  # open fzf too (its default `dark` scheme is fixed 256-colour cells). Its current
  # line is bright-white on bright-black — unreadable in both GitHub HC palettes — so
  # that row keeps the terminal's own colours, bold. `man fzf` → COLOR SCHEME.
  export FZF_DEFAULT_OPTS='--color=16,fg+:-1:bold,bg+:-1,gutter:-1'
fi

# bat — syntax-highlighted pager. Used as the man pager only; we do NOT alias `cat`
# (that breaks `cat > file` and piping into programs that expect plain output).
if command -v bat >/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"   # colourful man pages via bat
  export MANROFFOPT="-c"
  # Paint in ANSI slots so bat follows
  # Ghostty's light/dark palette — no second theme to switch. `bat --list-themes`.
  export BAT_THEME=ansi
fi
