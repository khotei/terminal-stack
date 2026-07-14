# 📖 The developer's guide to terminal-stack

How the five layers combine into **one** workflow — the mental model, how the tools are wired to each
other, and the moves a developer makes to get real work done. Read it top-to-bottom once to get
oriented; come back to the [scenarios](#user-flows) and the
[essential-moves table](#the-essential-moves--and-where-the-full-keys-live) to remember a combo. The
**exhaustive keys for each layer live in that layer's own README** — this guide is the cross-tool story
that ties them together, not a key dump.

> **New here?** Install with [`docs/install.md`](install.md) (or `make try` for a no-install Docker
> sandbox of the in-terminal layers), then start at [First five minutes](#first-five-minutes).

---

## Contents

1. [The mental model](#the-mental-model)
2. [First five minutes](#first-five-minutes)
3. [How the tools work together](#how-the-tools-work-together) — the wiring + the essential-moves table
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
│ ┌─ Zellij ───────────────────────────────────────────┐ │   sessions · tabs · panes  (modal · ⌃p ⌃t …)
│ │ ┌─ pane: Neovim ─────────┐ ┌─ pane: Claude Code ──┐ │ │   edit  ││  the agent
│ │ │  <Space> leader        │ │  statusline, /cmds   │ │ │
│ │ │  LSP · snacks · git    │ │  cc-worktree         │ │ │
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
| **Zellij** | sessions, tabs, panes | **`⌃p`/`⌃t`/…** mode key, then a key (or `⌥`-direct) |
| **Neovim** | editor motions, LSP, plugins | **`<Space>`** leader, then a key |

So your fingers always know *which tool they're talking to*: a `⌃`-mode key means "multiplexer", a bare
`<Space>` in the editor means "editor command". Ghostty deliberately leaves the `⌃` keys free; Neovim's
leader never shadows the multiplexer. When a full-screen app (nvim/claude) needs *every* key, press
[`⌥d`](../zellij/README.md#8-living-with-claude-code--neovim--manual-lock) to **lock** Zellij and hand it
over — `⌥d` again to reach the multiplexer. (Details:
[`.claude/rules/config.md`](../.claude/rules/config.md).)

**Where Claude Code lives:** in a Zellij pane next to Neovim — not an IDE sidebar. You edit on the
left, the agent works on the right, and you flick between them with `⌥h`/`⌥l`.

---

## First five minutes

```sh
cd ~/my-project
zellij --layout dev        # opens the editor │ agent split (40% agent on the right) — alias: zjd
```

- Both panes **start as shells** (the layout doesn't auto-launch the apps — so a fresh prompt is
  expected, not a failure). Left pane — type `nvim` to edit. Right pane — type `claude` to start the
  agent.
- **Switch panes:** `⌥h`/`⌥l` (Alt, left/right). **New tab:** `⌃t` then `n`. **Detach (leave it
  running):** `⌃o` then `d` — reattach later with `zellij attach` (alias `zja`).
- In Neovim, press **`<Space>`** and *wait* — a menu (which-key) shows every command. That's your
  discovery tool; you never need to memorize up front.

That's enough to be productive. The rest is muscle memory you'll build through the [flows](#user-flows).

> **Tune macOS for this workflow (optional):** `make macos` applies opinionated system defaults
> (Dock auto-hide, fast Vim key-repeat, …) — opt-in, not run by install. See
> [macos/README.md](../macos/README.md).

---

## How the tools work together

The five layers aren't just stacked — they're *wired*, so one mental model carries across all of them.
This is the synthesis; the exhaustive, upstream-cited keys for any layer live in **its own README**
(linked in the table below — that is now the single source per tool).

**1. One keyboard contract, no collisions.** `⌘` talks to Ghostty, a `⌃`-mode key to Zellij, `<Space>`
to Neovim — the contract from [the mental model](#the-mental-model). Nothing overlaps, so your fingers
always know who's listening.

**2. Keys flow OS → terminal → multiplexer → app.** Ghostty's `macos-option-as-alt` turns the Mac's
Option into a real Alt, so Zellij's `⌥h`/`⌥l` and Claude's `⌥P`/`⌥T` actually arrive. When a pane needs
*every* key for a full-screen app (nvim/claude/fzf/atuin), press
[`⌥d`](../zellij/README.md#8-living-with-claude-code--neovim--manual-lock) to **lock** Zellij and hand that
app the keyboard — `⌥d` again to return. There's no autolock: you lock by hand, so until you do, the
app's own Ctrl-keys can be caught by Zellij. `⌃g` stays free so Claude Code's "edit prompt in
`$EDITOR`" reaches Claude even while locked.

**3. One editing model everywhere.** Vim motions in Neovim, the *same* motions on the zsh prompt
(vi-mode), and again inside Claude Code (`editorMode: vim`, plus `⌃G` to edit a prompt in nvim itself).
Learn `ciw`/`ci"`/`b`/`w`/`cs"'` once; use them in the editor, the shell, and the agent's prompt box.

**4. A session is a project, and it outlives the window.** `cd ~/proj && zjd` opens the editor │ agent
split; `⌃o` `d` detaches with builds and agents still running; `zja` drops you back exactly where you
were — even after a reboot, via [resurrection](../zellij/README.md#5-sessions-are-workspaces). For two
features at once, a **worktree per agent** ([flow 5](#5-run-agents-in-parallel-worktrees)).

**5. The editor │ agent loop.** Navigate on the left (Neovim: `<Space>fg` search, `gd`/`gr` LSP),
delegate on the right (Claude: `@file`, `!cmd`), review the diff back in the editor (`<Space>gg`
lazygit). Switch sides with `⌥h`/`⌥l`. Peers in adjacent panes — lower RAM, tighter loop, you keep hold
of the diff.

**6. One palette, one theme signal.** Every layer runs the *same* palette and follows the macOS
light/dark appearance in lockstep: Ghostty repaints, and Zellij / Neovim / Starship / Claude Code track
it — so your eye doesn't hitch jumping pane to pane. Change one appearance setting, the whole stack
turns with it. *Which* palette isn't wired in anywhere but the config: swap the `theme` in
[`ghostty/config`](../ghostty/config) (mirror it in Zellij + Neovim), or just ask Claude Code to
re-theme the stack — the docs stay the same whatever palette you pick.

**7. The CLI mesh.** `fd` + `ripgrep` power Neovim's file/grep pickers *and* the shell; `fzf` + `atuin`
+ `zoxide` make history, paths, and directories a fuzzy query away; `lazygit` and `yazi` are the git
and file TUIs both the shell (`lg` / `y`) and Neovim (`<Space>gg`) reach for. Everything is a search,
not a click-path.

### The essential moves — and where the full keys live

The top combos per layer — the "remember the ergonomic move" table. For the exhaustive, upstream-cited
reference of any layer, open its README.

| Layer | The moves you'll reach for most | Full reference |
|---|---|---|
| **Ghostty** | `⌘⇧R` reload · <code>⌘&#96;</code> quick-terminal | [ghostty/README](../ghostty/README.md) |
| **Zellij** | `⌥h`/`⌥l` pane+tab · `⌃t` `N` jump to tab · `⌃o` `w` sessions · `⌥d` lock/unlock | [zellij/README](../zellij/README.md) |
| **Neovim** | `<Space>` which-key · `<Space>ff`/`fg` find/grep · `gd`/`gr`/`K` LSP · `<Space>gg` lazygit | [nvim/README](../nvim/README.md) |
| **Shell** | `z` jump · `⌃R` history · `⌃T` file · `Esc` vi-mode · `zjd` workspace | [zsh/README](../zsh/README.md) |
| **lazygit** | `Space` stage · `c` commit · `P` push · `s`/`f`/`r` squash/fixup/reword | [zsh/README §lazygit](../zsh/README.md#512-lazygit--git-as-a-tui) |
| **yazi** | `h`/`j`/`k`/`l` nav · `y`/`x`/`p` copy/cut/paste · `z` fzf-jump | [zsh/README §yazi](../zsh/README.md#513-yazi--a-tui-file-manager) |
| **Claude Code** | `⇧Tab` mode · `@`/`!`/`/` sigils · `⌃G` edit in nvim · `Esc` interrupt | [claude/README](../claude/README.md) |

---

## User flows

Concrete walkthroughs. Each is "the situation → the moves".

### 1. Start a project session
*You sit down to work on `~/code/api`.*

```sh
cd ~/code/api
zellij --layout dev          # editor │ agent split, named after the dir (alias: zjd)
```
- Left pane: `nvim` → you're editing. Right pane: `claude` → the agent is ready.
- Need a third pane for tests/logs? `⌃p` then `d` splits the current pane downward; run
  `npm test --watch` there.
- Lunch? `⌃o` then `d` detaches — everything keeps running. Back later: `zellij attach` (`zja`).

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

**Why this way:** The snacks picker (`<Space>ff`/`fg`) replaces the JetBrains "search everywhere"; the LSP
keys (`gd`/`gr`/`cr`) replace "go to / find usages / rename". Hands stay on the home row.

### 3. Pair with Claude Code
*You want the agent to implement a function while you keep reading code.*

1. `⌥l` → focus the Claude pane. Describe the task (`@` to attach a file path, `!` to run a quick
   bash check inline).
2. `⌥h` → back to Neovim; keep navigating while it works. The status line shows context % so you
   know when to `/compact`.
3. When it edits files, Neovim shows the changes (`:e` to reload, or it auto-reloads); review with
   `gd`/`<Space>gg`.
4. Big task with many parallel pieces? Hand it off to a worktree → [flow 5](#5-run-agents-in-parallel-worktrees).

**Why this way:** the agent and the editor are *peers in adjacent panes* — lower RAM and a tighter
loop than an embedded IDE agent, and you stay in control of the diff. When you want the pane to swallow
*every* key — Claude's own `Ctrl`-shortcuts, or nvim's — press
[`⌥d`](../zellij/README.md#8-living-with-claude-code--neovim--manual-lock) to **lock** Zellij, and `⌥d`
again to hand the multiplexer back. It's a manual toggle (no autolock), so until you press it Zellij
may catch the app's Ctrl-keys.

### 4. Git, the fast way
*You're ready to review and commit.*

- Quick status: `gs` (alias) in any shell pane.
- Full TUI: `lg` (or `<Space>gg` inside Neovim) → **lazygit**. Stage hunks with `Space`, commit with
  `c`, push with `P`, rebase interactively with `s`/`f`/`r`. It's the fastest staging UI there is.
- Per-line history: `<Space>gb` (git blame) in Neovim.
- Plain `git diff` / `git show` now flow through **delta** — pretty, line-numbered diffs; `n`/`N` move
  between hunks. Wired by the **additive** `~/.config/git/config` (it never touches your `~/.gitconfig`
  identity — see [`git/README.md`](../git/README.md)).

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
- Bounce between them with `⌃t` then `h`/`l` (tabs) or `zellij attach <name>`.
- **Merge back** by pushing each branch and opening a PR per branch — the squash-merge reunites them
  ([`pull-requests.md`](../.claude/rules/pull-requests.md)).

**Why this way:** worktrees give each agent an isolated working tree, so "two features at once" is
real parallelism, not branch-switch thrashing. The full model — *why* a shared tree collides, when to
split by file instead, native `claude --worktree`, and the merge-back — is
[`docs/parallel-agents.md`](parallel-agents.md).

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
2. `b`/`w` to hop by word, `0`/`$` to jump to start/end, `ci"` to replace a quoted value, `cs"'` to
   swap the quote style.
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
> `<Space>fg` "parseToken" → land in the auth module, `gd` into the helper, spot the bug. `⌥l` →
> tell Claude "write a failing test for an expired token, then fix `parseToken`". `⌥h` → back to
> nvim, keep reading while it works; the statusline ticks to *31% ctx*.
>
> It's done. `<Space>gg` → lazygit, stage the two files (`Space`), commit (`c`), and — because a
> second idea struck — `cc-worktree feat/refresh-rotation` spins a parallel session to chase it
> later. `⌃o` then `d`, close the laptop. Nothing lost.

That's the loop: **navigate by search, edit by motion, delegate to the pane next door, commit in
seconds, detach without fear.**

---

## Ergonomic principles

The *why* behind the combos — the reasons this stack is fast once it's yours:

- **One entry per layer.** `⌘` = terminal, `⌃`-mode keys = multiplexer, `<Space>` = editor. Your hands
  always know who's listening; nothing overlaps.
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
- **One palette, low friction.** One shared palette across every layer — its light variant in light,
  dark in dark, following the macOS appearance in lockstep — so there's less visual context-switching
  when your eyes jump pane to pane.

---

## Reload & troubleshoot

| Symptom / want | Do this |
|---|---|
| "Is my setup healthy?" | `make doctor` — checks tools, symlinks, fonts, `$PATH` (read-only) |
| Changed Ghostty config, no effect | `⌘⇧R` (reload), or restart Ghostty for font changes |
| Changed an nvim plugin spec | `:Lazy sync` (or restart nvim) |
| Changed a shell file | `source ~/.zshrc` or open a new shell |
| "Does my config even load?" | `make check` (all validators) — or per-tool, see below |
| A keybind seems dead | check the layer. A Zellij key dead? The pane may be **locked** — `⌥d` to unlock. An app's own Ctrl-key dead? The pane is **not** locked — `⌥d` to lock so the app gets it |
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

When the per-tool README isn't enough, go to the source (and remember the repo rule: **never invent a
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
| **Terminal theme** | `ghostty +list-themes` · [ghostty themes](https://ghostty.org/docs/config/reference#theme) | the palette every layer follows — named in `ghostty/config`, mirrored in Zellij & Neovim |

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

- Per-layer references (the single source of keys per tool): [ghostty](../ghostty/README.md) ·
  [zellij](../zellij/README.md) · [nvim](../nvim/README.md) · [zsh](../zsh/README.md) ·
  [claude](../claude/README.md) · [fonts](../fonts/README.md)
- Setup + ops: [install](install.md) · [sandbox](sandbox.md)
- Running many agents at once: [parallel-agents](parallel-agents.md)
- Coming from an IDE: [JetBrains → stack map](jetbrains-to-stack-review.md)
- How the repo is built (the SDD loop + commands): [`.claude/commands/README.md`](../.claude/commands/README.md)

---

<div align="center">
<sub>Built keyboard-first. When in doubt: <code>&lt;Space&gt;</code> in the editor, look at the Zellij
status bar in the multiplexer, and <code>make check</code> when something won't load.</sub>
</div>
