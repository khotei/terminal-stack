# ✴️ Cursor — the opt-in IDE profile

For when you reach for [**Cursor**](https://cursor.com) (the VS Code fork) next to the terminal stack.
It carries a Vim-first profile: the [`asvetliakov.vscode-neovim`](https://github.com/vscode-neovim/vscode-neovim)
extension driven by an [`init.lua`](./init.lua) whose `<Space>`-leader map mirrors the LazyVim muscle
memory (`<leader>gd` definition, `<leader>gr` references, `<leader>sf` quick-open) — the keys carry
across both editors.

- **Files:** [`settings.json`](./settings.json) · [`keybindings.json`](./keybindings.json) → Cursor `User/` (symlinked, live) · [`init.lua`](./init.lua) → `~/.config/cursor/init.lua`
- **Run:** `make cursor` (or `./cursor/install.sh`) · **preview:** `./cursor/install.sh --dry-run`

> ⚠️ **Opt-in — `bootstrap.sh` / `install.sh` never touch this.** The stack's primary editor is
> Neovim; this is for the GUI editor you keep around.

---

## What `make cursor` does

Symlinks three files (idempotent; a real file already there is backed up to `.bak`):

| Source | → Target | Live? |
|---|---|---|
| `settings.json` | `~/Library/Application Support/Cursor/User/settings.json` | Yes — Cursor reads **and writes** it; edits flow back to the repo |
| `keybindings.json` | `…/Cursor/User/keybindings.json` | Yes |
| `init.lua` | `~/.config/cursor/init.lua` | Loaded by vscode-neovim (wired once, below) |

Unlike JetBrains, a VS Code-family editor keeps its user config as plain JSON it reads/writes in place,
so symlinking is the standard, two-way dotfiles pattern — your in-app setting changes land in the repo.

## One-time wiring (in Cursor)

1. **Install the extension:** `asvetliakov.vscode-neovim` (`Cmd+Shift+X`). The committed
   `settings.json` already gives it render affinity (`extensions.experimental.affinity`).
2. **Point it at `init.lua`** — add to `settings.json` (the upstream export doesn't include this):
   ```jsonc
   "vscode-neovim.neovimInitVimPaths": { "darwin": "~/.config/cursor/init.lua" }
   ```
   This is deliberately separate from the stack's `~/.config/nvim` (LazyVim) so the heavy distro
   doesn't load inside Cursor.
3. **Reload the window** (`Cmd+Shift+P` → *Reload Window*).

Other extensions the config references — **GitLens**, **Bookmarks**, **Catppuccin Icons**,
**custom-ui-style** — are optional; a missing one just makes its settings inert.

## Keymap cheatsheet (`<leader>` = `Space`, in Cursor)

Full map in [`init.lua`](./init.lua).

| Keys | Action | | Keys | Action |
|---|---|---|---|---|
| `<leader>sf` / `sa` | Quick-open / commands | | `<leader>gd` / `gi` / `gy` | Def / impl / type |
| `<leader>fg` / `rg` | Find / replace in files | | `<leader>gr` | References |
| `<leader>re` / `rf` | Rename / refactor | | `<leader>vd` / `vh` | Peek def / hover |
| `<leader>fm` / `oi` | Format / organize imports | | `<leader>en` / `ep` | Next / prev problem |
| `<leader>m…` | Bookmarks | | `<leader>w…` | Editor splits |

> **Leader note:** `<Space>` matches Neovim's by design; Cursor and the terminal nvim never share a
> keystream, so there's no collision with the stack's Ghostty / Zellij / nvim layers. The terminal
> keys (`alt+n/p/s/c/k`) in `keybindings.json` drive Cursor's integrated terminal only.
