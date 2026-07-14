# Prompt — Starship (config: ~/.config/starship.toml; styled with the terminal's ANSI slots).
# Sourced last so it initialises over a fully-configured shell.
command -v starship >/dev/null && eval "$(starship init zsh)"
