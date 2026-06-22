# terminal-stack — Homebrew bundle. Install everything with:  brew bundle
# Verify the file:  brew bundle check   ·   list deps:  brew bundle list
# Update the stack's tools later:  make update
# Names verified against Homebrew. Reference: docs/install.md

# ══════════════════════════════════════════════════════════════════════
# THE STACK
# ══════════════════════════════════════════════════════════════════════

# ── terminal ──────────────────────────────────────────────────────────
cask "ghostty"                          # GPU terminal emulator (host GUI)

# ── multiplexer / editor / shell / prompt ─────────────────────────────
brew "zellij"
brew "neovim"
brew "starship"
brew "zsh-vi-mode"                       # Vim editing on the command line (zsh/vi-mode.zsh)

# ── agent ─────────────────────────────────────────────────────────────
cask "claude-code"                      # the whole point — Claude Code, runs in a Zellij pane

# ── companion CLIs (wired into the shell + editor) ────────────────────
brew "zoxide"                           # smarter cd
brew "atuin"                            # shell history
brew "fzf"                              # fuzzy finder
brew "fd"                               # fast find
brew "ripgrep"                          # fast grep
brew "lazygit"                          # git TUI
brew "yazi"                             # file manager TUI
brew "jq"                               # JSON (Claude Code statusline)
brew "eza"                              # modern ls (zsh/aliases.zsh)
brew "bat"                              # better cat / man pager (zsh/tools.zsh)
brew "git-delta"                        # pretty git diffs — binary is `delta` (git/config)
brew "zsh-autosuggestions"             # grey inline history suggestions (zsh/plugins.zsh)
brew "zsh-syntax-highlighting"         # colour the command line as you type (must load last)
brew "fzf-tab"                         # Tab completion becomes an fzf picker

# ── validators / formatters (used by /check + CI) ─────────────────────
brew "stylua"                           # Lua formatter (nvim)
brew "shfmt"                            # shell formatter

# ── git / containers (the SDD workflow + the sandbox) ─────────────────
brew "gh"                               # PRs, the SDD loop
cask "docker-desktop"                   # the `make try` sandbox

# ── fonts ─────────────────────────────────────────────────────────────
cask "font-symbols-only-nerd-font"      # icon fallback for Ghostty / Starship / LazyVim
cask "font-jetbrains-mono-nerd-font"    # a full Nerd Font (fallback / free alternative)
# Dank Mono (the primary Ghostty font) is not on Homebrew — it's bundled under
# fonts/ and installed by ./install.sh (see fonts/README.md for its license).

# ══════════════════════════════════════════════════════════════════════
# PERSONAL — apps used to actually drive the machine
# ══════════════════════════════════════════════════════════════════════
brew "mas"                              # Mac App Store CLI (for the `mas` lines below)

cask "arc"                              # browser
cask "google-chrome"                    # browser
cask "claude"                           # Claude desktop app (distinct from claude-code above)
cask "notion"                           # the SDD specs/hub live here
cask "obsidian"                         # notes
cask "telegram"                         # chat
cask "raycast"                          # launcher
cask "alt-tab"                          # window switcher
cask "shottr"                           # screenshots
cask "hiddenbar"                        # menu-bar declutter
cask "languagetool-desktop"             # grammar
mas  "OS Cleaner Pro", id: 1084211765

# ══════════════════════════════════════════════════════════════════════
# DEVELOPMENT — tooling beyond the terminal stack
# ══════════════════════════════════════════════════════════════════════
tap "oven-sh/bun"                       # third-party tap — if brew bundle errors here: brew trust oven-sh/bun
brew "bun"                              # JS runtime / package manager
brew "fnm"                              # fast Node version manager — wired in zsh/tools.zsh; bootstrap installs an LTS. Provides node for the Neovim TS LSP (mason → vtsls).
# cask "figma"                          # design (enable if needed)

# ── retired by the terminal stack (kept for reference, NOT installed) ──
# cask "intellij-idea"                  # → Neovim + LazyVim   (nvim/)
# cask "warp"                           # → Ghostty            (ghostty/)
