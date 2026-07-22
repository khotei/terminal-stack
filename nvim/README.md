# ⌨️ Neovim + LazyVim — the editor layer

The "IDE in the terminal." [LazyVim](https://www.lazyvim.org) is a curated [Neovim](https://neovim.io)
distribution on the [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager — LSP, Treesitter, a
fuzzy picker, which-key, git, and a discoverable **`<Space>`-leader** keymap out of the box. This layer
is the official **starter** plus a few opinionated overrides (a shared auto light/dark theme, diffview, dropbar,
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
4. [Recipes — "I want to… → do this"](#4-recipes--i-want-to--do-this) — incl. **the navigation set** (name → code → deps → back)
5. [The picker is the command palette](#5-the-picker-is-the-command-palette)
6. [Inside the floats — each embedded tool is its own app](#6-inside-the-floats--each-embedded-tool-is-its-own-app) — explorer · lazygit · diffview · flash
7. [Advanced craft — LSP, refactor, debug, test](#7-advanced-craft--lsp-refactor-debug-test)
8. [Anti-patterns](#8-anti-patterns)
9. [Living inside Zellij (the manual lock + the leader)](#9-living-inside-zellij-the-manual-lock--the-leader)
10. [What we changed vs. the stock starter](#10-what-we-changed-vs-the-stock-starter) · [Layout](#11-layout)
11. [Settings reference](#12-settings-reference-config-rationale) · [Reload & verify](#13-reload--verify) · [Install](#14-install)

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

**`<leader>` is one namespace of many.** which-key pops over **every prefix key**, not just the leader —
so the same *press-and-wait* reflex maps the whole keyboard. Most of these are **built-in Vim**, not
LazyVim; press one and read the popup:

| Prefix | Namespace | A few members |
|---|---|---|
| `<leader>` (Space) | LazyVim actions *(the tree above)* | `<leader>ff` find · `<leader>gg` git |
| `<C-w>` | **windows** (splits inside nvim) | `<C-w>v` vsplit · `<C-w>h` focus left · `<C-w>=` equalize |
| `g` | **goto & extended** | `gd` definition · `gg` top · `gc` comment · `gu`/`gU` case · `gx` open URL |
| `z` | **folds · view · spelling** | `zz`/`zt`/`zb` recenter · `za` fold · `zg` add-to-dict |
| `]` / `[` | **next / prev** pairs | `]d`/`[d` diagnostic · `]h`/`[h` hunk · `]b`/`[b` buffer · `]t`/`[t` todo |
| `"` | **registers** | `"ay` yank to `a` · `"+p` paste from clipboard |
| `` ` `` / `'` · `m` | **marks** (jump · set) | `` `a `` jump to mark · `ma` set mark `a` |
| `q` / `@` | **macros** (record · replay) | `qa`…`q` record to `a` · `@a` replay |

*(Insert mode has two more: `<C-x>` completion sub-modes — `<C-x><C-f>` files — and `<C-r>` insert-a-register.)*
Distinct from all of these are the **operators** (`d` `c` `y` `>` `gu`…), which take a *motion* (`dw`,
`ci"`) rather than opening a menu — a different mechanism, next note.

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
| Jump *into* the file tree — and back | `<leader>E` *(repo)* |
| Jump to a symbol's definition · back | `gd` · `<C-o>` |
| Teleport to any spot on screen | `s` + 2 chars + label (flash) |
| See what's under the cursor | `K` (hover docs) |
| Rename a symbol everywhere (live preview) | `<leader>cr` |
| Fix-it menu (imports, quick-fixes) | `<leader>ca` (code action) |
| Comment a line / a motion or selection | `gcc` / `gc` |
| Flip an editor option (wrap, numbers, diagnostics…) | `<leader>u` then a letter |
| Full git UI in a float | `<leader>gg` (lazygit) |
| Move focus between splits | `<C-h/j/k/l>` |
| Flip back to the last window I was in | `<C-w>p` |
| Leave insert without reaching for Esc | `jk` *(this repo — [§10](#10-what-we-changed-vs-the-stock-starter))* |

> `<leader>` is `<Space>`. Where a key is a *chord* (`<C-h>` = Ctrl+h), the whole chord is one press;
> where it's a *sequence* (`<leader>gg`), tap the keys in order and which-key guides the rest.

---

## 3. Complete keybinding reference

Everything below is a **LazyVim default** (source: [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps)
and the enabled [extras](https://www.lazyvim.org/extras)) **except** rows tagged *(repo)*, which this
stack adds in [`lua/plugins/`](./lua/plugins) — see [§10](#10-what-we-changed-vs-the-stock-starter).

> **How to read these tables** *(the conventions, stated once)*: `<leader>` = `<Space>`. A **chord**
> (`<C-h>`) is one press; a **sequence** (`<leader>gg`) is keys tapped in turn — which-key guides the
> rest. `·` separates related keys. Two case-symmetries run through the whole keymap — **lowercase acts
> on one, UPPERCASE on the whole** (`ghs`/`ghS` = stage hunk/buffer), and **lowercase goes, UPPERCASE
> moves** (`<C-w>h`/`H` = focus/relocate a split). Rows tagged *(repo)* are this stack's additions.

**Motion & jumps** — move the cursor, don't scroll to hunt for it; **flash** is the multiplier. (Every
row but the flash ones is *built-in Vim*, surfaced here because this is where you reach for "how do I
jump" — the raw editor is otherwise out of scope, [§1](#1-the-mental-model).)

| Keys | What it does |
|---|---|
| `s` · `S` | **flash** — 2 chars + a label, teleport anywhere on screen · flash by Treesitter node ([§6](#6-inside-the-floats--each-embedded-tool-is-its-own-app)) |
| `r` *(operator)* | **remote** flash — `dr…` / `yr…` acts on a far-off target, cursor never leaves home |
| `<C-o>` / `<C-i>` | back / forward through the **jumplist** — every `gd`, `/`, and `s` leaves a breadcrumb |
| `` `` `` · `` `. `` | to where you *just* were · to your last **edit** |
| `*` / `#` | jump to the next / prev use of the **word under the cursor** |
| `]e` / `[e` | next / prev **error** — one of the `]`/`[` next-prev family (diagnostics `]d`, hunks `]h`, …), full set in **Code / LSP** below & [§1](#1-the-mental-model) |

**Text objects** — what an operator *acts on*. Vim ships `iw`/`i(`/`i"`; [mini.ai](https://github.com/nvim-mini/mini.ai)
(a LazyVim default) adds **semantic** ones. Grammar: an operator (`d`/`c`/`y`/`v`) + `a`round / `i`nside +
one letter below. It finds the *next* object if you're not on one (so `ci(` works from before the parens).
**Type `ci` and wait** — which-key lists them all.

| `a` / `i` + | Selects (with `d`/`c`/`y`/`v`) |
|---|---|
| `f` · `c` · `o` | a **function** body · a **class** · a **block** (if / loop / `{…}`) — by Treesitter |
| `(` `[` `{` `"` `` ` `` · `t` | the bracket / quote pair · an HTML/JSX **tag** (`cit` retargets a tag's contents) |
| `u` · `e` · `d` | a **function call** · a **CamelCase** sub-word · a run of **digits** |
| `g` · `?` | the whole **buffer** · a delimiter pair you **type** at a prompt |

> `daf` deletes a whole function · `ci"` changes the string you're near · `yau` yanks a call · `vic` selects a class body.

**Find & navigate** — one [snacks picker](https://www.lazyvim.org/keymaps#snackspicker), many sources ([§5](#5-the-picker-is-the-command-palette)):

| Keys | What it does |
|---|---|
| `<leader><space>` · `<leader>ff` | Find a file by fuzzy name (project root) |
| `<leader>/` | Grep the whole project by content — jump to the match |
| `<leader>sw` · `<leader>sW` | Grep the **word / selection under the cursor** (root · cwd) |
| `<leader>,` | Switch buffer — pick from the open files |
| `<leader>fr` | Recent files (across projects) |
| `<leader>ss` · `<leader>sS` | Symbols in **this file** · in the **whole project** (jump by name) |
| `<leader>sm` | **Marks** — list every bookmark and jump to it |
| `<leader>su` | **Undo history** as a picker — browse and restore a past state |
| `<leader>sR` | Resume the last picker exactly where you left it |
| `<leader>sk` | Search all keymaps by name (the "what was that key?" escape hatch) |
| `<leader>sn…` | **Noice** — recall a message that scrolled past: `snh` full history · `snl` last · `snd` dismiss all |
| `<leader>fc` | Open one of this stack's config files |
| `<leader>e` · `<leader>E` | Explorer: toggle · focus ⇄ back *(repo)* |

**Buffers, windows, tabs:**

| Keys | What it does |
|---|---|
| `<S-h>` / `<S-l>` · `]b` / `[b` | Previous / next buffer |
| `<leader>bd` · `<leader>bo` | Close this buffer · close all **other** buffers |
| `<C-h/j/k/l>` | Move focus between splits |
| `<C-↑/↓/←/→>` | Resize the current split |
| `<C-w>p` | Jump back to the last-active window |
| `<leader>-` · `<leader>\|` | Split below · split right |
| `<leader>wd` · `<leader>wm` | Close the split · zoom it full-screen (toggle) |
| `<leader><tab><tab>` · `<leader><tab>d` | New Neovim tab · close it |
| `<leader><tab>]` / `[` | Next / prev Neovim tab |
| `<C-w>` then a key | The window namespace — split, move, resize (see [§1](#1-the-mental-model)) |

> **Neovim tabs vs. Zellij tabs.** `<leader><tab>*` are Neovim *tabpages* (viewport arrangements inside
> the editor). Your project tabs — editor │ agent — are **Zellij's** (`Ctrl+t`); see the
> [multiplexer doc](../zellij/README.md). Different layers, different keys — no collision.

**Code / LSP** — active wherever a language server is attached (`.ts`/`.tsx` via vtsls, [§7](#7-advanced-craft--lsp-refactor-debug-test)):

| Keys | What it does |
|---|---|
| `gd` · `gr` | Jump to the **definition** · list every **reference** (where it's used) |
| `gI` · `gy` | Jump to **implementations** · to the symbol's **type** |
| `]]` / `[[` | Hop to the next / prev **use** of the symbol under the cursor, in-file (`<a-n>`/`<a-p>` cycle) |
| `K` · `gK` | Hover docs · signature help (parameter hints) — a peek, no jump |
| `<leader>ca` · `<leader>cA` | Code action (add import, quick-fix) · source action (whole-file, e.g. organize imports) |
| `<leader>cr` | Rename the symbol everywhere, live preview *(inc-rename extra)* |
| `<leader>cf` | Format the buffer or selection |
| `<leader>cs` · `<leader>cd` | Outline — a symbol tree of the file *(outline extra)* · line diagnostics |
| `]d` / `[d` · `]e` / `[e` | Next / prev diagnostic · next / prev error |

**Git:**

| Keys | What it does |
|---|---|
| `<leader>gg` · `<leader>gG` | Lazygit — the full git TUI (root · cwd), see [§6](#6-inside-the-floats--each-embedded-tool-is-its-own-app) |
| `<leader>gs` | **Changed files** as a picker — jump straight to what moved |
| `<leader>gl` | Git **log** — browse commits and what each one changed |
| `<leader>gb` · `<leader>gB` | Blame the line inline · open the line on the host (GitHub/…) |
| `]h` / `[h` | Jump to the next / prev **hunk** (a changed block) |
| `<leader>ghp` | **Preview** a hunk's pre-change version inline (non-destructive) |
| `<leader>ghs` · `<leader>ghS` | Stage the **hunk** · the whole **buffer** |
| `<leader>ghr` · `<leader>ghR` | Reset (discard) the **hunk** · the whole **buffer** |
| `<leader>ghb` · `<leader>ghB` | Full blame of the **line** · the whole **buffer** |
| `<leader>ghd` · `<leader>ghD` | Diff the file vs HEAD · vs the previous commit (`~`) |
| `<leader>ghu` | Un-stage the last staged hunk |
| `<leader>gv` · `<leader>gm` | Diffview: working tree · whole branch vs `main` *(repo)* |
| `<leader>gV` · `<leader>gF` | Diffview history — whole repo · current file *(repo)* |

> A **hunk** is a contiguous block of changed lines (a git-diff term — literally a "chunk"). `ghp` peeks
> the pre-change version inline; `ghd`/`ghD` open a full diff vs HEAD / the previous commit. (The
> lower/UPPERCASE = hunk/buffer symmetry is the one from the [§3 legend](#3-complete-keybinding-reference).)

**Diagnostics, search, edit:**

| Keys | What it does |
|---|---|
| `<leader>xx` · `<leader>xX` | All diagnostics · this buffer's, in a Trouble panel |
| `gcc` · `gc` | Toggle a line comment · comment a motion / visual selection |
| `gsa` · `gsd` · `gsr` | Surround: add · delete · replace (`gsaiw"` wraps a word in quotes) *(surround extra)* |
| `]t` / `[t` | Next / prev TODO / FIX comment |
| `<leader>sr` | Project-wide search & replace |

**Debug & test** (from the enabled extras — [§7](#7-advanced-craft--lsp-refactor-debug-test)):

| Keys | What it does |
|---|---|
| `<leader>db` · `<leader>dB` | Toggle a breakpoint · a conditional breakpoint |
| `<leader>dc` · `<leader>di`/`dO`/`do` | Run / continue · step into / over / out |
| `<leader>du` · `<leader>de` | Toggle the DAP UI panels · evaluate an expression |
| `<leader>tr` · `<leader>tt` | Run the nearest test · every test in the file |
| `<leader>ts` · `<leader>to` | Toggle the test summary panel · show test output |
| `<leader>td` · `<leader>tw` | Debug the nearest test · toggle watch (re-run on save) |

**UI toggles & session** — `<leader>u` + a letter flips an option (each remembers its state, [§4](#4-recipes--i-want-to--do-this)):

| Keys | What it does |
|---|---|
| `<leader>uw` · `<leader>ul` · `<leader>uL` | Toggle wrap · line numbers · relative numbers |
| `<leader>uf` · `<leader>ud` | Toggle auto-format-on-save · diagnostics |
| `<leader>uh` · `<leader>uc` | Toggle inlay hints · conceal |
| `<leader>uA` · `<leader>uD` | Toggle the tab-bar *(off by default, [§10](#10-what-we-changed-vs-the-stock-starter))* · scope-dimming |
| `<leader>ub` · `<leader>um` | Toggle dark background · in-buffer Markdown render *(markdown extra)* |
| `<C-/>` | Toggle a terminal at the project root |
| `<leader>qq` · `<leader>qs` / `<leader>ql` | Quit all · restore session / last session |

<details>
<summary><b>More that ships</b> — completion + snippet keys · JSX auto-tags · TODO search · the quiet plugins <em>(click to expand)</em></summary>

**Completion + snippets** — insert mode, [blink.cmp](https://github.com/Saghen/blink.cmp) on the `"enter"` preset. The menu **auto-pops** as you type; you rarely press anything but accept:

| Key | Action |
|---|---|
| `<CR>` · `<C-y>` | **Accept** the selected item |
| `<C-n>` / `<C-p>` | Next / prev candidate |
| `<C-space>` | Force the menu open · toggle the docs popup |
| `<Tab>` / `<S-Tab>` | Jump forward / back through a **snippet's** placeholders |
| `<C-e>` · `<C-k>` | Dismiss the menu · toggle signature help |
| `<C-f>` / `<C-b>` | Scroll the docs popup |

**Find every TODO / FIX** — [todo-comments](https://github.com/folke/todo-comments.nvim), beyond the `]t` / `[t` jumps in the table above:

| Key | Action |
|---|---|
| `<leader>st` · `<leader>xt` | List all TODO/FIX comments — in a picker · in a Trouble panel |

**The quiet machinery** — on by default, (almost) no keys to learn; here so you know *why* the editor already does these:

| Plugin | What it does for you | Reach it via |
|---|---|---|
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | auto-closes and renames JSX/HTML tags as you type | automatic in `.tsx` / `.html` |
| [mini.pairs](https://github.com/nvim-mini/mini.pairs) | auto-closes brackets and quotes | toggle off with `<leader>up` |
| [ts-comments](https://github.com/folke/ts-comments.nvim) | picks the right `gcc` comment string in embedded langs (JSX-in-TS) | automatic |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | runs linters on save, feeding the same `]d` / `]e` diagnostics | automatic |
| [mason](https://github.com/mason-org/mason.nvim) | installs LSP servers / formatters / debug adapters | `:Mason` · add bundles with `:LazyExtras` |

</details>

---

## 4. Recipes — "I want to… → do this"

### The navigation set — from a name to the code, its deps, and back

Most work starts from a **name** you already see — a file in a diff, a symbol in a review, a component
you half-remember. The loop is always the same: **land on it → see what it touches → jump around → get
back → mark the spot.** This is the ready-made key set for each step.

**1 · Land on it — you have a name.**

| You have… | Get there |
|---|---|
| a rough **file name** | `<leader><space>` fuzzy-find · `<leader>fr` recent · `<leader>,` open buffers |
| a **changed** file | `<leader>gs` (changed-files picker) · `<leader>gg` lazygit · `<leader>gv` diffview |
| a **symbol / component** name | `<leader>sS` project symbols · `<leader>ss` this file · `<leader>sw` grep the word |
| the cursor already **on** it | `gd` — jump to its definition |

**2 · See what it touches — dependencies.**

| You want… | Key |
|---|---|
| every place it's **used** | `gr` — references, in a picker |
| to hop **use → use in this file** | `]]` / `[[` (next / prev reference; `<a-n>`/`<a-p>` cycle) |
| its **type** · its **implementations** | `gy` · `gI` |
| the file's **shape** | `<leader>cs` Outline (symbol tree); the **dropbar** winbar shows the path with no keypress |

**3 · Jump around — and get back.**

| Move | Key |
|---|---|
| teleport to any visible spot | `s` (flash) + 2 chars + the label |
| back / forward through your jumps | `<C-o>` / `<C-i>` |
| to the spot you *just* left | `` `` `` (backtick backtick) |
| between changed **hunks** | `]h` / `[h` — `<leader>ghp` peeks the old version |

**4 · Bookmark a spot — marks are Vim's built-in bookmarks.**

| Do | Key |
|---|---|
| drop a mark **in this file** | `ma` (any letter `a`–`z`) |
| drop a **global** mark (survives across files) | `mA` (any capital `A`–`Z`) |
| leap to a mark | `` `a `` (backtick + its letter) |
| list & pick from every mark | `<leader>sm` |

> **The whole loop in one breath:** `<leader>sS` land on a symbol → `gr` / `]]` see its uses → `gd` in,
> `<C-o>` back out → `ma` to bookmark base camp before a deep dive.

**Flip an editor setting without touching config.** `<leader>u` is a whole *namespace* of on/off
switches — wrap (`uw`), line numbers (`ul`), diagnostics (`ud`), inlay hints (`uh`), indent guides
(`ug`), conceal (`uc`), zen mode (`uz`), light/dark (`ub`). Press `<leader>u` and which-key lists every
toggle; each remembers its state, so you flip a thing on, work, and flip it back — no `:set` from memory.

**Comment and move through problems without leaving home row.** `gcc` toggles a line comment; `gc`
takes a motion or a visual selection (`gco` / `gcO` open a fresh comment below / above). Step between
issues with `]d` / `[d` (diagnostics), `]e` (next error), `]t` (next TODO), `]q` (next quickfix). Need a
throwaway buffer? `<leader>.` toggles a **per-project scratchpad**; `<leader>n` reopens a notification you
dismissed too fast.

**Refactor safely.** `<leader>cr` renames the symbol under the cursor with **live preview** — every call
site updates as you type ([inc-rename extra](https://www.lazyvim.org/extras/editor/inc-rename)). Broken
import or a lint the LSP can fix? `<leader>ca` (code action) offers the menu — "Add import", "Organize
imports", quick-fixes — apply and move on.

**Review a diff — especially Claude Code's.** `<leader>gv` opens **diffview** *(repo)* on the working
tree; `<leader>gm` reviews the whole branch vs main (`origin/main...HEAD`). Both open with
`--imply-local`, so the working-tree file is on the right side and **LSP works inside the diff**
(`gd`/`gr`/`K` — no jump to the real file needed). `<leader>gV` shows the repo's commit *history*;
`<leader>gF` narrows it to the current file ([diffview.nvim](https://github.com/sindrets/diffview.nvim)).
Full review workflow: [working-with-agents.md](../docs/working-with-agents.md).
For a stray line, stage it straight from the buffer: cursor on a hunk, `<leader>ghs`; jump between hunks
with `]h` / `[h`. Need the full git TUI? `<leader>gg` floats **lazygit**.

**Run and debug a test at the cursor.** `<leader>tr` runs the nearest test; `<leader>ts` opens the
summary panel; `<leader>td` runs it *under the debugger*. This stack wires the [Vitest and Jest
adapters](./lua/plugins/neotest.lua) *(repo)* so tests are discovered whichever a repo uses.

**Read a Markdown file as a document, not source.** Open any `.md` and `<leader>um` toggles
**render-markdown** *(repo — [markdown extra](https://www.lazyvim.org/extras/lang/markdown))*: headings,
tables, checkboxes and fenced code render *inline, in the buffer* — no browser, no second window. Put the
cursor on a line and it unfolds back to raw Markdown to edit; move off and it re-renders. Press `<leader>um`
again for plain source. *(The extra's browser preview, `markdown-preview.nvim`, is disabled by choice —
[§10](#10-what-we-changed-vs-the-stock-starter).)*

**Format on demand.** `<leader>cf` formats the buffer (or selection) via the LSP/formatter. Auto-format
on save is on by default — toggle it per-session with `<leader>uf` when a repo's formatter fights you.

---

## 5. The picker is the command palette

Almost every "find / list / choose" action funnels through **one** fuzzy picker — the
[snacks picker](https://www.lazyvim.org/keymaps#snackspicker) LazyVim ships. Internalize the picker and
half the keymap comes for free, because the same UI drives files (`<leader><space>`), grep (`<leader>/`),
buffers (`<leader>,`), recent (`<leader>fr`), **keymaps** (`<leader>sk`), symbols (`<leader>ss`), git log,
diagnostics, and more.

**One keymap, every source.** The picker's keys live in *its* window, not in each source — so this
table is identical whether you opened files, grep, or buffers (a source may add a couple of its own —
see below). It's **two windows**: an *input* prompt that opens in **insert** (you type the filter) and
the *list*. The `<C-…>` chords below drive everything **without leaving the filter** — internalize those
and you never switch modes. Prefer Vim motions (`j`/`k`, `gg`/`G`) on the list? `<a-w>` hops focus into
the **list** window (it's in normal mode there); `i` hops back to typing. `<Esc>` **closes** the picker,
it does *not* drop you to normal — so focus, don't Esc. **`?` toggles a live cheatsheet** of these keys
in any picker (source: [snacks.nvim](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)).

| Key | What it does |
|---|---|
| `<C-n>` / `<C-p>` · `↓` / `↑` | Next / prev item |
| `<CR>` | Open in the current window |
| `<C-s>` / `<C-v>` · `<C-t>` | Open in split / vsplit · in a new tab |
| `<Tab>` / `<S-Tab>` · `<C-a>` | Multi-select an item · select all |
| `<C-q>` | Send all matches → the quickfix list |
| `<C-f>` / `<C-b>` · `<a-p>` | Scroll the preview · toggle the preview pane |
| `<C-d>` / `<C-u>` | Half-page down / up in the list |
| `<C-Up>` / `<C-Down>` | Prev / next query from history |
| `<Esc>` · `<C-c>` · `q` | Close the picker |

Reopen the last picker exactly where you left it with **`<leader>sR`** (resume) — the fast path back
after a detour. **A source may add its own keys** atop these: the buffers picker binds `<C-x>` to
*delete the buffer* (that "`<ctrl-x> to close`" hint), and git-status binds `<Tab>` to *stage* / `<C-r>`
to *restore*. When unsure which apply, `?`.

> Reflex: *"I need to get *to* something"* → it's a `<leader>f…` or `<leader>s…` picker. When unsure,
> `<leader>` and read the `f` / `s` branches which-key prints.

---

## 6. Inside the floats — each embedded tool is its own app

The picker taught the trick ([§5](#5-the-picker-is-the-command-palette)): a float is a *separate
application*, and learning its keymap once unlocks all of it. Everything here opens **on top of** the
editor — the `<leader>` tree and `gd`/`K` don't apply; you're driving *that tool* now. Two reflexes
carry across almost all of them: **`?` (or `g?`) opens the tool's own help**, and `q` / `<Esc>` closes
it. Every key below is the tool's own **default** — cited, never invented
([config.md](../.claude/rules/config.md)); the source is linked per tool.

### The explorer (`<leader>e`) — a file manager, not just a tree

`<leader>e` is [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim), the LazyVim default
explorer — it *manages* files, not only opens them. `<leader>e` **toggles** it; `<leader>E` **focuses**
it from any split and, pressed again from inside, hops back (`<C-w>p`) — *(repo,
[§10](#10-what-we-changed-vs-the-stock-starter))*. The authoritative key list is **`?` inside the
tree**; the moves worth memorizing (a few — `l h Y O P` — are LazyVim's additions on top of neo-tree's
own defaults):

| Key | What it does |
|---|---|
| `l` / `<CR>` · `h` | Open · close the node under the cursor |
| `S` · `s` · `t` | Open in split · vsplit · new tab (letters, not chords) |
| `a` · `A` | Add a file · a folder |
| `d` · `r` | Delete · rename |
| `y` · `x` · `p` | Copy · cut · paste files — the tree's own clipboard |
| `Y` · `O` | Copy the **path** to the system clipboard · open in the OS app |
| `c` · `m` | Copy / move to a path you type |
| `.` · `<BS>` | Make the folder under the cursor the root · climb back up |
| `H` · `P` | Toggle hidden files · a preview pane |
| `/` · `[g` / `]g` | Fuzzy-filter within the tree · prev / next git-changed file |

**Secrets.**
- **Reveal-follows-buffer.** `follow_current_file` is on *(repo, via LazyVim)* — the tree always
  highlights the file you're editing; reopen `<leader>e` and you're already on it.
- **Two clipboards.** `y`/`x`/`p` copy/cut/paste files *within* the tree; `Y` puts the file's **path**
  on the system clipboard, and `O` hands the file to the OS's default app.
- **Splits are letters, not chords.** Open a file beside the current one with `S` (horizontal) / `s`
  (vertical) — not `<C-…>`. And `t` opens it in a **new tab**.
- **Reroot on the fly.** `.` makes the folder under the cursor the tree root; `<BS>` climbs back up.

### Lazygit (`<leader>gg`) — the git TUI, its own world

A standalone TUI ([lazygit](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md))
that nvim only floats, so **the keys are lazygit's own**. Five side-panels — **Status `1` · Files `2` ·
Branches `3` · Commits `4` · Stash `5`** — drive a diff view on the right. Jump by number; `[`/`]` cycle
a panel's sub-tabs; `<enter>` "goes into" the selected item. Keys are **context-dependent** — the same
letter differs per panel (`s` = stash in Files, squash in Commits).

| Key | What it does |
|---|---|
| `1`–`5` | Jump to a side-panel (Status · Files · Branches · Commits · Stash) |
| `<space>` | Context action — stage/unstage · checkout · apply stash |
| `<enter>` | Drill in — on a file, opens line/hunk staging |
| `a` | Stage **all** (Files panel) |
| `c` · `C` | Commit · commit in `$EDITOR` (Files) |
| `A` | Amend into the last commit (Files) |
| `P` / `p` | Push / pull |
| `b` · `n` · `f` | Branch menu · new branch · fetch (Branches) |
| `d` · `s` | Discard menu · stash (Files) |
| `z` / `Z` | Undo / redo the last git action |

**Secrets.**
- **Partial staging.** `<enter>` on a file opens the staging view; there `<space>` toggles the
  line/hunk and `v` range-selects — that's how you commit *part* of a file.
- **Interactive rebase, no ceremony.** In the Commits panel, act on a commit directly: `s` squash,
  `f` fixup, `r` reword, `e` edit, `d` drop; `m` opens the continue/abort menu.
- **Cherry-pick by copy/paste.** In Commits, `C` (capital) copies commits and `V` pastes them onto the
  current branch. Mind the case — in Files, `C` means "commit with editor."
- **Instant amend.** `A` in Files folds staged changes into `HEAD` with no prompt.

### Diffview (`<leader>gv` · `<leader>gm`) — the review loop *(repo)*

Side-by-side of every change with a file list you page through — `<leader>gv` for the working tree,
`<leader>gm` for the whole branch vs main. Both use `--imply-local`, so the real file sits on the
right and **LSP is live in the diff** (`gd`/`gr`/`K`, diagnostics) — the review and the code, one view
([diffview.nvim](https://github.com/sindrets/diffview.nvim); `<leader>gV`/`gF` show history;
[full guide](../docs/working-with-agents.md)). Its default keys, once a diffview panel is focused:

| Key | What it does |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / prev file — steps straight into its diff |
| `-` · `s` | Stage · unstage the entry |
| `S` · `U` | Stage-all · unstage-all |
| `X` | Restore the entry to the left side (discard the change) |
| `i` | Toggle the file list between list ⇄ tree |
| `R` · `g?` | Refresh · open help |

> **The whole review loop is two keys:** `-` to stage from the panel, `<Tab>` to step straight into the
> next file's diff — ideal for reading Claude Code's changes ([§4](#4-recipes--i-want-to--do-this)).

### The other panels — Trouble · Outline · Neotest · DAP-UI

Each is a focused list/tree with its own keys (`?` opens help in all of them):

| Panel (open with) | The keys that matter |
|---|---|
| **Trouble** — `<leader>xx` ([docs](https://github.com/folke/trouble.nvim)) | `}` / `{` next/prev item **with preview** (plain `j`/`k` only move the cursor) · `<CR>` jump · `o` jump + close · `q` close |
| **Outline** — `<leader>cs` | `<CR>` jump to the symbol; move through the tree like any buffer |
| **Neotest** — `<leader>ts` ([docs](https://github.com/nvim-neotest/neotest)) | `r` run · `d` debug · `o` output · `w` **watch** (re-run on save) · `m` then `R` mark a set & run it · `J`/`K` next/prev failed |
| **DAP-UI** — `<leader>du` ([docs](https://github.com/rcarriga/nvim-dap-ui)) | `<CR>` expand a variable · `e` edit / set its value · `r` send it to the REPL · `t` toggle a breakpoint |

> **Neotest secret:** `w` turns the summary into a live loop — the test re-runs on every save, so you
> leave the panel open and just keep editing.

### Scratch buffers (`<leader>.` toggle · `<leader>S` list) — a per-project notebook

Two keys, but **two different objects**. `<leader>.` toggles a **scratch buffer** — a real, editable
float ([snacks.scratch](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md)); `<leader>S`
opens a **picker** of every scratch you own, so it obeys the whole [§5](#5-the-picker-is-the-command-palette)
keymap (`<C-s>` / `<C-v>` / `<C-t>` to open one in a split / tab). The float itself is just a buffer —
you edit it with plain Vim; only a few keys are its own:

| Key | Action |
|---|---|
| `q` | close the float (it auto-saves first) |
| `<leader>.` | toggle it shut again |
| `R` | reset to the template *(only if a `template` is set — none by default)* |
| `<CR>` | **lua scratch only** — run the buffer / selection, output inline (`Snacks.debug.run`) |

**Secrets.**
- **A notebook, not a new file each press.** A scratch's identity is a *key* — `name + filetype + count
  + cwd + git-branch` — so the same context always reopens the **same** buffer with last time's notes
  still in it. Files live in `~/.local/share/nvim/scratch/` and **auto-save when hidden** (no `:w`).
- **Want a second one? Count it.** `2<leader>.` opens scratch №2, `3<leader>.` №3 (`vim.v.count1`) — the
  title shows "Scratch 2". A different filetype, project, or branch also spawns its own.
- **No interactive rename.** The filename is a hash of that key, not free text. To label one, bind
  `Snacks.scratch({ name = "notes", ft = "markdown" })` in [`keymaps.lua`](./lua/config/keymaps.lua), or
  rename the file on disk. `<leader>S` lists them newest-first.

### Flash — teleport by label (a motion, not a float)

Not a float, but the highest-leverage *movement* LazyVim ships — quick keys in the
[§3 Motion & jumps](#3-complete-keybinding-reference) table, the mechanism here. `s` + two
characters paints a one-key **label** on every match; press the label to teleport — in Normal mode to
move, in operator-pending (`d`/`y`/`c`) to act on a distant target
([flash.nvim](https://github.com/folke/flash.nvim)).

| Key | Mode | Action |
|---|---|---|
| `s` | normal / visual / op | flash jump — type chars, then a label, to teleport |
| `S` | normal / visual / op | flash Treesitter — label-select a growing syntax node |
| `r` | operator | remote — jump away, act, return (`yr…`) |
| `<C-space>` | normal / op / visual | Treesitter incremental select (grow; `<BS>` shrinks) |

Example: `d` then `r` then `s` + a target deletes a far-off word without moving your cursor home.
(Labels on `f`/`t` are opt-in — LazyVim doesn't enable them by default.)

---

## 7. Advanced craft — LSP, refactor, debug, test

The stack turns LazyVim into a real IDE for **TypeScript/JavaScript** via four
[extras](https://www.lazyvim.org/extras) plus glue this repo adds ([§10](#10-what-we-changed-vs-the-stock-starter)):

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

### Debugging — the deep guide

The loop: breakpoint `<leader>db` → start `<leader>dc` (a config picker) → step `<leader>di`/`dO`/`do`
→ inspect in the dap-ui panels (`<leader>du`). Pick the row for your target:

| Debug target | How | Notes |
|---|---|---|
| **A test** (Vitest · Jest · @effect/vitest) | cursor in the test → `<leader>td` | neotest runs it under dap; @effect/vitest rides the Vitest path |
| **The current file** | `<leader>dc` → **Launch file** | from `lang.typescript`; runs `${file}` under node |
| **An npm / pnpm script** | `<leader>dc` → **Debug npm/pnpm script** → type the script | runs it under the debugger *(repo)* |
| **A VS Code-style config** | drop `.vscode/launch.json` in the project | js-debug configs auto-read into the `<leader>dc` picker, zero setup |
| **Anything already running** | `node --inspect-brk <entry>` in a Zellij pane → `<leader>dc` → **Attach** | the universal escape hatch |

**How it works — the `--inspect` server ↔ client.** Node ships its own debugger; nothing extra to
install. `--inspect` (`--inspect-brk` to pause on line 1) raises an **Inspector** — a debug server
(default `127.0.0.1:9229`) speaking the **Chrome DevTools Protocol**. Any CDP client attaches:
nvim-dap's `js-debug`, `chrome://inspect`, or VS Code.

- **Launch** — the editor starts node for you (`Launch file`, `Debug npm script`); nothing to raise.
- **Attach** — you raise the process with `--inspect`, the editor connects; the universal path.
- **Dev servers** (Next, Vite, Nest…) are node underneath — `NODE_OPTIONS='--inspect' npm run dev` in a
  pane → `<leader>dc` → **Attach**.
- `js-debug` adds source-maps (TS→JS) and child-process auto-attach on top of raw CDP.

**Reliability.** Node must be on `PATH` (the stack supplies it via fnm — `fnm use default` if Neovim
started without the shell env). "Green" ≠ "works": `/check` only proves the dap config *parses*; a
session is proven only when a breakpoint is **hit** — verify interactively. `<leader>dc` failing with
`ECONNREFUSED 127.0.0.1:<port>` is a known js-debug handshake flake
([LazyVim #5913](https://github.com/LazyVim/LazyVim/issues/5913)) — terminate (`<leader>dt`) and retry.

**Known gaps.** `node:test` / `node --test` has no mature neotest adapter (no `<leader>td`) — run it in
a pane, or `node --inspect-brk --test <file>` → **Attach**. **Bun** isn't debuggable from nvim (WebKit
inspector, not CDP) — run `bun test` in a pane, or run the code under node.

---

## 8. Anti-patterns

| Don't | Do instead |
|---|---|
| Memorize the whole keymap | `<Space>` and let **which-key** show the branch |
| `:e path/to/file` from memory | `<leader><space>` fuzzy-find · `<leader>/` grep |
| Hunt a symbol by scrolling | `gd` to its definition, `<C-o>` back; `<leader>cs` outline |
| Rename by find-and-replace | `<leader>cr` (LSP rename, live preview) — every call site |
| Scatter your own maps across files | put them in [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) (the one owning file) |
| Reach for `<Esc>` a mile away | `jk` *(this repo)* |
| Wonder why a Zellij key does nothing in nvim | the pane is **Locked** (you pressed `Alt+d`) — [§9](#9-living-inside-zellij-the-manual-lock--the-leader) |

---

## 9. Living inside Zellij (the manual lock + the leader)

Neovim runs in a **Zellij pane**, so two keyboard layers share your keyboard — and by default the
multiplexer's modal keys (`<C-p>` pane, `<C-t>` tab, `<C-n>` resize, `<C-s>` scroll, `<C-o>` session)
win, so those chords reach *Zellij*, not the editor:

- **`Alt+d` hands nvim *every* keystroke.** There's **no autolock** — you hold the lock by choice. Press
  `Alt+d` and Zellij drops to **Locked** mode, passing keys straight through, so `<C-n>`/`<C-p>`,
  `<C-s>`, `<C-w>`, function keys — all of it reaches the editor untouched. `Alt+d` again takes the
  multiplexer back. `<Space>` (the leader) and the window keys `<C-h/j/k/l>` never collide, so those
  work whether or not you're locked; the `Ctrl+<mode>` chords are the ones the lock frees.
- **A few nvim *defaults* live on `Alt` — Zellij eats those too.** LazyVim binds move-line to `<A-j>` /
  `<A-k>`, but those are exactly Zellij's *focus-pane-down/up* keys, so from an unlocked pane they move
  the Zellij focus, not the line. Lock the pane (`Alt+d`) and they reach the editor. It's the only
  default collision — the rest of the keymap is leader / `Ctrl` / `g`-based.
- **The gotcha: a `Ctrl` chord "does nothing" in nvim → you're *not* locked.** Enter nvim and its
  `Ctrl`-keys are eaten by Zellij until you press `Alt+d` — no auto-locking to catch it for you. This is
  the mirror of the [Zellij reflex](../zellij/README.md#1-the-mental-model).
- **Add editor maps in one place.** [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) is the sole home
  for your maps, so a collision with Zellij's modal keys or Ghostty stays auditable
  ([keyboard-layer contract](../.claude/rules/config.md)). Add them with `vim.keymap.set`.

---

## 10. What we changed vs. the stock starter

The config is the [official LazyVim starter](https://github.com/LazyVim/starter) plus these edits — the
*what* lives in the files; here's the *why*.

| File | Change | Why |
|---|---|---|
| [`lua/plugins/colorscheme.lua`](./lua/plugins/colorscheme.lua) | swap LazyVim's default colorscheme for the stack's shared palette + point the `colorscheme` opt at it | One palette across the stack, auto light/dark — the colorscheme reads `vim.o.background`. Which palette (plugin + options) lives in [`colorscheme.lua`](./lua/plugins/colorscheme.lua); the [LazyVim-documented](https://www.lazyvim.org/configuration/general) way to theme. |
| [`lua/plugins/colorscheme.lua`](./lua/plugins/colorscheme.lua) | add [`f-person/auto-dark-mode.nvim`](https://github.com/f-person/auto-dark-mode.nvim) | Polls the macOS appearance, flips `vim.o.background`, and re-applies the colorscheme so it recompiles for the new mode. Works **inside Zellij**, where the terminal's CSI 2031 signal may not reach the editor. |
| [`lua/config/lazy.lua`](./lua/config/lazy.lua) | point `install.colorscheme` at the stack's palette | Use the real theme during install, not the default tokyonight. |
| [`lua/config/options.lua`](./lua/config/options.lua) | `number`/`relativenumber` off, `wrap` on, `showtabline` off, `scrolloff=8`, `confirm` | Small comfort defaults on top of LazyVim's. |
| [`lua/plugins/bufferline.lua`](./lua/plugins/bufferline.lua) | disable `bufferline.nvim` | Keep the buffer tab-bar hidden for good — `showtabline = 0` alone doesn't stick because bufferline re-enables it on startup. Buffer cycling stays on native `<S-h>`/`<S-l>`, `[b`/`]b`. |
| [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) | `jk` → `<Esc>` | One universal comfort bind; this file is where you port IdeaVim maps. |
| [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) | `<leader>E` → focus / return the neo-tree sidebar | Stock `<leader>e` only *toggles* the tree (closes it from the editor); this **focuses** it from any split in one key — no `<C-h>` hop across splits — and a second press returns to the origin window (`<C-w>p`). Overrides LazyVim's `<leader>E` (cwd explorer, still on `<leader>fE`). |
| [`lazyvim.json`](./lazyvim.json) | enable `lang.markdown` + `lang.typescript` + `editor.inc-rename` + `editor.outline` + `coding.mini-surround` + `dap.core` + `test.core` extras | In-buffer Markdown render (`<leader>um`), TS LSP (`gd`/`gr`/`K`), live rename (`<leader>cr`), outline (`<leader>cs`), surround (`gs*`), debugger (`<leader>d…`), test runner (`<leader>t…`). See [§7](#7-advanced-craft--lsp-refactor-debug-test). |
| [`lua/plugins/markdown.lua`](./lua/plugins/markdown.lua) | disable `markdown-preview.nvim` | `lang.markdown` ships two renderers; keep only render-markdown's in-buffer toggle (`<leader>um`). A terminal-first stack wants no browser tab — and skips the plugin's node build step. |
| [`lua/plugins/dap-node.lua`](./lua/plugins/dap-node.lua) | append an `npm`/`pnpm` "Debug script" dap config | `lang.typescript` covers "Launch file"/"Attach" but not `npm run <script>` under the debugger; appended so its own configs survive. |
| [`lua/plugins/neotest.lua`](./lua/plugins/neotest.lua) | add Vitest + Jest neotest adapters | `test.core` ships neotest with an *empty* adapter table — no adapter, no tests discovered. |
| [`lua/plugins/diffview.lua`](./lua/plugins/diffview.lua) | add [`sindrets/diffview.nvim`](https://github.com/sindrets/diffview.nvim) + `<leader>gv`/`gm`/`gV`/`gF`, `--imply-local` default | Side-by-side diff + file history for reviewing changes (incl. `origin/main...HEAD`); `--imply-local` puts the working file on the right so LSP works in the diff. No LazyVim-native equivalent. |
| [`lua/plugins/dropbar.lua`](./lua/plugins/dropbar.lua) | add [`Bekaboo/dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim) | Breadcrumb winbar (the "Context Info" view). Requires **Neovim ≥ 0.11** — a version floor the stack now depends on. |
| [`lua/plugins/typescript.lua`](./lua/plugins/typescript.lua) | inlay hints **off by default** (`inlay_hints.enabled = false`) + max out the `vtsls` set (`variableTypes`, `parameterNames = "all"`) + noise suppressors | LazyVim ships inlay hints *on* globally — turn them off for a clean buffer. `lang.typescript` also ships variable-type hints off and parameter names at `"literals"` only, so all six categories are maxed (redundant ones suppressed) — one `<leader>uh` then reveals everything, JetBrains-style, on demand. |

## 11. Layout

```
nvim/
├── init.lua                      # one line: require("config.lazy")
├── lua/config/
│   ├── lazy.lua                  # lazy.nvim bootstrap + LazyVim import (+ install-time colorscheme)
│   ├── options.lua               # vim.opt overrides (loaded before lazy)
│   ├── keymaps.lua               # editor maps — the one place to port IdeaVim habits
│   └── autocmds.lua              # autocmds (stub)
├── lua/plugins/
│   ├── colorscheme.lua           # shared palette (auto light/dark via vim.o.background) + auto-dark-mode.nvim
│   ├── diffview.lua              # side-by-side diff + file history
│   ├── dropbar.lua               # breadcrumb winbar
│   ├── dap-node.lua              # npm/pnpm "Debug script" launcher
│   ├── markdown.lua              # disable browser preview (keep in-buffer render)
│   └── neotest.lua               # Vitest + Jest adapters
├── lazyvim.json                  # enabled LazyVim extras
├── stylua.toml                   # 2-space, 120-col (matches the starter)
└── lazy-lock.json                # pinned plugin versions (reproducible installs)
```

---

## 12. Settings reference (config rationale)

The *why* behind the non-obvious choices — the files state the *what*.

| Where | Setting | Why |
|---|---|---|
| `options.lua` | `number = false`, `relativenumber = false` | Start with a clean gutter — no line numbers; flip either on for the buffer with `<leader>ul` / `<leader>uL` when a count motion needs them. LazyVim turns both on by default. |
| `options.lua` | `wrap = true` | Soft-wrap long lines by default so nothing runs off-screen; LazyVim ships wrap off. Toggle with `<leader>uw`. |
| `options.lua` | `scrolloff = 8` | Keep 8 lines of context above/below the cursor — never edit at the screen edge. |
| `options.lua` | `confirm = true` | `:q` with unsaved changes *asks* instead of erroring — one keystroke to save/discard. |
| `lazy.lua` | `install.colorscheme = { <palette>, "habamax" }` | First launch installs plugins under the *real* theme, not the stock tokyonight flash. |
| `colorscheme.lua` | the palette + its own options | The one place the theme is named; it reads `vim.o.background`, which `auto-dark-mode.nvim` flips on macOS appearance change, so the editor tracks the OS **even inside Zellij**. Swap the palette here to re-theme. |
| `stylua.toml` | 2-space, 120-col | Matches the LazyVim starter — `stylua --check nvim/` is the style gate. |

Extras enabled in `lazyvim.json` are the LazyVim [extras manifest](https://www.lazyvim.org/extras); each
one is a curated bundle of plugin + config + keymaps, opt-in by one line.

## 13. Reload & verify

- **Plugins:** edit a spec, then `:Lazy sync` (or restart). `lazy-lock.json` pins versions — commit it
  after a deliberate `:Lazy update`.
- **Validate:** `nvim --headless +qa` exits 0 after bootstrapping. `make check` (Docker, Linux-accurate)
  or `make check-local` (this machine) runs it; so does CI. Verified in the sandbox on **Neovim 0.12 /
  LazyVim 16**.
- **Health:** `:checkhealth` (or `nvim --headless "+checkhealth" +qa`) reports missing providers/deps.
- **Try it now:** `make try` in the sandbox, then `nvim`.

## 14. Install

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
  reference · 4 task-first recipes · 5 a domain multiplier · 6 driving the embedded tools/floats ·
  7 advanced craft · 8 anti-patterns · 9 integration/gotchas · what-changed vs. upstream + layout ·
  settings rationale · reload/verify/install
  · "go deeper" pointers.
Rules honored: cite every key upstream (config.md · never invent) — LazyVim defaults from lazyvim.org,
repo keys from lua/plugins/*; config says what, prose says why (claude-md.md); public repo → assume
world-readable. Rows tagged (repo) are this stack's additions; all else is LazyVim default.
-->
