# ⌨️ Neovim + LazyVim — the editor layer

The "IDE in the terminal." [LazyVim](https://lazyvim.org) is a curated [Neovim](https://neovim.io)
distribution on the [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager — LSP, Treesitter,
Telescope, which-key, git, and a discoverable `<Space>`-leader keymap, out of the box. This layer is
the official **starter** plus a few opinionated overrides.

- **Dir:** [`nvim/`](.) → `~/.config/nvim/`
- **Validate:** `nvim --headless +qa` (bootstraps plugins, exits 0) — run by `/check` + CI
- **Feature:** `F-EDIT-001` · **Upstream:** <https://lazyvim.org>

---

## Layout

```
nvim/
├── init.lua                      # one line: require("config.lazy")
├── lua/config/
│   ├── lazy.lua                  # lazy.nvim bootstrap + LazyVim import (starter, +catppuccin install)
│   ├── options.lua               # vim.opt overrides (loaded before lazy)
│   ├── keymaps.lua               # editor maps — the place to port IdeaVim habits
│   └── autocmds.lua              # autocmds (stub)
├── lua/plugins/
│   └── colorscheme.lua           # Catppuccin Mocha → LazyVim colorscheme
├── stylua.toml                   # 2-space, 120-col (matches the starter)
└── lazy-lock.json                # pinned plugin versions (reproducible installs)
```

## What we changed vs. the stock starter

| File | Change | Why |
|---|---|---|
| `lua/plugins/colorscheme.lua` | add `catppuccin/nvim` (mocha) + set `colorscheme = "catppuccin"` | One palette across Ghostty / Zellij / Starship. The [LazyVim-documented](https://www.lazyvim.org/configuration/general) way to theme. |
| `lua/config/lazy.lua` | `install.colorscheme = { "catppuccin", … }` | Use the real theme during install, not the default tokyonight. |
| `lua/config/options.lua` | `relativenumber`, `scrolloff=8`, `confirm` | Small comfort defaults on top of LazyVim's. |
| `lua/config/keymaps.lua` | `jk` → `<Esc>` | One universal comfort bind; this file is where you port your IdeaVim maps. |

> **Porting IdeaVim:** `lua/config/keymaps.lua` is the single home for editor maps, so collisions with
> the Zellij prefix (`ctrl+a`) and Ghostty stay auditable
> ([keyboard-layer contract](../.claude/rules/config.md)). Add your maps there with `vim.keymap.set`.

## Keys (LazyVim defaults — discover, don't memorize)

The leader is **`<Space>`**. Press it and **which-key** shows every branch. The essentials:

| Keys | Action |
|---|---|
| `<Space>` then wait | which-key menu (discovery) |
| `<Space>ff` / `<Space>fg` | Find files / live grep (Telescope) |
| `<Space>e` | File explorer (neo-tree) |
| `<Space>gg` | Lazygit |
| `gd` / `gr` / `K` | LSP: definition / references / hover |
| `<Space>ca` / `<Space>cr` | Code action / rename |
| `jk` (insert) | Exit insert mode |

Full reference: <https://www.lazyvim.org/keymaps>.

## Reload & verify

- **Plugins:** edit a spec, then `:Lazy sync` (or restart). `lazy-lock.json` pins versions — commit it
  after a deliberate `:Lazy update`.
- **Validate:** `nvim --headless +qa` exits 0 after bootstrapping. Verified in the Docker sandbox on
  **Neovim 0.12 / LazyVim 16** — 32 plugins install clean. `make check` (Docker, Linux-accurate) or
  `make check-local` (this machine) runs it; so does CI.
- **Try it now:** `make try` in the sandbox, then `nvim`.

## Install

`./install.sh` (or `make install`) symlinks `nvim/` into `~/.config/nvim`. By hand:

```sh
ln -sfn "$PWD/nvim" ~/.config/nvim && nvim   # first launch installs plugins
```

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
