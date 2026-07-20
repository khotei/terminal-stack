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
4. [Recipes — "I want to… → do this"](#4-recipes--i-want-to--do-this)
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

**Find & navigate** (the [snacks picker](https://www.lazyvim.org/keymaps#snackspicker)):

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader><space>` | Find files (root) | `<leader>/` | Grep (root) |
| `<leader>ff` | Find files (root) | `<leader>fg` | Find files (git-files) |
| `<leader>,` | Buffers | `<leader>fr` | Recent files |
| `<leader>fc` | Find config file | `<leader>sR` | Resume last picker |
| `<leader>sk` | Search keymaps | `<leader>ss` | Symbols (this file) |
| `<leader>e` | Explorer toggle (root) | `<leader>E` | Explorer focus ⇄ back *(repo)* |
| `<leader>fe` | Explorer (root) | `<leader>fE` | Explorer (cwd) |

**Buffers, windows, tabs:**

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<S-h>` / `<S-l>` | Prev / next buffer | `]b` / `[b` | Prev / next buffer |
| `<leader>bd` | Delete buffer | `<leader>bo` | Delete other buffers |
| `<C-h/j/k/l>` | Move focus between splits | `<C-↑/↓/←/→>` | Resize split |
| `<C-w>p` | Focus last-active window | `<leader>-` | Split below |
| `<leader>\|` | Split right | | |
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
| `<leader>gv` | Diffview: working tree *(repo)* | `<leader>gm` | Diffview: branch vs main *(repo)* |
| `<leader>gh` | Diffview: file history (cwd) *(repo)* | `<leader>gH` | Diffview: this file's history *(repo)* |

**Diagnostics, search, edit:**

| Keys | Action | Keys | Action |
|---|---|---|---|
| `<leader>xx` | Diagnostics (Trouble) | `<leader>xX` | Buffer diagnostics (Trouble) |
| `gcc` / `gc` | Toggle comment (line / motion) | `gsa` / `gsd` / `gsr` | Surround add / delete / replace *(surround extra)* |
| `]t` / `[t` | Next / prev TODO comment | `<leader>sr` | Search & replace (grep) |

**Debug & test** (from the enabled extras — [§7](#7-advanced-craft--lsp-refactor-debug-test)):

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
| `<leader>um` | Toggle Render Markdown *(markdown extra)* | `<leader>qq` | Quit all |
| `<leader>qs` / `<leader>ql` | Restore session / last session | | |

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
(`gd`/`gr`/`K` — no jump to the real file needed). `<leader>gh` shows the repo's commit *history*;
`<leader>gH` narrows it to the current file ([diffview.nvim](https://github.com/sindrets/diffview.nvim)).
Full review workflow: [reviewing-changes.md](../docs/reviewing-changes.md).
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

| Key | Action | Key | Action |
|---|---|---|---|
| `<C-n>` / `<C-p>` · `↓` / `↑` | next / prev item | `<CR>` | open (current window) |
| `<C-s>` / `<C-v>` | open in split / vsplit | `<C-t>` | open in a **new tab** |
| `<Tab>` / `<S-Tab>` | multi-select an item | `<C-a>` | select all |
| `<C-q>` | send matches → quickfix | `<C-f>` / `<C-b>` | scroll the **preview** |
| `<C-d>` / `<C-u>` | half-page down / up (list) | `<a-p>` | toggle the preview pane |
| `<C-Up>` / `<C-Down>` | prev / next query from history | `<Esc>` · `<C-c>` · `q` | close |

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

| Key | Action | Key | Action |
|---|---|---|---|
| `l` / `<CR>` · `h` | open · close node | `a` · `A` | add file · add folder |
| `S` / `s` | open in split / vsplit | `d` · `r` | delete · rename |
| `t` | open in a new tab | `y` · `x` · `p` | copy · cut · paste (tree clipboard) |
| `Y` · `O` | copy **path** · open in system app | `c` · `m` | copy / move to a typed path |
| `.` · `<BS>` | folder under cursor as root · up | `H` · `P` | toggle hidden · preview |
| `/` | fuzzy-filter **within the tree** | `[g` / `]g` | prev / next git-changed |

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

| Key | Action | Key | Action |
|---|---|---|---|
| `1`–`5` | jump to a side-panel | `<space>` | stage/unstage · checkout · apply stash |
| `a` | stage **all** (Files) | `<enter>` | drill in — on a file → line/hunk staging |
| `c` · `C` | commit · commit in `$EDITOR` (Files) | `A` | amend into the last commit (Files) |
| `P` / `p` | push / pull | `b` · `n` · `f` | branch menu · new branch · fetch (Branches) |
| `d` · `s` | discard menu · stash (Files) | `z` / `Z` | undo / redo the last git action |

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
([diffview.nvim](https://github.com/sindrets/diffview.nvim); `<leader>gh`/`gH` show history;
[full guide](../docs/reviewing-changes.md)). Its default keys, once a diffview panel is focused:

| Key | Action | Key | Action |
|---|---|---|---|
| `<Tab>` / `<S-Tab>` | next / prev file (into its diff) | `-` / `s` | stage / unstage the entry |
| `S` / `U` | stage-all / unstage-all | `X` | restore the entry to the left side |
| `i` | toggle list ⇄ tree | `R` · `g?` | refresh · help |

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

### Bonus — flash: the motion the guide was missing

Not a float, but the highest-leverage *movement* LazyVim ships — and this doc omitted it. `s` + two
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

> Depth beyond this doc — the `node:test`/Bun gaps, attach-to-process, `.vscode/launch.json` reuse — is
> in [Debugging your code](../docs/jetbrains-to-stack-review.md#debugging-your-code).

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
| [`lua/plugins/diffview.lua`](./lua/plugins/diffview.lua) | add [`sindrets/diffview.nvim`](https://github.com/sindrets/diffview.nvim) + `<leader>gv`/`gm`/`gh`/`gH`, `--imply-local` default | Side-by-side diff + file history for reviewing changes (incl. `origin/main...HEAD`); `--imply-local` puts the working file on the right so LSP works in the diff. No LazyVim-native equivalent. |
| [`lua/plugins/dropbar.lua`](./lua/plugins/dropbar.lua) | add [`Bekaboo/dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim) | Breadcrumb winbar (the "Context Info" view). Requires **Neovim ≥ 0.11** — a version floor the stack now depends on. |
| [`lua/plugins/typescript.lua`](./lua/plugins/typescript.lua) | max out `vtsls` inlay hints (`variableTypes`, `parameterNames = "all"`) + noise suppressors | `lang.typescript` ships variable-type hints off and parameter names at `"literals"` only, so `<leader>uh` reveals little. All six hint categories on (suppressing the redundant ones) so one toggle shows everything, JetBrains-style. |

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
