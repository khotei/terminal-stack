# 🧠 JetBrains — the opt-in IDE profile

For when you still reach for a JetBrains IDE (IntelliJ / WebStorm / PyCharm / Rider / …) next to the
terminal stack. It carries a Vim-first [**IdeaVim**](https://github.com/JetBrains/ideavim) config whose
`<Space>`-leader map **mirrors the LazyVim muscle memory** — `<leader>ff` find file, `gd` go to
definition, `gr` find usages — so the keys you learn in Neovim survive in the IDE, and vice-versa.

- **Files:** [`.ideavimrc`](./.ideavimrc) → `~/.ideavimrc` (symlinked, live) · [`settings.zip`](./settings.zip) — IDE settings, **imported** (not linked)
- **Run:** `make jetbrains` (or `./jetbrains/install.sh`) · **preview:** `./jetbrains/install.sh --dry-run`

> ⚠️ **Opt-in — `bootstrap.sh` / `install.sh` never touch this.** It's for the IDE you keep *around*;
> the stack's primary editor is Neovim. Already migrated? You want
> [`docs/jetbrains-to-stack-review.md`](../docs/jetbrains-to-stack-review.md) instead.

---

## What `make jetbrains` does

1. **Symlinks `.ideavimrc` → `~/.ideavimrc`.** IdeaVim reads it live — `<leader>Ss` (`:source ~/.ideavimrc`)
   reloads without restarting. Idempotent; a real file already there is backed up to `~/.ideavimrc.bak`.
2. **Points you at `settings.zip` to import** through the IDE: *Settings → Manage IDE Settings →
   Import Settings…* → pick `jetbrains/settings.zip`, then restart.

### Why the settings are imported, not symlinked

A JetBrains IDE **rewrites its config on exit**, and that config lives in a versioned, product-specific
dir (`~/Library/Application Support/JetBrains/<Product><ver>/`). Symlinking it would (a) break on the
next IDE update and (b) write machine state back through the link into this repo. Import is one-way and
version-agnostic — the safe path for a dotfiles repo.

### Plugins `.ideavimrc` expects

Install from *Settings → Plugins*: **IdeaVim**, **IdeaVim-EasyMotion** (+ AceJump), **which-key**,
**IdeaVim-Sneak**, **NERDTree**. Missing ones make the matching `set …` lines inert — harmless.

## Keymap cheatsheet (IdeaVim, `<leader>` = `Space`)

The full map is in [`.ideavimrc`](./.ideavimrc); the namespaces:

| Keys | Action | | Keys | Action |
|---|---|---|---|---|
| `<leader>f…` | **Find** (file/text/action/class/symbol) | | `gd` / `gi` / `gy` | Goto decl / impl / type |
| `<leader>g…` | **Git** (branches/commit/push/history) | | `gr` / `gs` | Find / show usages |
| `<leader>r…` | **Refactor** (rename/extract/inline/move) | | `K` | Hover info |
| `<leader>c…` | **Code** (intentions/format/optimize) | | `]e` / `[e` | Next / prev error |
| `<leader>R…` | **Run** · `<leader>D…` **Debug** | | `]c` / `[c` | Next / prev VCS change |
| `<leader>w…` | **Windows** (splits) · `Ctrl-hjkl` nav | | `gch` / `gth` | Call / type hierarchy |

> **Leader note:** the `<Space>` leader matches Neovim's, by design — but the two editors never share
> a keystream (different apps), so there's no collision with the stack's Ghostty/Zellij/nvim layers.

## Public-repo caveat

`settings.zip` is committed **as exported**, so anything your export captured (e.g. `trusted-paths.xml`
listing local project paths) ships with it. Re-export from a clean profile, or prune the zip, if that
matters for your fork.
