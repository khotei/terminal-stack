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
leader never shadows the multiplexer. And when the editor/agent is focused, [autolock](../zellij/README.md#autolock)
hands it *every* key — press `⌥z` to reach Zellij again. (Details: [`.claude/rules/config.md`](../.claude/rules/config.md).)

**Where Claude Code lives:** in a Zellij pane next to Neovim — not an IDE sidebar. You edit on the
left, the agent works on the right, and you flick between them with `⌥h`/`⌥l`.

---

## First five minutes

```sh
cd ~/my-project
zellij --layout dev        # opens the editor │ agent split (40% agent on the right)
```

- Both panes **start as shells** (the layout doesn't auto-launch the apps — so a fresh prompt is
  expected, not a failure). Left pane — type `nvim` to edit. Right pane — type `claude` to start the
  agent.
- **Switch panes:** `⌥h`/`⌥l` (Alt, left/right). **New tab:** `⌃t` then `n`. **Detach (leave it
  running):** `⌃o` then `d` — reattach later with `zellij attach`.
- In Neovim, press **`<Space>`** and *wait* — a menu (which-key) shows every command. That's your
  discovery tool; you never need to memorize up front.

That's enough to be productive. The rest is muscle memory you'll build through the [flows](#user-flows).

> **Tune macOS for this workflow (optional):** `make macos` applies opinionated system defaults
> (Dock auto-hide, fast Vim key-repeat, …) — opt-in, not run by install. See
> [macos/README.md](../macos/README.md).

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

> Keep **one** Ghostty window — Zellij does the tabs and panes. Zellij's `⌃` mode keys are
> intentionally unbound here.

### Zellij — multiplexer

Zellij is **modal**, not prefix-based: press a **mode key**, act with plain keys, then `Enter`/`Esc`
to leave. For the everyday moves, hold **`⌥` (Alt)** and skip the mode entirely:

| Keys | Action |
|---|---|
| `⌥h` `⌥j` `⌥k` `⌥l` | Move focus between panes (`⌥h`/`⌥l` cross into adjacent tabs) |
| `⌥n` / `⌥f` | New pane / floating pane (the "popup" window) |
| `⌃p` then `n` · `d` · `r` | Pane mode → new · split down · split right |
| `⌃p` then `x` · `f` | Close pane · fullscreen (zoom) |
| `⌃t` then `n` · `1`…`9` | Tab mode → new tab · jump to tab N |
| `⌃t` then `h`/`l` | Previous / next tab |
| `⌃s` | Scroll / search mode (`e` edits scrollback in nvim · `Esc` exits) |
| `⌃o` then `w` · `d` | Session mode → session manager (fuzzy switch) · detach |
| `⌥z` | Drop a **locked** (editor/agent) pane back to full Zellij |

From the shell (no mode):

| Command | Action |
|---|---|
| `zellij --layout dev` | New session with the editor │ agent layout |
| `zellij attach` (or `za`) | Reattach the last session |
| `zellij ls` | List sessions |
| `zellij setup --dump-config` | Print **every** default keybind (the full list) |

> **Seeing the keys:** Zellij **shows the active mode's keys in the status bar** — enter a mode (`⌃p`,
> `⌃t`, …) and read the bar. There's no single "all hotkeys" popup; for the exhaustive list use
> `zellij setup --dump-config`. Locking is automatic ([autolock](../zellij/README.md#autolock)) so
> editor/agent panes get every key; `⌥z` gets you back.

### Neovim + LazyVim — editor

Leader is **`<Space>`**. Press it and wait for **which-key**. The essentials (LazyVim defaults unless
noted; full list: <https://www.lazyvim.org/keymaps>):

| Keys | Action |
|---|---|
| `<Space>` (wait) | which-key menu — discover everything |
| `<Space>ff` / `<Space>fg` | Find **f**iles / live **g**rep (snacks picker) |
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
| `z foo` / `z foo bar` / `zi` | Jump to a dir by frecency (frequency + recency) / by keywords / pick interactively (zoxide) |
| `cd -` | Back to the previous dir |
| `ll` `la` `lt` · `..` `...` | **eza** long+icons+git / all / tree · up one / up two dirs |
| `man <cmd>` | Syntax-coloured man page (**bat** is the `MANPAGER`; `cat` is *not* aliased) |
| `gs` `gd` `gl` | git status / diff / log --graph (aliases) |
| `lg` · `y` | Open lazygit ([below](#lazygit--git-tui)) · yazi ([below](#yazi--file-manager)) |

**Power-ups** (load last, from `zsh/plugins.zsh`):

| Feature | What it does |
|---|---|
| Autosuggestions | A grey suggestion from history appears as you type — `→` (right-arrow) accepts it |
| Syntax-highlighting | The command line is coloured live as you type (valid command = green, bad = red) |
| fzf-tab | `Tab` completion becomes a fuzzy fzf picker — type, filter, Enter |

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

Runs in its own pane; the status line shows **model · dir · git · context% · cost**. Keys/flags below
are from the official docs — [CLI](https://code.claude.com/docs/en/cli-reference) ·
[commands](https://code.claude.com/docs/en/commands) ·
[interactive mode](https://code.claude.com/docs/en/interactive-mode).

**Start & resume (from the shell):**

| Command | Action |
|---|---|
| `claude` | Start an interactive session |
| `claude "fix the login bug"` | Start with an initial prompt |
| `claude -c` (`--continue`) | Continue the most recent conversation |
| `claude -r` (`--resume`) | Pick a past session to resume |
| `claude -p "…"` (`--print`) | Print mode — non-interactive, for pipes/scripts |
| `cat err.log \| claude -p "explain"` | Pipe content into a one-shot query |
| `claude --model <name>` | Start on a specific model (see `/model` or the CLI docs for current ids) |
| `claude --add-dir ../lib` | Add extra working directories to the session |
| `claude mcp` | Manage MCP servers |

**In-session shortcuts:**

| Keys | Action |
|---|---|
| `Esc` | Interrupt Claude mid-turn (keeps the work so far) |
| `Esc` `Esc` | Clear the input draft, or — when empty — open the **rewind** menu |
| `⇧Tab` | Cycle permission mode (`default` → `acceptEdits` → `plan` → …) |
| `⌃O` | Toggle the transcript viewer (full tool output) |
| `⌃R` | Reverse-search input history (`⌃S` cycles scope) |
| `⌃B` | Background the running bash command / agent |
| `⌃T` | Toggle the task list |
| `⌃G` | Edit the prompt in `$EDITOR` (**nvim**) |
| `⌥P` / `⌥T` / `⌥O` | Switch model / toggle extended thinking / toggle fast mode |
| `⇧⏎` or `\`+`⏎` | New line (multiline input) |
| `⌃V` | Paste an image from the clipboard |
| `⌃C` / `⌃D` | Interrupt or clear input / exit the session |

**Quick prefixes (start of the line):**

| Prefix | Action |
|---|---|
| `/` | Slash command or skill |
| `!` | Shell mode — run a command, add its output to the context |
| `@` | Mention a file path (autocomplete) |
| `#` | Add a line to `CLAUDE.md` memory |

**Useful slash commands** (type `/` to see all):

| Command | Action |
|---|---|
| `/init` · `/memory` | Generate a starter `CLAUDE.md` · edit memory files |
| `/clear` · `/compact` · `/context` | New session · summarize context down · show where the window is spent |
| `/cost` · `/model` · `/effort` | Token cost · switch model · adjust reasoning effort |
| `/plan` | Enter plan mode before a big change |
| `/agents` · `/tasks` | Manage subagents · list background tasks |
| `/review` · `/security-review` | Review a PR · security review |
| `/resume` · `/rewind` | Resume a session · rewind to a checkpoint |
| `/mcp` · `/permissions` | Manage MCP servers · approval rules |
| `/vim` · `/terminal-setup` · `/keybindings` | Toggle vim editing · install `Shift+Enter` · edit keybindings |
| `/config` · `/statusline` · `/help` | Settings · status line · list everything |

> **Vim editing in the prompt:** enable via `/config` → *Editor mode* for `Esc`/`i`/`a`, `hjkl`, `dw`,
> `ciw`, text objects — the same modal model as Neovim and the zsh prompt.

**How the stack already smooths Claude Code:**

- **`⇧⏎` just works** — Ghostty is one of the terminals with native `Shift+Enter`, so multiline needs
  no `/terminal-setup`.
- **`⌃G` opens Neovim** — `$EDITOR=nvim` (set in `zsh/env.zsh`), so long prompts get full Vim editing.
- **Option shortcuts work** — `ghostty/config` sets `macos-option-as-alt`, which is exactly what
  `⌥P`/`⌥T`/`⌥O` need on macOS.
- **The PR badge is live** — `gh` (in the Brewfile) powers Claude Code's clickable PR status in the
  footer.
- **No key clash** — [autolock](../zellij/README.md#autolock) locks the agent pane, so Claude's
  `⌃O`/`⌃T`/`⌃B` reach it untouched; Zellij's `⌃G` is unbound too, so `⌃G` opens nvim even unlocked.

> Worktrees for parallel agents: [flow 5](#5-run-agents-in-parallel-worktrees) +
> [`claude/README.md`](../claude/README.md).

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
- Need a third pane for tests/logs? `⌃p` then `d` splits the current pane downward; run
  `npm test --watch` there.
- Lunch? `⌃o` then `d` detaches — everything keeps running. Back later: `zellij attach`.

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
loop than an embedded IDE agent, and you stay in control of the diff.
[`zellij-autolock`](../zellij/README.md#autolock) (on by default) passes every key straight to the
focused editor/agent — no manual locking when the pane runs one of its watched apps (nvim/vim/git/fzf/
zoxide/atuin/**claude**); `⌥z` drops back to the full multiplexer when you need it.

### 4. Git, the fast way
*You're ready to review and commit.*

- Quick status: `gs` (alias) in any shell pane.
- Full TUI: `lg` (or `<Space>gg` inside Neovim) → **lazygit**. Stage hunks with `Space`, commit with
  `c`, push with `P`, browse branches with `b`. It's the fastest staging UI there is.
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
- **One palette, low friction.** Catppuccin across every layer — Latte in light, Mocha in dark,
  following the macOS appearance in lockstep — so there's less visual context-switching when your
  eyes jump pane to pane.

---

## Reload & troubleshoot

| Symptom / want | Do this |
|---|---|
| "Is my setup healthy?" | `make doctor` — checks tools, symlinks, fonts, `$PATH` (read-only) |
| Changed Ghostty config, no effect | `⌘⇧R` (reload), or restart Ghostty for font changes |
| Changed an nvim plugin spec | `:Lazy sync` (or restart nvim) |
| Changed a shell file | `source ~/.zshrc` or open a new shell |
| "Does my config even load?" | `make check` (all validators) — or per-tool, see below |
| A keybind seems dead | check the layer: is the pane **locked** (autolock)? Then the app gets the key — press `⌥z` to reach Zellij |
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
