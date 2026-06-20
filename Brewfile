# terminal-stack — Homebrew bundle. Install everything with:  brew bundle
# Verify the file:  brew bundle check   ·   list deps:  brew bundle list
# Names verified against Homebrew. Reference: docs/install.md

# ── terminal ──────────────────────────────────────────────────────────
cask "ghostty"                          # GPU terminal emulator (host GUI)

# ── multiplexer / editor / shell / prompt ─────────────────────────────
brew "zellij"
brew "neovim"
brew "starship"

# ── companion CLIs (wired into the shell + editor) ────────────────────
brew "zoxide"                           # smarter cd
brew "atuin"                            # shell history
brew "fzf"                              # fuzzy finder
brew "fd"                               # fast find
brew "ripgrep"                          # fast grep
brew "lazygit"                          # git TUI
brew "yazi"                             # file manager TUI
brew "jq"                               # JSON (Claude Code statusline)

# ── validators / formatters (used by /check + CI) ─────────────────────
brew "stylua"                           # Lua formatter (nvim)
brew "shfmt"                            # shell formatter

# ── fonts ─────────────────────────────────────────────────────────────
cask "font-symbols-only-nerd-font"      # icon fallback for Ghostty / Starship / LazyVim
cask "font-jetbrains-mono-nerd-font"    # a full Nerd Font (if you don't use Dank Mono)
# Note: Dank Mono (the primary Ghostty font) is not on Homebrew — install it
# yourself, or switch Ghostty's font-family to JetBrainsMono Nerd Font.
