# Tech stack

A terminal-first dev environment. Each tool owns one layer; the configs wire them into a coherent
whole. Install via **Homebrew** (`@.claude/rules/tooling.md`). Always cite the upstream doc for a
config key — **never invent one** (`@.claude/rules/config.md`).

| Layer | Tool | Config | Notes |
|---|---|---|---|
| **Terminal** | **Ghostty** | `ghostty/config` → `~/.config/ghostty/config` | A single file, **no extension**, `key = value` syntax (one directive per line; repeated keys like `keybind` accumulate). GPU-accelerated; hot-reloads config. Docs: ghostty.org. |
| **Multiplexer** | **Zellij** | `zellij/config.kdl` (+ `layouts/*.kdl`) → `~/.config/zellij/` | Config and layouts are **KDL**. Owns the prefix key and pane/tab/session management. Plugins (e.g. **zellij-autolock**, which releases the prefix to nested apps like nvim) load from the config/layout. Docs: zellij.dev. |
| **Editor** | **Neovim + LazyVim** | `nvim/` → `~/.config/nvim/` | **Lua** config on the **lazy.nvim** plugin manager; LazyVim is the distro/preset on top. Entry `init.lua`; plugins as lazy.nvim specs under `lua/plugins/*.lua`, settings under `lua/config/`. Docs: lazyvim.org, neovim.io. |
| **Shell** | **zsh + Starship** | `zsh/.zshrc`, `zsh/*.zsh`, `zsh/starship.toml` | zsh as the login shell; **Starship** the cross-shell prompt (`starship.toml`). Thin `.zshrc` sourcing role files (`env.zsh`, `aliases.zsh`, `prompt.zsh`). Docs: starship.rs. |
| **Agent** | **Claude Code** | `.claude/` | Lives in a multiplexer pane; runs the SDD loop against Notion (`@.claude/commands/README.md`). The `.claude/` toolkit + rules are themselves config in this repo. |

## Shell companion tools

The shell layer wires together a set of standard CLIs (installed via Homebrew):

- **zoxide** — smarter `cd` (frecency-ranked jumps).
- **atuin** — shell history (searchable, optionally synced).
- **fzf** — fuzzy finder; powers history/file pickers.
- **fd** — fast `find` replacement; **ripgrep** (`rg`) — fast `grep`.
- **lazygit** — TUI git client (often bound in nvim and/or a Zellij pane).
- **yazi** — TUI file manager.

These are runtime dependencies the configs reference (aliases, fzf keybinds, nvim integrations), not
themselves configured by their own files in this repo unless a feature adds one.

## The keyboard-layer contract

Three tools own keyboard input and **must not collide** (`@.claude/rules/config.md`):

- **Ghostty** — terminal-level keys.
- **Zellij** — the multiplexer **prefix** (e.g. `ctrl+a`) and everything under it.
- **Neovim** — the editor **leader** (e.g. `<space>`) and editor maps.

A new bind in any layer must not shadow the layer below. Record the chosen prefix/leader as an
invariant in the relevant `CLAUDE.md`.

## Platform

Primary target is **macOS** (Homebrew, Ghostty). Most of the stack is cross-platform (Linux); where
a key or install step is macOS-specific, note it at the site.
