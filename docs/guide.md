# 📖 The developer's guide to terminal-stack

How to actually *live* in this terminal — the mental model, the keys, and the moves a developer makes
to get real work done. Read it top-to-bottom once to get oriented; come back to the
[scenarios](#user-flows) and [cheat sheets](#cheat-sheets) to remember an ergonomic combo.

> **New here?** Install with [`docs/install.md`](install.md) (or `make try` for a no-install Docker
> sandbox of the in-terminal layers), then start at [First five minutes](#first-five-minutes).

---

## Contents

1. [The mental model](#the-mental-model)
2. [First five minutes](#first-five-minutes)
3. [Cheat sheets](#cheat-sheets)
   - [Ghostty (terminal)](#ghostty--terminal)
   - [Zellij (multiplexer)](#zellij--multiplexer)
   - [Neovim + LazyVim (editor)](#neovim--lazyvim--editor)
   - [Command line (zsh vi-mode + tools)](#command-line--zsh-vi-mode--tools)
   - [lazygit (git TUI)](#lazygit--git-tui)
   - [yazi (file manager)](#yazi--file-manager)
   - [Claude Code (agent)](#claude-code--agent)
4. [User flows](#user-flows)
   - [1. Start a project session](#1-start-a-project-session)
   - [2. Find and edit code](#2-find-and-edit-code)
   - [3. Pair with Claude Code](#3-pair-with-claude-code)
   - [4. Git, the fast way](#4-git-the-fast-way)
   - [5. Run agents in parallel (worktrees)](#5-run-agents-in-parallel-worktrees)
   - [6. Move around (history, dirs, files)](#6-move-around-history-dirs-files)
   - [7. Edit a long command (vi-mode)](#7-edit-a-long-command-vi-mode)
   - [8. Tweak and reload a config](#8-tweak-and-reload-a-config)
5. [A day in the life](#a-day-in-the-life)
6. [Ergonomic principles](#ergonomic-principles)
7. [Reload & troubleshoot](#reload--troubleshoot)
8. [Further reading](#further-reading)

---

## The mental model

Five layers, each owning one job, nested inside each other:

```
┌─ Ghostty ──────────────────────────────────────────────┐   the window (GPU, font, copy/paste)
│ ┌─ Zellij ───────────────────────────────────────────┐ │   sessions · tabs · panes  (prefix ⌃a)
│ │ ┌─ pane: Neovim ─────────┐ ┌─ pane: Claude Code ──┐ │ │   edit  ││  the agent
│ │ │  <Space> leader        │ │  statusline, /cmds   │ │ │
│ │ │  LSP · Telescope · git │ │  cc-worktree         │ │ │
│ │ └────────────────────────┘ └──────────────────────┘ │ │
│ │  zsh + Starship + vi-mode  (the shell every pane runs)│ │
│ └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

**The one rule that makes it all fit — the keyboard-layer contract.** Three tools own keyboard input,
and they never collide:

| Layer | Owns | Entry key |
|---|---|---|
| **Ghostty** | terminal-level keys (font, copy/paste, quick-terminal) | `⌘ …` |
| **Zellij** | sessions, tabs, panes | **`⌃a`** prefix, then a key |
| **Neovim** | editor motions, LSP, plugins | **`<Space>`** leader, then a key |

So your fingers always know *which tool they're talking to*: a bare `⌃a` means "multiplexer", a bare
`<Space>` in the editor means "editor command". Ghostty deliberately leaves `⌃a` free; Neovim's leader
never shadows the multiplexer. (Details: [`.claude/rules/config.md`](../.claude/rules/config.md).)

**Where Claude Code lives:** in a Zellij pane next to Neovim — not an IDE sidebar. You edit on the
left, the agent works on the right, and you flick between them with the prefix.

---

## First five minutes

```sh
cd ~/my-project
zellij --layout dev        # opens the editor │ agent split (40% agent on the right)
```

- Left pane is a shell — type `nvim` to edit. Right pane — type `claude` to start the agent.
- **Switch panes:** `⌃a` then `h`/`l` (left/right). **New tab:** `⌃a c`. **Detach (leave it
  running):** `⌃a d` — reattach later with `zellij attach`.
- In Neovim, press **`<Space>`** and *wait* — a menu (which-key) shows every command. That's your
  discovery tool; you never need to memorize up front.

That's enough to be productive. The rest is muscle memory you'll build through the [flows](#user-flows).

---

## Cheat sheets

> Keys below are what this repo ships. Where a key is the tool's own default (not set by us) it's
> marked *(default)*. Full per-tool reference lives in each layer's README
> ([ghostty](../ghostty/README.md) · [zellij](../zellij/README.md) · [nvim](../nvim/README.md) ·
> [zsh](../zsh/README.md) · [claude](../claude/README.md)).

### Ghostty — terminal

| Keys | Action |
|---|---|
| `⌘⇧R` | Reload `ghostty/config` |
| <code>⌘&#96;</code> | Quick terminal (drop-down) from anywhere |
| `⌘=` / `⌘-` / `⌘0` | Font size up / down / reset *(default)* |
| `⌘C` / `⌘V` | Copy / paste *(default)* |

> Keep **one** Ghostty window — Zellij does the tabs and panes. `⌃a` is intentionally unbound here.

### Zellij — multiplexer

Press the **`⌃a`** prefix, release, then the key (tmux-style):

| Keys | Action |
|---|---|
| `⌃a` `c` | New tab |
| `⌃a` `"` / `⌃a` `%` | Split pane down / right |
| `⌃a` `h` `j` `k` `l` | Move focus between panes |
| `⌃a` `n` / `⌃a` `p` | Next / previous tab |
| `⌃a` `x` | Close the focused pane |
| `⌃a` `z` | Toggle fullscreen (zoom) a pane |
| `⌃a` `[` | Scroll / copy mode (then `q` to exit) |
| `⌃a` `d` | Detach the session (keeps running) |
| `⌃a` `⌃a` | Send a literal `⌃a` to the app |

From the shell (no prefix):

| Command | Action |
|---|---|
| `zellij --layout dev` | New session with the editor │ agent layout |
| `zellij attach` (or `za`) | Reattach the last session |
| `zellij ls` | List sessions |

> Zellij is modal and **shows its keys in the status bar** — when in doubt, look down. Its other
> default modes (`⌃p` pane, `⌃t` tab, `⌃n` resize, `⌃g` lock) still work alongside the `⌃a` prefix.

### Neovim + LazyVim — editor

Leader is **`<Space>`**. Press it and wait for **which-key**. The essentials (LazyVim defaults unless
noted; full list: <https://www.lazyvim.org/keymaps>):

| Keys | Action |
|---|---|
| `<Space>` (wait) | which-key menu — discover everything |
| `<Space>ff` / `<Space>fg` | Find **f**iles / live **g**rep (Telescope) |
| `<Space>fr` / `<Space>,` | Recent files / switch buffer |
| `<Space>e` | File explorer (neo-tree) |
| `<Space>gg` / `<Space>gb` | Lazygit / git blame |
| `gd` / `gr` / `gI` | LSP: definition / references / implementation |
| `K` | Hover docs · `<Space>ca` code action · `<Space>cr` rename |
| `]d` / `[d` | Next / previous diagnostic · `<Space>cd` line diagnostics |
| `⌃h` `⌃j` `⌃k` `⌃l` | Move between **editor** splits |
| `<Space>bd` / `<Space>qq` | Close buffer / quit |
| `jk` *(ours)* | Exit insert mode |
| `:Lazy` / `:Mason` | Plugin manager / LSP-server installer |

### Command line — zsh vi-mode + tools

**Vi editing** at the prompt ([zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode); classic
surround mode):

| Keys | Action |
|---|---|
| `Esc` | Normal mode (block cursor); `i` `a` `I` `A` `o` back to insert |
| `h` `l` · `w` `b` `e` | Char · word motions |
| `0` `^` `$` | Line start · first non-blank · end |
| `f{c}` `t{c}` · `;` `,` | Jump to / before a char on the line · repeat / reverse |
| `x` `r{c}` `~` | Delete char · replace char · toggle case |
| `dd` `cc` `D` `C` `s` | Delete line · change line · to end of line · substitute |
| `ciw` `ci"` `ci(` `dt/` | Change inner word / quotes / parens · delete up to `/` |
| `yy` `p` `P` | Yank line · paste after / before |
| `u` `⌃R` | Undo · redo |
| `v` `V` | Visual / visual-line select |
| `ys"` `cs"'` `ds"` | **Surround**: add `"` · change `"`→`'` · delete `"` |

**Navigation & history:**

| Keys / cmd | Action |
|---|---|
| `⌃R` | Fuzzy-search shell history (atuin) |
| `⌃T` | Pick a file path into the current command (fzf) |
| `⌥C` | `cd` into a fuzzy-picked subdir (fzf) |
| `vim **<Tab>` | fzf path completion — type `**` then `Tab` after any command |
| `z foo` / `z foo bar` / `zi` | Jump to a dir by frecency / by keywords / pick interactively (zoxide) |
| `cd -` | Back to the previous dir |
| `ll` `la` · `..` `...` | `ls -lah` / `ls -A` · up one / up two dirs |
| `gs` `gd` `gl` | git status / diff / log --graph (aliases) |
| `lg` · `y` | Open lazygit ([below](#lazygit--git-tui)) · yazi ([below](#yazi--file-manager)) |

**Search & find, the modern way** (real flags you'll reuse):

```sh
fd auth                 # find files/dirs whose name matches "auth" (fast, respects .gitignore)
fd -e ts -e tsx login   # only .ts/.tsx files matching "login"
fd -H -t d node_modules # include Hidden, only Directories named node_modules
rg "createUser"         # grep the repo for a string (ripgrep — fast, .gitignore-aware)
rg -n -t ts "TODO"      # line Numbers, only TypeScript files
rg -l "parseToken"      # just the file names that match
rg -o 'v\d+\.\d+'       # print Only the matched part (a regex)
atuin search -i         # full-screen history search (same engine as ⌃R)
```

### lazygit — git TUI

Launch with **`lg`** (alias) or **`<Space>gg`** in Neovim. Panels on the left, diff on the right.
`?` shows every key; `q` quits. (Keys are lazygit defaults — full list:
<https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md>.)

| Keys | Action |
|---|---|
| `1`–`5` · `Tab` · `h`/`l` | Jump to panel: status · files · branches · commits · stash |
| `↑`/`↓` or `k`/`j` | Move within a panel |
| **Files:** `<Space>` | Stage / unstage the selected file |
| `a` | Stage / unstage **all** |
| `<Enter>` | Drill into a file → stage **hunks / lines** |
| `c` · `C` · `A` | Commit · commit with `$EDITOR` · amend last commit |
| `d` · `s` / `S` | Discard / unstage · stash all / stash options |
| `p` · `P` | Pull · push |
| **Line-staging:** `<Space>` · `v` · `a` · `<Tab>` | Stage line · range-select · toggle hunk mode · switch staged/unstaged |
| **Branches:** `<Space>` · `n` · `c` · `-` | Checkout · new branch · checkout by name · previous branch |
| **Commits:** `s` · `f` · `r` · `d` · `e` | Squash · fixup · reword · drop · edit (interactive rebase) |
| `z` / `Z` | Undo / redo (via the reflog) |
| `?` · `q` | Keybindings menu · quit |

### yazi — file manager

Launch with **`y`** (alias). Vim-keyed. `q` quits; `~` or `?` shows help. (Keys are yazi defaults —
full keymap: <https://yazi-rs.github.io/docs/quick-start>.)

| Keys | Action |
|---|---|
| `h` `j` `k` `l` | Parent dir · down · up · enter dir / open file |
| `gg` / `G` · `⌃u` / `⌃d` | Top / bottom · half-page up / down |
| `<Space>` · `v` · `⌃a` · `⌃r` | Toggle-select file · visual select · select all · invert |
| `y` · `x` · `p` / `P` | Yank (copy) · cut · paste / paste-overwrite |
| `d` · `D` | Move to trash · delete permanently |
| `a` · `r` | Create (end with `/` for a dir) · rename |
| `.` | Toggle hidden files |
| `o` / `<Enter>` · `O` | Open · open-with (choose app) |
| `s` / `S` | Search by name (fd) / by content (ripgrep) |
| `z` / `Z` | Jump via fzf / via zoxide |
| `f` · `/` · `n` / `N` | Filter · find · next / previous match |
| `tt` · `1`–`9` · `[` / `]` | New tab · switch tab · previous / next tab |
| `;` / `:` | Run a shell command (`:` blocks until it finishes) |
| `q` · `<Esc>` | Quit · cancel / clear selection |

> **Tip:** to make `yazi` change your *shell's* directory on quit, use its `y` wrapper function from
> the docs instead of the bare alias — then `q` drops you in the folder you navigated to.

### Claude Code — agent

Runs in its own pane. The status line shows **model · dir · git · context% · cost**. Worktrees for
parallel agents (see [flow 5](#5-run-agents-in-parallel-worktrees)). The most-used in-app keys:

| Keys / prefix | Action |
|---|---|
| `⇧Tab` | Cycle permission mode (Normal → Auto-Accept → Plan) |
| `Esc` | Stop generating · `Esc Esc` rewind the conversation |
| `/` | Slash command (`/clear`, `/compact`, `/cost`, `/model`, `/resume`) |
| `!` / `@` | Run a bash command / autocomplete a file path |
| `⌃G` | Edit the prompt in `$EDITOR` (nvim) |

> Full Claude Code shortcut reference: [`claude/README.md`](../claude/README.md) and the upstream
> [keyboard shortcuts](https://code.claude.com/docs/en/interactive-mode).

---

## User flows

Concrete walkthroughs. Each is "the situation → the moves".

### 1. Start a project session
*You sit down to work on `~/code/api`.*

```sh
cd ~/code/api
zellij --layout dev          # editor │ agent split, named after the dir
```
- Left pane: `nvim` → you're editing. Right pane: `claude` → the agent is ready.
- Need a third pane for tests/logs? `⌃a "` splits the current pane downward; run `npm test --watch`
  there.
- Lunch? `⌃a d` detaches — everything keeps running. Back later: `zellij attach`.

**Why this way:** one session = one project. Tabs are sub-tasks; panes are editor/agent/runner. You
never lose context, and a reboot-free week of work lives in detached sessions.

### 2. Find and edit code
*You need to change how `createUser` validates email.*

1. In Neovim: `<Space>fg` → type `createUser` → Enter on the hit (live grep across the repo).
2. Land on the function. `gd` jumps to a symbol's definition; `gr` shows everywhere it's used.
3. Edit with Vim motions (`ci(` to replace args, `cit` inside a tag, `<Space>cr` to LSP-rename the
   symbol everywhere).
4. `K` for hover docs, `]d` to hop to the next error, `<Space>ca` to apply a quick-fix.
5. `<Space>ff` to open a sibling file by name; `⌃h`/`⌃l` to move between editor splits.

**Why this way:** Telescope (`<Space>ff`/`fg`) replaces the JetBrains "search everywhere"; the LSP
keys (`gd`/`gr`/`cr`) replace "go to / find usages / rename". Hands stay on the home row.

### 3. Pair with Claude Code
*You want the agent to implement a function while you keep reading code.*

1. `⌃a l` → focus the Claude pane. Describe the task (`@` to attach a file path, `!` to run a quick
   bash check inline).
2. `⌃a h` → back to Neovim; keep navigating while it works. The status line shows context % so you
   know when to `/compact`.
3. When it edits files, Neovim shows the changes (`:e` to reload, or it auto-reloads); review with
   `gd`/`<Space>gg`.
4. Big task with many parallel pieces? Hand it off to a worktree → [flow 5](#5-run-agents-in-parallel-worktrees).

**Why this way:** the agent and the editor are *peers in adjacent panes* — lower RAM and a tighter
loop than an embedded IDE agent, and you stay in control of the diff. Enabling
[`zellij-autolock`](../zellij/README.md#autolock-opt-in--seamless-editoragent-passthrough) makes the
hand-off seamless (no manual locking when a pane has nvim/claude focused).

### 4. Git, the fast way
*You're ready to review and commit.*

- Quick status: `gs` (alias) in any shell pane.
- Full TUI: `lg` (or `<Space>gg` inside Neovim) → **lazygit**. Stage hunks with `Space`, commit with
  `c`, push with `P`, browse branches with `b`. It's the fastest staging UI there is.
- Per-line history: `<Space>gb` (git blame) in Neovim.

**Why this way:** lazygit turns "stage exactly these hunks, write a message, push" into a few
keystrokes without leaving the terminal; `<Space>gg` opens it docked to the file you're on.

### 5. Run agents in parallel (worktrees)
*Two independent tasks; you want an agent on each without them colliding.*

```sh
cc-worktree feat/email-validation     # makes ../api-feat-email-validation + a Zellij session
cc-worktree fix/rate-limit origin/main
```
- Each command creates a **git worktree** (a separate checkout of the same repo on its own branch)
  and opens a `dev`-layout Zellij session in it. Run a `claude` in each — they never step on each
  other's files.
- Bounce between them with `⌃a` `p`/`n` (tabs) or `zellij attach <name>`.

**Why this way:** worktrees give each agent an isolated working tree, so "two features at once" is
real parallelism, not branch-switch thrashing. (See [`claude/README.md`](../claude/README.md).)

### 6. Move around (history, dirs, files)
*You need that `docker run …` from yesterday and a deeply-nested folder.*

- **History:** `⌃R` → fuzzy-search every command you've run (atuin), even across machines if you sync.
- **Jump dirs:** `z api` → teleport to `~/code/api` (zoxide ranks by frecency); `zi` to pick from a
  list.
- **Fuzzy file → command:** `⌃T` drops a picked path into the current command; `⌥C` `cd`s into a
  fuzzy-picked subdir.
- **Browse visually:** `y` → **Yazi**, a Vim-keyed file manager (`h/j/k/l` to navigate, `Enter` to
  open, `q` to quit back to the shell).

**Why this way:** `z` + `⌃R` kill 90% of `cd ../../..` and re-typing long commands. Everything is a
fuzzy search away.

### 7. Edit a long command (vi-mode)
*You typed a 200-char `ffmpeg`/`curl` line and need to fix a flag in the middle.*

1. `Esc` → normal mode (the cursor block tells you).
2. `b`/`w` to hop by word, `0`/`$` to jump to start/end, `ci"` to replace a quoted value, `cs'"` to
   swap quote style.
3. `i`/`a` back to insert, or just `Enter` to run.

**Why this way:** the command line now has the *same* modal editing as Neovim — no reaching for arrow
keys or `⌃A`/`⌃E` emacs chords. One editing model everywhere. (See [`zsh/README.md`](../zsh/README.md).)

### 8. Tweak and reload a config
*You want a different Ghostty opacity / a new nvim plugin / a new alias.*

- **Ghostty:** edit `~/.config/ghostty/config` → `⌘⇧R` to reload. Validate: `ghostty +show-config`.
- **Neovim:** add a spec under `nvim/lua/plugins/` → `:Lazy sync`. Validate: `nvim --headless +qa`.
- **Shell:** edit `zsh/aliases.zsh` → `source ~/.zshrc` (or new shell). Validate: `zsh -n`.
- **Anything:** `make check` runs every validator at once (and it's what CI runs).

**Why this way:** the repo *is* the config (symlinks), so an edit is live immediately; `git pull` +
`./install.sh --prune` syncs a new machine, `make update` upgrades the tools. Each change should still
pass `/check`.

---

## A day in the life

> `⌘⇧R`-fresh terminal. `z api` → `zellij --layout dev`. Left: `nvim`. Right: `claude`.
>
> `<Space>fg` "parseToken" → land in the auth module, `gd` into the helper, spot the bug. `⌃a l` →
> tell Claude "write a failing test for an expired token, then fix `parseToken`". `⌃a h` → back to
> nvim, keep reading while it works; the statusline ticks to *31% ctx*.
>
> It's done. `<Space>gg` → lazygit, stage the two files (`Space`), commit (`c`), and — because a
> second idea struck — `cc-worktree feat/refresh-rotation` spins a parallel session to chase it
> later. `⌃a d`, close the laptop. Nothing lost.

That's the loop: **navigate by search, edit by motion, delegate to the pane next door, commit in
seconds, detach without fear.**

---

## Ergonomic principles

The *why* behind the combos — the reasons this stack is fast once it's yours:

- **One prefix per layer.** `⌘` = terminal, `⌃a` = multiplexer, `<Space>` = editor. Your hands always
  know who's listening; nothing overlaps.
- **Search, don't browse.** `<Space>ff`/`fg`, `⌃R`, `z`, lazygit — reaching a file / command / commit
  is a fuzzy query, not a click-path. Fewer keystrokes, no mouse.
- **Stay on the home row.** Vim motions in the editor *and* the shell (vi-mode) mean you almost never
  reach for arrows or the mouse — less travel, less strain.
- **Modal discovery beats memorization.** which-key (`<Space>`) and the Zellij status bar *show* you
  the next key, so you learn by using, not by studying.
- **Panes are peers.** Editor and agent sit side by side; switching is one chord, and the work in each
  is independent (and parallel, via worktrees).
- **Detach, don't lose.** Sessions outlive the window. Close the lid mid-task; `zellij attach` and
  you're exactly where you were.
- **One palette, low friction.** Catppuccin Mocha across every layer — less visual context-switching
  when your eyes jump pane to pane.

---

## Reload & troubleshoot

| Symptom / want | Do this |
|---|---|
| Changed Ghostty config, no effect | `⌘⇧R` (reload), or restart Ghostty for font changes |
| Changed an nvim plugin spec | `:Lazy sync` (or restart nvim) |
| Changed a shell file | `source ~/.zshrc` or open a new shell |
| "Does my config even load?" | `make check` (all validators) — or per-tool, see below |
| A keybind seems dead | check the layer: is a `⌃a`-prefix key being eaten by the app? `⌃a ⌃a` sends a literal `⌃a` |
| fzf/atuin `⌃R` stopped working | vi-mode must load *before* them — it does in `zsh/.zshrc`; check your `~/.zshrc.local` overrides |
| New machine / new files added | `git pull && ./install.sh --prune` |
| Update all the tools | `make update` (then `:Lazy update` + commit `lazy-lock.json`) |

| Validator | Proves |
|---|---|
| `ghostty +show-config` | Ghostty config parses |
| `zellij --config zellij/config.kdl setup --check` | Zellij config loads |
| `nvim --headless +qa` | Neovim + plugins load |
| `zsh -n <file>` | a shell file is syntactically valid |

---

## Further reading

### Official docs — the authoritative reference per tool

When the cheat sheet isn't enough, go to the source (and remember the repo rule: **never invent a
config key — cite these**).

| Layer / tool | Docs | Reach for it when |
|---|---|---|
| **Ghostty** | <https://ghostty.org/docs> · [config ref](https://ghostty.org/docs/config/reference) · [keybinds](https://ghostty.org/docs/config/keybind/reference) | a new key, a theme, font/cursor options |
| **Zellij** | <https://zellij.dev/documentation> | layouts, keybindings, plugins, options |
| **Neovim** | <https://neovim.io/doc/> · in-editor `:help` | core editor, Lua API, `:help lua-guide` |
| **LazyVim** | <https://www.lazyvim.org> · [keymaps](https://www.lazyvim.org/keymaps) · [extras](https://www.lazyvim.org/extras) | enabling language/feature extras, default keys |
| **lazy.nvim** | <https://github.com/folke/lazy.nvim> | the plugin-spec format, lazy-loading |
| **Starship** | <https://starship.rs/config> | prompt modules, palettes, format strings |
| **zsh-vi-mode** | <https://github.com/jeffreytse/zsh-vi-mode> | ZVM options, surround, `zvm_after_init` |
| **zoxide** | <https://github.com/ajeetdsouza/zoxide> | `z`/`zi` usage, init flags |
| **atuin** | <https://docs.atuin.sh> | history search, optional sync, key bindings |
| **fzf** | <https://github.com/junegunn/fzf> | shell integration, `FZF_DEFAULT_*` env, previews |
| **lazygit** | <https://github.com/jesseduffield/lazygit> | staging/rebase keys, custom commands |
| **yazi** | <https://yazi-rs.github.io> | the file-manager keymap + plugins |
| **Claude Code** | <https://code.claude.com/docs> · [interactive mode](https://code.claude.com/docs/en/interactive-mode) · [statusline](https://code.claude.com/docs/en/statusline) | slash commands, shortcuts, settings, hooks |
| **Homebrew** | <https://brew.sh> · [bundle](https://github.com/Homebrew/homebrew-bundle) | the package manager + `brew bundle` |
| **Catppuccin** | <https://catppuccin.com> | the shared palette + ports for other apps |

### Video intros (community)

Optional, for learning passively — **community-made, so quality and recency vary** (the official docs
above stay the source of truth). Pick one that fits; skim, don't memorize.

- **Neovim / LazyVim**
  - [Zero to IDE with LazyVim](https://www.youtube.com/watch?v=N93cTbtLCIM) — getting started from the starter.
  - [typecraft — configure Neovim, complete tutorial](https://www.youtube.com/watch?v=J9yqSdvAKXY) — how the config fits together.
  - [How I set up Neovim to make it amazing (2024 guide)](https://www.youtube.com/watch?v=6pAG3BHurdM) — a from-scratch walkthrough.
- **Zellij**
  - [Master terminal multiplexing with Zellij in minutes](https://www.youtube.com/watch?v=ZndhImXIGlg) — the core model fast.
  - [Is Zellij the perfect multiplexer? (vs tmux)](https://www.youtube.com/watch?v=BjfMWqy1hnw) — why Zellij, compared to tmux.

> Searching YouTube for "**LazyVim 2026**", "**Zellij workflow**", or "**Neovim Claude Code**" surfaces
> fresher material than any fixed link — treat the above as a starting point.

### Going deeper in this repo

- Per-layer references: [ghostty](../ghostty/README.md) · [zellij](../zellij/README.md) ·
  [nvim](../nvim/README.md) · [zsh](../zsh/README.md) · [claude](../claude/README.md) ·
  [fonts](../fonts/README.md)
- Setup + ops: [install](install.md) · [sandbox](sandbox.md)
- How the repo is built (the SDD loop + commands): [`.claude/commands/README.md`](../.claude/commands/README.md)

---

<div align="center">
<sub>Built keyboard-first. When in doubt: <code>&lt;Space&gt;</code> in the editor, look at the Zellij
status bar in the multiplexer, and <code>make check</code> when something won't load.</sub>
</div>
