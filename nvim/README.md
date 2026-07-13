# ⌨️ Neovim + LazyVim — the editor layer

The "IDE in the terminal." [LazyVim](https://www.lazyvim.org) is a curated [Neovim](https://neovim.io)
distribution on the [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager — LSP, Treesitter, a
fuzzy picker, which-key, git, and a discoverable **`<Space>`-leader** keymap out of the box. This layer
is the official **starter** plus a few opinionated overrides (Catppuccin auto-theme, diffview, dropbar,
TypeScript/DAP/test extras).

**This file is the single source for Neovim in this stack** — the mental model, the highest-value keys,
a complete reference, task-first recipes, and the config rationale. You should not need the upstream
manual to start working.

- **Dir:** [`nvim/`](.) → `~/.config/nvim/`
- **Validate:** `nvim --headless +qa` (bootstraps plugins, exits 0) — run by `/check` + CI
- **Feature:** `F-EDIT-001` · **Upstream:** <https://www.lazyvim.org>

### Contents

1. [The mental model](#1-the-mental-model) — which-key makes this self-documenting
2. [Quick start: the moves that pay rent](#2-quick-start--the-moves-that-pay-rent)
3. [Complete keybinding reference](#3-complete-keybinding-reference) — by area
4. [Recipes — "I want to… → do this"](#4-recipes--i-want-to--do-this)
5. [The picker is the command palette](#5-the-picker-is-the-command-palette)
6. [Advanced craft — LSP, refactor, debug, test](#6-advanced-craft--lsp-refactor-debug-test)
7. [Anti-patterns](#7-anti-patterns)
8. [Living inside Zellij (autolock + the leader)](#8-living-inside-zellij-autolock--the-leader)
9. [What we changed vs. the stock starter](#9-what-we-changed-vs-the-stock-starter) · [Layout](#10-layout)
10. [Settings reference](#11-settings-reference-config-rationale) · [Reload & verify](#12-reload--verify) · [Install](#13-install)

---

## 1. The mental model

Neovim is modal — Normal / Insert / Visual — and LazyVim layers a **`<Space>` leader** on top: nearly
every non-editing action (find, git, LSP, debug, test, toggle) hangs off a `<Space>`-prefixed tree.

**The one idea that outranks every hotkey: you don't memorize the tree — you *discover* it.** This
setup runs [which-key](https://www.lazyvim.org/keymaps): press **`<Space>` and wait**, and a popup lists
every branch under it — `f` files, `g` git, `c` code, `d` debug, `t` test, `u` toggles, … Keep typing to
drill in. So the goal of everything below is a **mental map of the branches** plus the dozen keys you'll
wear grooves into, not a flashcard deck.

```
<Space> ─wait─▶ which-key menu ─┬─ f  find (files, grep, recent…)
                                ├─ g  git (lazygit, hunks, diff)
                                ├─ c  code (action, rename, format, outline)
                                ├─ d  debug   · t  test   · x  diagnostics
                                └─ u  toggle UI   · q  quit/session
```

Two more discovery aids, both LazyVim defaults: **`<leader>?`** lists every keymap active in *this*
buffer, and **`<leader>sk`** searches all keymaps by name.

> Motions and operators (`w`, `ciw`, `%`, `f`, …) are Vim itself — this doc covers the *LazyVim* layer.
> For the raw editor, `:Tutor` inside nvim, or [neovim.io/doc](https://neovim.io/doc/).

---

## 2. Quick start — the moves that pay rent

Learn these before anything else; grouped by *reflex*, they cover most of a working day. (All are
LazyVim defaults unless the row says otherwise — the exhaustive tables are in
[§3](#3-complete-keybinding-reference).)

| Reflex | Keys |
|---|---|
| Forgot a key → let the editor tell you | `<Space>` then wait (which-key) |
| Open a file by fuzzy name | `<leader><space>` (Find Files, root dir) |
| Search the whole project by content | `<leader>/` (Grep) |
| Flip to the file I just left | `<S-h>` / `<S-l>` (prev / next buffer) |
| Toggle the file tree | `<leader>e` (explorer) |
| Jump to a symbol's definition · back | `gd` · `<C-o>` |
| See what's under the cursor | `K` (hover docs) |
| Rename a symbol everywhere (live preview) | `<leader>cr` |
| Fix-it menu (imports, quick-fixes) | `<leader>ca` (code action) |
| Full git UI in a float | `<leader>gg` (lazygit) |
| Move focus between splits | `<C-h/j/k/l>` |
| Leave insert without reaching for Esc | `jk` *(this repo — [§9](#9-what-we-changed-vs-the-stock-starter))* |

> `<leader>` is `<Space>`. Where a key is a *chord* (`<C-h>` = Ctrl+h), the whole chord is one press;
> where it's a *sequence* (`<leader>gg`), tap the keys in order and which-key guides the rest.

---

## 3. Complete keybinding reference

Everything below is a **LazyVim default** (source: [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps)
and the enabled [extras](https://www.lazyvim.org/extras)) **except** rows tagged *(repo)*, which this
stack adds in [`lua/plugins/`](./lua/plugins) — see [§9](#9-what-we-changed-vs-the-stock-starter).

**Find & navigate** (the [snacks picker](https://www.lazyvim.org/keymaps#snackspicker)):

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader><space>` | Find files (root) | `<leader>/` | Grep (root) |
| `<leader>ff` | Find files (root) | `<leader>fg` | Find files (git-files) |
| `<leader>,` | Buffers | `<leader>fr` | Recent files |
| `<leader>fc` | Find config file | `<leader>sR` | Resume last picker |
| `<leader>sk` | Search keymaps | `<leader>ss` | Symbols (this file) |
| `<leader>e` | Explorer (root) | `<leader>E` | Explorer (cwd) |

**Buffers, windows, tabs:**

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<S-h>` / `<S-l>` | Prev / next buffer | `]b` / `[b` | Prev / next buffer |
| `<leader>bd` | Delete buffer | `<leader>bp` | Toggle pin buffer |
| `<C-h/j/k/l>` | Move focus between splits | `<C-↑/↓/←/→>` | Resize split |
| `<leader>-` | Split below | `<leader>\|` | Split right |
| `<leader>wd` | Close split | `<leader>wm` | Zoom (maximize) split |
| `<leader><tab><tab>` | New tab | `<leader><tab>d` | Close tab |
| `<leader><tab>]` / `[` | Next / prev tab | | |

> **Neovim tabs vs. Zellij tabs.** `<leader><tab>*` are Neovim *tabpages* (viewport arrangements inside
> the editor). Your project tabs — editor │ agent — are **Zellij's** (`Ctrl+t`); see the
> [multiplexer doc](../zellij/README.md). Different layers, different keys — no collision.

**Code / LSP** (active wherever a language server is attached):

| Keys | Action | Keys | Action |
|---|---|---|---|
| `gd` | Goto definition | `gr` | References |
| `gI` | Goto implementation | `gy` | Goto type definition |
| `K` | Hover docs | `gK` | Signature help |
| `<leader>ca` | Code action | `<leader>cA` | Source action |
| `<leader>cr` | Rename (live preview) *(inc-rename extra)* | `<leader>cf` | Format |
| `<leader>cs` | Outline (symbols) *(outline extra)* | `<leader>cd` | Line diagnostics |
| `]d` / `[d` | Next / prev diagnostic | `]e` / `[e` | Next / prev error |

**Git:**

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader>gg` | Lazygit (root) | `<leader>gG` | Lazygit (cwd) |
| `<leader>gb` | Blame line | `<leader>gB` | Git browse (open on host) |
| `]h` / `[h` | Next / prev hunk | `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk | `<leader>ghp` | Preview hunk inline |
| `<leader>ghb` | Blame line (full) | `<leader>ghS` | Stage buffer |
| `<leader>gv` | Diffview: review changes *(repo)* | `<leader>gh` | Diffview: file history (cwd) *(repo)* |
| `<leader>gH` | Diffview: this file's history *(repo)* | | |

**Diagnostics, search, edit:**

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader>xx` | Diagnostics (Trouble) | `<leader>xX` | Buffer diagnostics (Trouble) |
| `gcc` / `gc` | Toggle comment (line / motion) | `gsa` / `gsd` / `gsr` | Surround add / delete / replace *(surround extra)* |
| `]t` / `[t` | Next / prev TODO comment | `<leader>sr` | Search & replace (grep) |

**Debug & test** (from the enabled extras — [§6](#6-advanced-craft--lsp-refactor-debug-test)):

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader>db` | Toggle breakpoint | `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Run / continue | `<leader>di/dO/do` | Step into / over / out |
| `<leader>du` | Toggle DAP UI | `<leader>de` | Eval expression |
| `<leader>tr` | Run nearest test | `<leader>tt` | Run file |
| `<leader>ts` | Toggle test summary | `<leader>to` | Show test output |
| `<leader>td` | Debug nearest test | `<leader>tw` | Toggle watch |

**UI toggles & session:**

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader>uf` | Toggle auto-format | `<leader>uw` | Toggle wrap |
| `<leader>ul` | Toggle line numbers | `<leader>ud` | Toggle diagnostics |
| `<leader>ub` | Toggle dark background | `<C-/>` | Terminal (root) |
| `<leader>qq` | Quit all | `<leader>qs` / `<leader>ql` | Restore session / last session |

---

## 4. Recipes — "I want to… → do this"

**Open the right file without knowing its path.** `<leader><space>` fuzzy-matches filenames from the
project root; type fragments (`usrctrl` → `user_controller.ts`). Don't know the name but know a string
inside? `<leader>/` greps content across the tree and drops you on the match. Both are the
[snacks picker](#5-the-picker-is-the-command-palette) — same picker, different source.

**Understand code you didn't write.** Cursor on a symbol: `K` shows its docs/signature; `gd` jumps to
its definition (`<C-o>` hops back); `gr` lists every reference; `gy` goes to its *type*. Want the whole
file's shape? `<leader>cs` opens the **Outline** (this repo's [outline extra](https://www.lazyvim.org/extras/editor/outline))
— a symbol tree you can jump around; the **dropbar** winbar *(repo)* shows the symbol path at the cursor
like JetBrains' "Context Info", no keypress needed.

**Refactor safely.** `<leader>cr` renames the symbol under the cursor with **live preview** — every call
site updates as you type ([inc-rename extra](https://www.lazyvim.org/extras/editor/inc-rename)). Broken
import or a lint the LSP can fix? `<leader>ca` (code action) offers the menu — "Add import", "Organize
imports", quick-fixes — apply and move on.

**Review a diff — especially Claude Code's.** `<leader>gv` opens **diffview** *(repo)*: a side-by-side of
all working-tree changes with a file list you page through. `<leader>gh` shows the repo's commit
*history*; `<leader>gH` narrows it to the current file ([diffview.nvim](https://github.com/sindrets/diffview.nvim)).
For a stray line, stage it straight from the buffer: cursor on a hunk, `<leader>ghs`; jump between hunks
with `]h` / `[h`. Need the full git TUI? `<leader>gg` floats **lazygit**.

**Run and debug a test at the cursor.** `<leader>tr` runs the nearest test; `<leader>ts` opens the
summary panel; `<leader>td` runs it *under the debugger*. This stack wires the [Vitest and Jest
adapters](./lua/plugins/neotest.lua) *(repo)* so tests are discovered whichever a repo uses.

**Format on demand.** `<leader>cf` formats the buffer (or selection) via the LSP/formatter. Auto-format
on save is on by default — toggle it per-session with `<leader>uf` when a repo's formatter fights you.

---

## 5. The picker is the command palette

Almost every "find / list / choose" action funnels through **one** fuzzy picker — the
[snacks picker](https://www.lazyvim.org/keymaps#snackspicker) LazyVim ships. Internalize the picker and
half the keymap comes for free, because the same UI drives files (`<leader><space>`), grep (`<leader>/`),
buffers (`<leader>,`), recent (`<leader>fr`), **keymaps** (`<leader>sk`), symbols (`<leader>ss`), git log,
diagnostics, and more.

Inside any picker: type to filter, `<C-n>`/`<C-p>` (or `↓`/`↑`) to move, `<CR>` to accept, `<C-v>` /
`<C-s>` to open in a vertical / horizontal split, `<Esc>` to cancel. Reopen the last one exactly where
you left it with **`<leader>sR`** (resume) — the fast path back after a detour.

> Reflex: *"I need to get *to* something"* → it's a `<leader>f…` or `<leader>s…` picker. When unsure,
> `<leader>` and read the `f` / `s` branches which-key prints.

---

## 6. Advanced craft — LSP, refactor, debug, test

The stack turns LazyVim into a real IDE for **TypeScript/JavaScript** via four
[extras](https://www.lazyvim.org/extras) plus glue this repo adds ([§9](#9-what-we-changed-vs-the-stock-starter)):

- **Language intelligence** — [`lang.typescript`](https://www.lazyvim.org/extras/lang/typescript) installs
  the **vtsls** server, so `gd`/`gr`/`K`/`gy` and `<leader>ca` work in `.ts`/`.tsx` (they were inert
  before — no server was installed).
- **Structure & rename** — [`editor.outline`](https://www.lazyvim.org/extras/editor/outline) gives
  `<leader>cs` (symbol tree); [`editor.inc-rename`](https://www.lazyvim.org/extras/editor/inc-rename)
  upgrades `<leader>cr` to a live, previewed rename.
- **Debugging** — [`dap.core`](https://www.lazyvim.org/extras/dap/core) is the [nvim-dap](https://github.com/mfussenegger/nvim-dap)
  UI: `<leader>db` sets a breakpoint, `<leader>dc` launches, `<leader>du` opens the panels, `<leader>di/dO/do`
  step. This repo also adds a *(repo)* [`npm`/`pnpm` "Debug script" launcher](./lua/plugins/dap-node.lua) —
  it prompts for the script name and attaches the debugger.
- **Testing** — [`test.core`](https://www.lazyvim.org/extras/test/core) is [neotest](https://github.com/nvim-neotest/neotest);
  this repo supplies the *(repo)* [Vitest + Jest adapters](./lua/plugins/neotest.lua) so `<leader>tr` /
  `<leader>ts` actually discover tests (the extra ships an empty adapter table).

> Depth beyond this doc — the `node:test`/Bun gaps, attach-to-process, `.vscode/launch.json` reuse — is
> in [Debugging your code](../docs/jetbrains-to-stack-review.md#debugging-your-code).

---

## 7. Anti-patterns

| Don't | Do instead |
|---|---|
| Memorize the whole keymap | `<Space>` and let **which-key** show the branch |
| `:e path/to/file` from memory | `<leader><space>` fuzzy-find · `<leader>/` grep |
| Hunt a symbol by scrolling | `gd` to its definition, `<C-o>` back; `<leader>cs` outline |
| Rename by find-and-replace | `<leader>cr` (LSP rename, live preview) — every call site |
| Scatter your own maps across files | put them in [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) (the one owning file) |
| Reach for `<Esc>` a mile away | `jk` *(this repo)* |
| Wonder why a Zellij key does nothing in nvim | the pane is **locked on purpose** — [§8](#8-living-inside-zellij-autolock--the-leader) |

---

## 8. Living inside Zellij (autolock + the leader)

Neovim runs in a **Zellij pane**, so two keyboard layers share your keyboard. They don't fight, by
design:

- **Zellij hands nvim *every* keystroke.** The multiplexer runs
  [`zellij-autolock`](../zellij/README.md#8-living-with-claude-code--neovim--autolock): the moment a pane
  is running `nvim`, Zellij drops to **Locked** mode and passes keys straight through — so `<Space>`,
  `<C-w>`, function keys, all of it reach the editor untouched. That's *why* the leader can safely be
  `<Space>` and the window keys `<C-h/j/k/l>`: the multiplexer isn't listening while you edit.
- **The escape hatch is `Alt+z`.** If you *do* want a Zellij action (split a pane, switch tabs) while
  focused in nvim, `Alt+z` disables autolock and gives the multiplexer back; `Alt+z` again re-arms. This
  is the reflex from the [Zellij doc](../zellij/README.md#1-the-mental-model) — a Zellij key "not
  working" means the pane is locked to nvim.
- **Add editor maps in one place.** [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) is the sole home
  for your maps, so a collision with Zellij's prefix or Ghostty stays auditable
  ([keyboard-layer contract](../.claude/rules/config.md)). Add them with `vim.keymap.set`.

---

## 9. What we changed vs. the stock starter

The config is the [official LazyVim starter](https://github.com/LazyVim/starter) plus these edits — the
*what* lives in the files; here's the *why*.

| File | Change | Why |
|---|---|---|
| [`lua/plugins/colorscheme.lua`](./lua/plugins/colorscheme.lua) | `catppuccin/nvim` `flavour="auto"` (`background`→latte/mocha) + `colorscheme = "catppuccin"` | One palette across the stack, auto light/dark. `flavour="auto"` tracks `vim.o.background`. The [LazyVim-documented](https://www.lazyvim.org/configuration/general) way to theme. |
| [`lua/plugins/colorscheme.lua`](./lua/plugins/colorscheme.lua) | add [`f-person/auto-dark-mode.nvim`](https://github.com/f-person/auto-dark-mode.nvim) | Polls the macOS appearance and flips `vim.o.background` → catppuccin recompiles. Works **inside Zellij**, where the terminal's CSI 2031 signal may not reach the editor. |
| [`lua/config/lazy.lua`](./lua/config/lazy.lua) | `install.colorscheme = { "catppuccin", … }` | Use the real theme during install, not the default tokyonight. |
| [`lua/config/options.lua`](./lua/config/options.lua) | `relativenumber`, `scrolloff=8`, `confirm` | Small comfort defaults on top of LazyVim's. |
| [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) | `jk` → `<Esc>` | One universal comfort bind; this file is where you port IdeaVim maps. |
| [`lazyvim.json`](./lazyvim.json) | enable `lang.typescript` + `editor.inc-rename` + `editor.outline` + `coding.mini-surround` + `dap.core` + `test.core` extras | TS LSP (`gd`/`gr`/`K`), live rename (`<leader>cr`), outline (`<leader>cs`), surround (`gs*`), debugger (`<leader>d…`), test runner (`<leader>t…`). See [§6](#6-advanced-craft--lsp-refactor-debug-test). |
| [`lua/plugins/dap-node.lua`](./lua/plugins/dap-node.lua) | append an `npm`/`pnpm` "Debug script" dap config | `lang.typescript` covers "Launch file"/"Attach" but not `npm run <script>` under the debugger; appended so its own configs survive. |
| [`lua/plugins/neotest.lua`](./lua/plugins/neotest.lua) | add Vitest + Jest neotest adapters | `test.core` ships neotest with an *empty* adapter table — no adapter, no tests discovered. |
| [`lua/plugins/diffview.lua`](./lua/plugins/diffview.lua) | add [`sindrets/diffview.nvim`](https://github.com/sindrets/diffview.nvim) + `<leader>gv`/`gh`/`gH` | Side-by-side diff + file history for reviewing changes — no LazyVim-native equivalent. |
| [`lua/plugins/dropbar.lua`](./lua/plugins/dropbar.lua) | add [`Bekaboo/dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim) | Breadcrumb winbar (the "Context Info" view). Requires **Neovim ≥ 0.11** — a version floor the stack now depends on. |

## 10. Layout

```
nvim/
├── init.lua                      # one line: require("config.lazy")
├── lua/config/
│   ├── lazy.lua                  # lazy.nvim bootstrap + LazyVim import (+catppuccin install theme)
│   ├── options.lua               # vim.opt overrides (loaded before lazy)
│   ├── keymaps.lua               # editor maps — the one place to port IdeaVim habits
│   └── autocmds.lua              # autocmds (stub)
├── lua/plugins/
│   ├── colorscheme.lua           # Catppuccin (auto latte/mocha) + auto-dark-mode.nvim
│   ├── diffview.lua              # side-by-side diff + file history
│   ├── dropbar.lua               # breadcrumb winbar
│   ├── dap-node.lua              # npm/pnpm "Debug script" launcher
│   └── neotest.lua               # Vitest + Jest adapters
├── lazyvim.json                  # enabled LazyVim extras
├── stylua.toml                   # 2-space, 120-col (matches the starter)
└── lazy-lock.json                # pinned plugin versions (reproducible installs)
```

---

## 11. Settings reference (config rationale)

The *why* behind the non-obvious choices — the files state the *what*.

| Where | Setting | Why |
|---|---|---|
| `options.lua` | `relativenumber = true` | Line-relative counts make `j`/`k`-with-a-count motions (`5j`) instant to aim. |
| `options.lua` | `scrolloff = 8` | Keep 8 lines of context above/below the cursor — never edit at the screen edge. |
| `options.lua` | `confirm = true` | `:q` with unsaved changes *asks* instead of erroring — one keystroke to save/discard. |
| `lazy.lua` | `install.colorscheme = { "catppuccin", "habamax" }` | First launch installs plugins under the *real* theme, not the stock tokyonight flash. |
| `colorscheme.lua` | `flavour = "auto"` | Follows `vim.o.background`; `auto-dark-mode.nvim` flips that on macOS appearance change, so the editor tracks the OS **even inside Zellij**. |
| `stylua.toml` | 2-space, 120-col | Matches the LazyVim starter — `stylua --check nvim/` is the style gate. |

Extras enabled in `lazyvim.json` are the LazyVim [extras manifest](https://www.lazyvim.org/extras); each
one is a curated bundle of plugin + config + keymaps, opt-in by one line.

## 12. Reload & verify

- **Plugins:** edit a spec, then `:Lazy sync` (or restart). `lazy-lock.json` pins versions — commit it
  after a deliberate `:Lazy update`.
- **Validate:** `nvim --headless +qa` exits 0 after bootstrapping. `make check` (Docker, Linux-accurate)
  or `make check-local` (this machine) runs it; so does CI. Verified in the sandbox on **Neovim 0.12 /
  LazyVim 16**.
- **Health:** `:checkhealth` (or `nvim --headless "+checkhealth" +qa`) reports missing providers/deps.
- **Try it now:** `make try` in the sandbox, then `nvim`.

## 13. Install

`./install.sh` (or `make install`) symlinks `nvim/` into `~/.config/nvim`. By hand:

```sh
ln -sfn "$PWD/nvim" ~/.config/nvim && nvim   # first launch installs plugins
```

Needs **Neovim ≥ 0.11** (dropbar) and, for the TS/test/debug flow, `node`+`lazygit` on `$PATH` — all via
[Homebrew](../.claude/rules/tooling.md).

### Go deeper (on demand — not front to back)

- Every default keymap → [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps)
- Add plugins / override extras → [configuration](https://www.lazyvim.org/configuration)
- The extras catalog → [lazyvim.org/extras](https://www.lazyvim.org/extras)
- Raw Neovim (motions, `:help`) → [neovim.io/doc](https://neovim.io/doc/) · `:Tutor`

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).

<!--
This README is the per-tool doc pattern: ONE file per tool, at <tool>/README.md (GitHub renders it, the
root README links it). To enrich another tool's README to this shape, follow the section order:
  1 mental model (the one load-bearing concept) · 2 quick-start "moves that pay rent" · 3 complete
  reference · 4 task-first recipes · 5 a domain multiplier · 6 advanced craft · 7 anti-patterns ·
  8 integration/gotchas · what-changed vs. upstream + layout · settings rationale · reload/verify/install
  · "go deeper" pointers.
Rules honored: cite every key upstream (config.md · never invent) — LazyVim defaults from lazyvim.org,
repo keys from lua/plugins/*; config says what, prose says why (claude-md.md); public repo → assume
world-readable. Rows tagged (repo) are this stack's additions; all else is LazyVim default.
-->
