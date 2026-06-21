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

**Vi editing** at the prompt (zsh-vi-mode):

| Keys | Action |
|---|---|
| `Esc` | Normal mode (then `i`/`a`/`I`/`A` back to insert, `v` visual) |
| `b` `w` `0` `$` | Word back / forward, line start / end |
| `ci"` `daw` `dd` | Change-in-quotes, delete-a-word, delete line |
| `S"` `cs'"` `ds(` | Surround: add / change / delete |

**Navigation & tools:**

| Keys / cmd | Action |
|---|---|
| `⌃R` | Search shell history (atuin) |
| `⌃T` | Insert a file path (fzf) |
| `⌥C` | `cd` into a fuzzy-picked dir (fzf) |
| `z <part-of-dir>` | Jump to a dir by frecency (zoxide) · `zi` to pick |
| `ll` / `la` | `ls -lah` / `ls -A` |
| `gs` / `gd` / `gl` | git status / diff / log-graph |
| `lg` | Lazygit (full git TUI) · `y` Yazi (file manager) |

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

<div align="center">
<sub>Built keyboard-first. When in doubt: <code>&lt;Space&gt;</code> in the editor, look at the Zellij
status bar in the multiplexer, and <code>make check</code> when something won't load.</sub>
</div>
