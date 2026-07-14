# 🐚 zsh + Starship — the shell layer

The launchpad. A thin, modular zsh setup with the [Starship](https://starship.rs) prompt and a set of
modern CLI companions wired in — so you **type less and jump more**. The `.zshrc` does almost nothing
itself: it sources small **role files** in a deliberate order, each concern in one place.

**This file is the single source for the shell in this stack** — the mental model, every alias and
keybinding, the fast recipes, a "moves that pay rent" card for **each companion CLI**, and the config
rationale. Nothing to hunt across other files or upstream manuals.

- **Files:** [`.zshrc`](./.zshrc) → `~/.zshrc`; [`*.zsh`](.) → `~/.config/zsh/`;
  [`starship.toml`](./starship.toml) → `~/.config/starship.toml`
- **Validate:** `zsh -n <file>` (syntax, no execution) — run by `/check` + CI
- **Feature:** `F-SHELL-001` · **Upstream:** <https://starship.rs/config>

### Contents

1. [The mental model](#1-the-mental-model) — the shell as a launchpad, and the one load order that makes it work
2. [Quick start: the moves that pay rent](#2-quick-start--the-moves-that-pay-rent)
3. [Complete reference — aliases + shell keys](#3-complete-reference--aliases--shell-keys)
4. [Recipes — "I want to… → do this"](#4-recipes--i-want-to--do-this)
5. [Companion CLIs — a card each](#5-companion-clis--a-card-each)
   · [fzf](#51-fzf--fuzzy-everything) · [fzf-tab](#52-fzf-tab--tab-becomes-a-fuzzy-menu) · [zoxide](#53-zoxide--jump-by-frecency) · [atuin](#54-atuin--history-as-a-database) · [zsh-vi-mode](#55-zsh-vi-mode--vim-on-the-command-line) · [autosuggestions](#56-zsh-autosuggestions--grey-ghost-text) · [syntax-highlighting](#57-zsh-syntax-highlighting--live-colour) · [eza](#58-eza--a-better-ls) · [bat](#59-bat--a-better-cat--pager) · [ripgrep](#510-ripgrep-rg--a-better-grep) · [fd](#511-fd--a-better-find) · [lazygit](#512-lazygit--git-as-a-tui) · [yazi](#513-yazi--a-tui-file-manager) · [fnm](#514-fnm--node-version-manager)
6. [Anti-patterns](#6-anti-patterns)
7. [The prompt (Starship)](#7-the-prompt-starship)
8. [Keeping `$HOME` tidy — XDG](#8-keeping-home-tidy--xdg-base-directories)
9. [Living inside a Zellij pane](#9-living-inside-a-zellij-pane)
10. [Settings reference](#10-settings-reference-config-rationale) · [Reload & verify](#11-reload--verify) · [Install](#12-install)

---

## 1. The mental model

**The shell is a launchpad, not a place you live.** You don't `cd` deep, `grep -r`, and scroll — you
**fuzzy-everything** ([fzf](#51-fzf--fuzzy-everything)), **jump by frecency**
([zoxide](#53-zoxide--jump-by-frecency)), and **search your whole history like a database**
([atuin](#54-atuin--history-as-a-database)). Three keystrokes replace three habits:

| Old habit | The launchpad move |
|---|---|
| `cd ../../projects/foo/src` | `z foo` — jump by name, ranked by how often × how recently you go there |
| `↑ ↑ ↑` hunting for a command | `Ctrl-R` — full-text fuzzy search over every command you've ever run |
| `ls`, eyeball, `cd`, repeat | `Ctrl-T` (paste a fuzzy-picked path) · `Alt-C` (fuzzy-`cd`) |

**The one load-bearing invariant: source order.** [`.zshrc`](./.zshrc) sources six role files in a
fixed sequence, and the order is *not* cosmetic — three couplings depend on it:

```
env → vi-mode → aliases → tools → prompt → plugins
```

| Boundary | Why it must be there |
|---|---|
| `env` **first** | Sets `$EDITOR`, `$XDG_*`, history *before* anything reads them. |
| `vi-mode` **before** `tools` | [zsh-vi-mode](#55-zsh-vi-mode--vim-on-the-command-line) *overwrites* keymaps on init, so fzf's `Ctrl-T`/`Ctrl-R` and atuin's `Ctrl-R` must bind **after** it or they're clobbered. This is why it runs `ZVM_INIT_MODE=sourcing`. |
| `plugins` **last**, highlighting **within it last** | [zsh-syntax-highlighting must be sourced after every other widget](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md) so it can wrap them. |

Every integration is **guarded** (`command -v tool && …`): a missing tool is a **silent skip**, never a
broken startup. So you can install the stack piecemeal — the shell degrades gracefully.

---

## 2. Quick start — the moves that pay rent

Learn these before anything else; they cover ~90% of real use. (Per-tool detail is in
[§5](#5-companion-clis--a-card-each).)

| Reflex | Keys / command | Tool |
|---|---|---|
| Jump to a dir by name | `z foo` | zoxide |
| Pick a dir interactively | `zi` | zoxide |
| Fuzzy-search **history** | `Ctrl-R` | atuin |
| Paste a fuzzy-picked **path** | `Ctrl-T` | fzf |
| Fuzzy-`cd` into a subdir | `Alt-C` | fzf |
| Fuzzy **Tab-completion** menu | `Tab` (on any completion) | fzf-tab |
| Accept the grey suggestion | `→` (right arrow) | autosuggestions |
| Fuzzy-complete an argument | `vim **`, then `Tab` | fzf |
| Long listing with git status | `ll` | eza |
| Git, visually | `lg` | lazygit |
| File manager | `y` | yazi |
| Vim editing on the prompt | `Esc` then `ci"`, `daw`, … | zsh-vi-mode |

> **`Ctrl-R` is atuin's, not fzf's, in this setup.** Both bind `Ctrl-R`; because `tools.zsh` runs
> `atuin init` *after* `fzf --zsh`, **atuin wins** — you get atuin's database UI, not fzf's. That's
> intentional (see [§5.4](#54-atuin--history-as-a-database)).

---

## 3. Complete reference — aliases + shell keys

Everything defined in this repo's config. The config file is the contract; this is the offline copy.

### Aliases ([`aliases.zsh`](./aliases.zsh))

| Alias | Expands to | Notes |
|---|---|---|
| `ls` | `eza --group-directories-first` | eza only; plain `ls` if eza absent |
| `ll` | `eza -lah --group-directories-first --git` | long, all, human sizes, git status |
| `la` | `eza -a --group-directories-first` | all entries |
| `lt` | `eza --tree --level=2` | tree, 2 levels deep |
| `..` / `...` | `cd ..` / `cd ../..` | |
| `gs` / `gd` | `git status` / `git diff` | |
| `gl` | `git log --oneline --graph --decorate` | one-line graph |
| `ga` / `gc` / `gp` | `git add` / `commit` / `push` | the verbs `lg` doesn't cover |
| `gco` | `git checkout` | |
| `zj` | `zellij` | multiplexer CLI (attach/list/kill) |
| `zjd` | `zellij --layout dev` | the editor │ agent workspace, one command |
| `zja` | `zellij attach` | re-enter a detached session |
| `lg` | `lazygit` | only if installed |
| `y` | `yazi` | only if installed |
| `yolo` | `claude --dangerously-skip-permissions` | opt-in, **never** a shadow of bare `claude` |

> **Deliberately *not* aliased:** `grep`, `find`, `cat`. Scripts and muscle memory keep working;
> the modern replacements ([`rg`](#510-ripgrep-rg--a-better-grep), [`fd`](#511-fd--a-better-find),
> [`bat`](#59-bat--a-better-cat--pager)) get their own names. `bat` is wired only as the man-pager.

Fall-back when eza is absent: `ll='ls -lah'`, `la='ls -A'` (no `ls`/`lt`).

### Shell keybindings (wired by the integrations)

| Keys | Action | Bound by |
|---|---|---|
| `Ctrl-R` | fuzzy history search (database UI) | [atuin](#54-atuin--history-as-a-database) |
| `↑` | prefix-search history | atuin |
| `Ctrl-T` | paste a fuzzy-picked file/dir path | [fzf](#51-fzf--fuzzy-everything) |
| `Alt-C` | fuzzy-`cd` into a subdirectory | fzf |
| `Tab` | fuzzy completion menu | [fzf-tab](#52-fzf-tab--tab-becomes-a-fuzzy-menu) |
| `→` / `End` | accept the grey autosuggestion | [autosuggestions](#56-zsh-autosuggestions--grey-ghost-text) |
| `**` + `Tab` | fuzzy-complete the current argument | fzf |
| `Esc` / `Ctrl-[` | enter Vim **normal** mode on the prompt | [zsh-vi-mode](#55-zsh-vi-mode--vim-on-the-command-line) |

`AUTO_CD` is on ([`env.zsh`](./env.zsh)) — typing a bare `foo/` is `cd foo/`.

---

## 4. Recipes — "I want to… → do this"

**Get back to a project I was in last week.** `z` remembers directories by *frecency* (frequency ×
recency), so `z termi` lands you in `terminal-stack` even from `$HOME` — no path typed. Forgot the
name? `zi` opens an fzf picker over the whole database. `z -` bounces to the previous dir
([zoxide](https://github.com/ajeetdsouza/zoxide#getting-started)).

**Re-run a command I ran once, days ago.** `Ctrl-R`, type any fragment (`docker`, `--port 8080`), and
atuin fuzzy-searches your *entire* history. `Enter` runs it; `Tab` drops it on the prompt to **edit
first**. Press `Ctrl-R` again inside the UI to cycle the scope (global → session → this directory)
([atuin search](https://docs.atuin.sh/reference/search/)).

**Feed a fuzzy-picked file to any command.** Type the command, then `**` and `Tab`:
`nvim **⟨Tab⟩`, `git add **⟨Tab⟩`, `kill -9 **⟨Tab⟩` — fzf completes the argument
([fzf completion](https://github.com/junegunn/fzf#fuzzy-completion-for-bash-and-zsh)). Or `Ctrl-T`
anywhere to paste a path without leaving the line.

**Grep a codebase fast.** `rg TODO` searches recursively from the cwd, honoring `.gitignore` and
skipping binaries by default; `rg -tpy async` limits to Python, `rg -l pattern` lists only filenames
([ripgrep guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)). Pair with `fd -e ts`
to find files by name/extension ([fd](https://github.com/sharkdp/fd#how-to-use)).

**Stage and commit visually.** `lg` opens [lazygit](#512-lazygit--git-as-a-tui): `Space` stages the
file under the cursor, `c` commits, `P` pushes — no `git add -p` dance.

**Read a man page in colour.** Just `man <anything>` — [bat](#59-bat--a-better-cat--pager) is wired as
`MANPAGER`, so man pages come syntax-highlighted with no extra step.

**Browse and jump with a file manager.** `y` opens [yazi](#513-yazi--a-tui-file-manager); navigate
with `h`/`j`/`k`/`l`, `Enter` to open. *(To have the shell `cd` to yazi's last directory on quit, wire
the `y()` wrapper — see [§5.13](#513-yazi--a-tui-file-manager).)*

---

## 5. Companion CLIs — a card each

Only the tools **actually wired in this repo's config** appear here. Each card is a *moves that pay
rent* quick-start: the handful of keys/commands that get you productive, plus one recipe. Go deeper via
the linked upstream doc — you shouldn't need to for daily use.

### 5.1 fzf — fuzzy-everything

The general-purpose fuzzy finder; the shell integration (`source <(fzf --zsh)`, [`tools.zsh`](./tools.zsh))
adds keybindings. Docs: <https://github.com/junegunn/fzf>.

**Shell keys:** `Ctrl-T` paste a picked path · `Alt-C` fuzzy-`cd` · (`Ctrl-R` is
[atuin's](#54-atuin--history-as-a-database) here, not fzf's).

**Inside the finder:**

| Key | Action |
|---|---|
| type | filter the list |
| `Ctrl-J` / `Ctrl-K` (or `Ctrl-N` / `Ctrl-P`) | move down / up |
| `Enter` | accept |
| `Tab` | toggle-select + advance (multi-select) |
| `Shift-Tab` | toggle-select + back |
| `Shift-↑` / `Shift-↓` | scroll a preview |
| `Esc` / `Ctrl-C` / `Ctrl-G` | abort |

**Fuzzy completion:** `COMMAND [dir/]pattern**⟨Tab⟩` — e.g. `cd **⟨Tab⟩`, `unset **⟨Tab⟩`.

> **Recipe — pick a file into an editor:** `nvim **⟨Tab⟩`, filter, `Enter`. Or `Ctrl-T` to inject the
> path mid-command.

> ⚠️ **Setup correction:** the current form is `source <(fzf --zsh)` (fzf ≥ 0.48, Feb 2024) — the
> integration ships *in the binary*. Old guides tell you to `source ~/.fzf.zsh` or source
> `key-bindings.zsh` + `completion.zsh`; that's pre-0.48 and drifts. This repo uses the correct form.
> Also: `?`/`toggle-preview` have **no** default bind, and `Ctrl-/` now toggles *word-wrap*, not
> preview scroll (scroll is `Shift-↑/↓`).

**Power flags — by task** *(when you pipe a list into `fzf` yourself, e.g. `fd -t f | fzf …`):*

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Preview each candidate | `--preview 'bat --color=always {}'` | Runs the command per line; `{}` is the current item |
| Pick several at once | `-m` | Multi-select with `Tab`; prints every chosen line |
| Start already filtered | `-q 'foo'` | Open with a query pre-typed |
| Literal, not fuzzy | `-e` | Exact-match mode |
| Non-interactive filter | `-f 'foo'` | Print matches and exit, no UI (add `--no-sort` for a fuzzy `grep`) |
| Auto-pick the obvious one | `-1` | Select immediately if there is exactly one match (`-0` exits on none) |
| Keep it out of the way | `--height 40% --layout reverse` | A 40%-tall pane below the cursor, list on top |
| Colorized input | `--ansi` | Honor ANSI color codes in the piped-in text |
| Capture the typed query | `--print-query` | Emit the query as the first output line |

### 5.2 fzf-tab — Tab becomes a fuzzy menu

Replaces zsh's completion *selection menu* with an fzf picker — it hooks native completion, doesn't
replace it. Loaded in [`plugins.zsh`](./plugins.zsh). Docs: <https://github.com/Aloxaf/fzf-tab>.

**Keys (inside the menu):**

| Key | Action |
|---|---|
| `Tab` | accept |
| `Ctrl-Space` | toggle multi-select |
| `F1` / `F2` | switch completion groups |
| `/` | continuous completion — drill into a path segment by segment |

> **Recipe:** `cd ⟨Tab⟩` now fuzzy-filters directories in an fzf list instead of cycling; type a few
> letters to narrow, `Enter` to accept.

> **Ordering (why it's sourced where it is):** fzf-tab must bind `^I` (Tab) **after** `compinit` and
> **after** [zsh-autosuggestions](#56-zsh-autosuggestions--grey-ghost-text) — which is exactly the
> `plugins.zsh` order. It also needs zsh's own menu *off* (do not set `menu select`).

### 5.3 zoxide — jump by frecency

A smarter `cd` that ranks visited directories by **frecency** = frequency + recency. Initialised in
[`tools.zsh`](./tools.zsh) (`eval "$(zoxide init zsh)"`). Docs: <https://github.com/ajeetdsouza/zoxide>.

**Commands:**

| Command | Action |
|---|---|
| `z foo` | jump to the top match |
| `z foo bar` | match multiple keywords in order |
| `z -` | previous directory |
| `zi foo` | pick interactively via fzf |
| `z ..` · `z ~/x` | plain paths act like `cd` |

> **Recipe:** visit `~/lab/terminal-stack` a couple of times, then from anywhere `z termi` teleports
> there. The database self-ages, so stale dirs fade.

> **Matching rule:** keywords match path *components* left-to-right, and the **last keyword must match
> the last path segment** — so `z stack` beats `z lab` for `…/terminal-stack`.

**Power flags — by task:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Disambiguate with two hints | `z foo bar` | Match multiple keywords in order (last must hit the last segment) |
| Bounce back | `z -` | Jump to the previous directory |
| Not sure of the name | `zi foo` | Interactive fzf picker, optionally seeded with `foo` |
| See the match without moving | `zoxide query foo` | Print the top path (`-l` lists all; `-i` picks interactively) |
| Prune a stale entry | `zoxide remove <path>` | Drop a directory from the database |
| Seed the database | `zoxide add <path>` | Add / bump a directory's rank |

### 5.4 atuin — history as a database

Replaces flat `~/.zsh_history` with a searchable (optionally syncable) SQLite history and a full-screen
search UI. Initialised in [`tools.zsh`](./tools.zsh). Docs: <https://docs.atuin.sh>.

**It takes over `Ctrl-R` *and* `↑` by default.**

**Search UI keys:**

| Key | Action |
|---|---|
| type | filter |
| `↑` / `↓` (or `Ctrl-P` / `Ctrl-N`) | navigate |
| `Enter` | **run immediately** |
| `Tab` | put on the prompt to **edit first** |
| `Ctrl-R` | cycle filter mode (global / session / directory) |
| `Ctrl-S` | cycle search mode |
| `Esc` / `Ctrl-C` / `Ctrl-G` | cancel |

**CLI:** `atuin search <query>` (with `--after "yesterday 3pm"`, `--exit 0`, …).

> **Recipe:** `Ctrl-R`, type `port 8080`, `Ctrl-R` again to narrow to *this directory's* history,
> `Enter`.

> **Sync is opt-in** — atuin works fully local with no account; a hosted or self-hosted sync server is
> a separate, deliberate step. ⚠️ Edit-vs-run is **`Enter` = run / `Tab` = edit** (plus an
> `enter_accept` config toggle) — there is **no** default `Alt-Enter`/`Ctrl-Enter`, contrary to some
> blogs.

**Power flags — by task** *(the `atuin search` CLI, not the `Ctrl-R` UI):*

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Cap the result count | `--limit 20` | Return at most N matches |
| Only commands since… | `--after "yesterday 3pm"` | Filter by time (`--before` / `-b` for the other bound) |
| Scope to a directory | `-c <dir>` | Only history run in that directory |
| Only the ones that succeeded | `-e 0` | Filter by exit code (`--exclude-exit` to invert) |
| Just the command text | `--cmd-only` | Print the bare command, ideal for piping |
| Change how it matches | `--search-mode fulltext` | `prefix` · `fulltext` · `fuzzy` · `skim` |
| Change what it searches | `--filter-mode directory` | `global` · `host` · `session` · `directory` |
| What do I run most | `atuin stats` | Top commands (`--count N`); add a period like `atuin stats yesterday` |

### 5.5 zsh-vi-mode — Vim on the command line

Modal editing on the prompt — the same motions as Neovim. Loaded in [`vi-mode.zsh`](./vi-mode.zsh).
Docs: <https://github.com/jeffreytse/zsh-vi-mode>.

**Keys:**

| Key | Action |
|---|---|
| `Esc` (or `Ctrl-[`) | enter **normal** mode |
| `i` · `a` · `I` · `A` | back to insert |
| `v` | visual mode |
| `ci"` · `daw` · `0`/`$`/`w`/`b` | motions + text objects |
| `ys"` · `cs"'` · `ds"` | **surround:** add · change `"`→`'` · delete |

A **cursor-shape** change marks the mode (beam = insert, block = normal); the prompt's `❮` glyph also
flips (see [§7](#7-the-prompt-starship)).

> **Recipe:** typed a long command with a wrong flag? `Esc`, `b` to the word, `cw` to change it, keep
> going — no re-typing.

> **The coupling that shapes load order:** zvm *rebinds every keymap* when it initialises, which would
> wipe fzf's and atuin's `Ctrl-R`/`Ctrl-T`. This repo sets `ZVM_INIT_MODE=sourcing` and loads vi-mode
> **before** `tools.zsh`, so those integrations bind *after* zvm and win ([§1](#1-the-mental-model)).

### 5.6 zsh-autosuggestions — grey ghost text

Suggests, in grey, the rest of a command from your history as you type. Loaded in
[`plugins.zsh`](./plugins.zsh) with `ZSH_AUTOSUGGEST_STRATEGY=(history completion)`. Docs:
<https://github.com/zsh-users/zsh-autosuggestions>.

**Keys:** `→` (right arrow) or `End` accepts the whole suggestion; the `forward-word` widget accepts one
word. **Strategy** `(history completion)` = try a history match first, else fall back to a shell
completion — tried in array order.

> ⚠️ `ZSH_AUTOSUGGEST_STRATEGY` is an **array** (default `(history)`); old tips write it as a scalar.
> This repo's array form is correct. Upstream documents the *widget* for word-accept, not a fixed key —
> the exact key is your keymap's business.

### 5.7 zsh-syntax-highlighting — live colour

Colours the command line as you type: a valid command turns green, an unknown one red, before you even
run it. Loaded **last** in [`plugins.zsh`](./plugins.zsh). Docs:
<https://github.com/zsh-users/zsh-syntax-highlighting>.

> **Must be sourced last** — after every other widget (autosuggestions, fzf-tab, `compinit`) so it can
> wrap them. That single requirement is why `plugins.zsh` is `.zshrc`'s final source and highlighting
> its final line.

### 5.8 eza — a better `ls`

A modern `ls` with icons, git-status columns, and tree view. Backs `ls`/`ll`/`la`/`lt` when installed
([`aliases.zsh`](./aliases.zsh)), plain `ls` otherwise. Docs: <https://github.com/eza-community/eza>.

**Flags in use:** `--group-directories-first`, `-l` long, `-a` all, `-h` header/human sizes (`-lah`
combines them), `--git` status column, `--tree` + `--level=N`.

> ⚠️ **eza, not exa** — `exa` is unmaintained; eza is the maintained fork. Long forms are `-T`/`--tree`
> and `-L`/`--level` (not `-t`/`-l`).

**Power flags — by task:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| See the tree, but not endlessly deep | `-T -L 2` | Tree view capped at 2 levels (`-L` alone just governs depth; pair it with `-T`) |
| Which files are the space hogs | `-l -s size -r` | Long view, sort by size, biggest first (`-r` reverses the ascending default) |
| What did I touch most recently | `-l -s modified -r` | Sort by mtime; `-r` puts newest at the top |
| Total weight of each directory | `-l --total-size` | Recursive size per dir, not just the entry (**Unix only**) |
| Hide the noise git already ignores | `--git-ignore` | Omit `.gitignore`d paths from the listing |
| List only sub-directories | `-D` | Directories only (`-f` for files only) |
| Show `.` and `..` too | `-aa` | `-a` shows dotfiles; a second `a` adds `.`/`..` |
| Group folders at the top | `--group-directories-first` | Dirs first, then files (already in the `ls` alias) |

### 5.9 bat — a better `cat` / pager

A `cat` clone with syntax highlighting and a built-in pager. Wired **only** as the man-pager in
[`tools.zsh`](./tools.zsh) (`MANPAGER="sh -c 'col -bx | bat -l man -p'"`). Docs:
<https://github.com/sharkdp/bat>.

**Use:** `bat file.rs` highlights + paginates · `-p`/`--plain` drops line numbers & git gutter · `-l
<lang>` forces a language.

> **Why not alias `cat`?** It would break `cat > file` and pipes into programs expecting plain bytes,
> so it's man-pager only. **The `col -bx` variant is deliberate:** the current upstream headline is the
> terser `MANPAGER="bat -plman"`, but the `col -bx |` pipe strips overstrike sequences some `man`
> implementations still emit — the more robust form.

**Power flags — by task:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Read just lines 20–40 | `-r 20:40` | Print a line range (`:40`, `20:`, `20:+5` also work; repeat `-r` for several ranges) |
| Feed clean text into a pipe | `-p` | Plain style — no numbers/grid/gutter; `-pp` also turns paging off |
| Syntax for a file with no extension | `-l <lang>` | Force a language (`-l json`, `-l man`) |
| Show only what git changed | `-d` | Print just added/modified lines vs the git index; `--diff-context N` for surroundings |
| Point at one line while reading | `-H 30` | Highlight a line (range syntax like `-r`; repeatable) |
| Pick the exact look | `--style=numbers,changes` | Choose components; `+x`/`-x` add/remove from a preset |
| Find a theme you like | `--list-themes` | List themes; then `--theme=<name>` (`--list-languages` for syntaxes) |
| Reveal tabs/spaces/newlines | `-A` | Show non-printable characters |

### 5.10 ripgrep (`rg`) — a better `grep`

Recursive, `.gitignore`-aware, very fast search. A runtime dependency (**not** aliased — `grep` stays
`grep`). Docs: <https://github.com/BurntSushi/ripgrep>.

**Moves:** `rg pattern` (recursive from cwd) · `rg pattern path` · `-i` ignore case (`-S` smart-case) ·
`-t py` restrict to a filetype · `-g '*.md'` glob (`-g '!dist'` exclude) · `-l` list matching files ·
`-A`/`-B`/`-C N` context lines · `--hidden` include hidden. **Defaults:** respects
`.gitignore`/`.ignore`, skips hidden + binary (disable all filtering: `rg -uuu`).

**Power flags — by task:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Search one language only | `-t py` / exclude `-T test` | Restrict to (or exclude) a file type; `--type-list` shows all |
| Include/exclude by glob | `-g '*.md'` / `-g '!dist'` | Narrow to a glob, or negate one to skip it |
| Read the hit in context | `-C 3` | 3 lines either side (`-A`/`-B` for just after/before) |
| Just the filenames | `-l` | Files with a match (`--files-without-match` for the inverse) |
| How many lines matched | `-c` | Count matching **lines** per file (`--count-matches` for total matches) |
| Whole words only | `-w` | Match on word boundaries, not substrings |
| Extract just the match | `-o` | Print only the matched text, not the line |
| Lookarounds / backrefs | `-P` (`+ -U`) | PCRE2 engine; add `-U` for a multiline pattern |
| Search the ignored stuff too | `-uu` / `-uuu` | Drop ignore+hidden filtering; a third `u` adds binary files |
| Preview a rename | `-r '$1'` | Rewrite output with capture groups (non-destructive — display only) |
| Deterministic ordering | `--sort path` | Stable path order (forces single-threaded) |

### 5.11 fd — a better `find`

Fast, ergonomic file finder, `.gitignore`-aware. Also a runtime dependency (not aliased). Docs:
<https://github.com/sharkdp/fd>.

**Moves:** `fd pattern` (regex, from cwd) · `fd -e ts` by extension · `-t f`/`-t d` files/dirs only ·
`-H` include hidden · `-x cmd` run a command per result (parallel). **Defaults:** respects `.gitignore`
(`-I` disables), **smart-case** (case-insensitive unless the pattern has an uppercase letter).

**Power flags — by task:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Find by extension | `-e ts` | Match a file extension (repeat for several) |
| Only files / only dirs | `-t f` / `-t d` | Restrict to a type (`-t l` symlinks, `-t x` executables) |
| Run a command on each hit | `-x cmd {}` | Exec once per result, in parallel (`{}` is the path) |
| Run once with the whole list | `-X cmd` | Batch all results into a single command invocation |
| Search hidden / ignored files | `-H` / `-I` / `-u` | Add hidden · ignore `.gitignore` · `-u` does both |
| Stay shallow | `-d 2` | Cap traversal depth at 2 |
| Glob instead of regex | `-g '*.test.ts'` | Treat the pattern as a glob |
| Skip a subtree | `-E node_modules` | Exclude a glob (repeatable) |
| Only what changed lately | `--changed-within 2d` | Modified in the last 2 days (`--changed-before` for older) |
| By size | `-S +1m` | Larger than 1 MiB (`-500k` for smaller) |
| Safe piping to xargs | `-0` | NUL-separate results for `xargs -0` |

### 5.12 lazygit — git as a TUI

A full terminal UI for git — stage, commit, rebase, and cherry-pick without leaving the keyboard.
Aliased `lg` when installed ([`aliases.zsh`](./aliases.zsh)). Every key below is verified against the
[upstream keybindings](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md).

**Global** (any panel):

| Key | Action | Key | Action |
|---|---|---|---|
| `Tab` · `[` `]` | next panel · prev/next tab | `?` | keybindings menu |
| `J`/`K` · `Ctrl-D`/`Ctrl-U` | scroll the main view | `/` | search the view |
| `z` / `Z` | **undo / redo** the last git action | `:` | run a raw git command |
| `R` | refresh state | `+` / `_` | cycle / prev screen-size mode |

**Files panel:**

| Key | Action | Key | Action |
|---|---|---|---|
| `Space` | stage / unstage | `a` | stage **all** |
| `c` | commit | `C` | commit in `$EDITOR` |
| `A` | amend last commit | `d` | discard changes |
| `e` / `o` | edit / open file | `i` | add to `.gitignore` |
| `S` | stash options | `f` · `P` · `p` | fetch · push · pull |

**Commits panel** — interactive rebase without the raw syntax:

| Key | Action | Key | Action |
|---|---|---|---|
| `s` | squash into commit below | `f` | fixup into below |
| `r` | reword message | `d` | drop commit |
| `e` | mark for edit (rebase) | `A` | amend with staged |
| `C` / `V` | copy / paste (cherry-pick) | `t` · `T` | revert · tag |

**Branches panel:**

| Key | Action | Key | Action |
|---|---|---|---|
| `Space` | checkout | `M` | merge into current |
| `n` | new | `R` | rename |
| `d` | delete | `f` | fast-forward |
| `r` | rebase onto |  |  |

**Stash:** `Space` apply · `g` pop · `d` drop.

**CLI flags — launching it:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Open on another repo | `-p <path>` | Point at a repo path (shorthand for `--work-tree=<path> --git-dir=<path>/.git`) |
| Land on a specific view | `lazygit log` / `status` / `branch` / `stash` | Positional arg — focus that panel on open |
| Scope to one file's history | `-f <path>` | Filter commits/reflog/stash to `git log -- <path>` (overrides the panel arg) |
| Drive a bare/dotfiles repo | `-w <tree> -g <gitdir>` | Explicit `--work-tree` + `--git-dir` (e.g. a `~/.dotfiles` bare repo over `$HOME`) |
| Bigger focused panel | `-sm half` / `-sm full` | Initial screen-mode (`normal` default) |
| Find where config lives | `-cd` | Print the config dir (`-ucd <dir>` overrides it for this run) |
| Report a bug | `-d` | Debug mode with logging (`-l` tails those logs) |

> **Recipe — stage, commit, push:** `lg`, in Files `Space` the file(s), `c` to commit, `P` to push.
> **Rewrite history without fear:** in Commits, `s`/`f`/`r`/`d`/`e` on a commit drive an interactive
> rebase through lazygit's guided flow — no `git rebase -i` editor to hand-edit.

> ⚠️ Keys are **panel-scoped**: `d` discards a file but drops a commit/stash; `Space` stages *or*
> checks out *or* applies depending on focus. The top bar shows the active panel's keys; `?` lists all.

### 5.13 yazi — a TUI file manager

A fast, vim-keyed file manager with live previews. Aliased `y` when installed. Keys verified against the
[default keymap](https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/keymap-default.toml).

**Navigate:**

| Key | Action | Key | Action |
|---|---|---|---|
| `h` / `l` | leave / enter dir | `g g` / `G` | top / bottom |
| `j` / `k` | down / up | `K` / `J` | scroll the preview |
| `.` | toggle hidden | `t t` · `1`…`9` · `[` `]` | new tab · switch · prev/next |

**Select & operate:**

| Key | Action | Key | Action |
|---|---|---|---|
| `Space` | toggle select + go down | `y` · `x` · `p` | copy · cut · paste |
| `v` / `V` | visual select / unselect | `P` | paste (overwrite) |
| `Ctrl-a` / `Ctrl-r` | select all / invert | `d` / `D` | trash / delete forever |
| `Esc` | cancel selection | `a` · `r` | create · rename |

**Find, jump, open, quit:**

| Key | Action | Key | Action |
|---|---|---|---|
| `/` · `?` | find next / prev | `z` · `Z` | jump via **fzf** · **zoxide** |
| `f` | filter | `Enter` · `o` | open |
| `s` | search names (`fd`) | `O` | open-with |
| `S` | search content (`rg`) | `;` | shell |
|  |  | `q` · `Q` | quit · quit **without** cd-on-exit |

**CLI flags — launching it:**

| Task / goal | Flag or combo | What it does |
|---|---|---|
| Start in a directory | `yazi <path>` | Open with that entry as the cwd |
| `cd` the shell on quit | `--cwd-file <f>` | Write the final directory to a file on exit — the mechanism the `y()` wrapper reads (below) |
| Use it as a file picker | `--chooser-file <f>` | Chooser mode: write the selection to a file and exit (wire it into other tools) |
| Clear a stale cache | `--clear-cache` | Empty the cache directory |
| Report a bug | `--debug` | Print debug information |

> ⚠️ **`z` is fzf, `Z` is zoxide in yazi** — inverted from the shell, where `z` is zoxide. And a vim
> asymmetry: go-top is the chord `g g`, but go-bottom is bare `G`.

> **`cd`-on-quit (opt-in):** this repo aliases `y='yazi'` (bare), so quitting does **not** move the
> shell. For "quit yazi → land in the last-browsed dir," add the upstream `y()` wrapper to
> `~/.zshrc.local` — it runs yazi with `--cwd-file` and `cd`s there on `q` (not `Q`):
> <https://yazi-rs.github.io/docs/quick-start#shell-wrapper>.

### 5.14 fnm — Node version manager

A fast, Rust-written Node.js version manager. **Not interactive** — it's initialised in
[`tools.zsh`](./tools.zsh) (`eval "$(fnm env --use-on-cd)"`) so the right Node is on `PATH`, and it's
here because Neovim's LSP tooling launched from this shell needs a runtime. Docs:
<https://github.com/Schniz/fnm>.

**Already wired:** `fnm env --use-on-cd` — on every `cd`, fnm reads a directory's `.node-version` /
`.nvmrc` and **auto-switches** the active Node. You rarely call fnm by hand; the switch is automatic.

**CLI — managing versions:**

| Task / goal | Command | What it does |
|---|---|---|
| Install a version | `fnm install 22` (`--lts`) | Install a version (`--lts` for the latest LTS, `--latest` for newest) |
| Switch this shell | `fnm use 22` | Change the active version for the current session |
| Set the shell default | `fnm default 22` | Version new shells start on |
| What's installed | `fnm list` | List local versions (`list-remote` shows installable ones) |
| What's active now | `fnm current` | Print the version in use |
| Pin a project | write `.node-version` | Then `--use-on-cd` switches to it automatically on entry |

---

## 6. Anti-patterns

| Don't | Do instead |
|---|---|
| `cd ../../../foo/bar` | `z bar` — frecency jump ([zoxide](#53-zoxide--jump-by-frecency)) |
| `↑ ↑ ↑` hunting through history | `Ctrl-R` — fuzzy search ([atuin](#54-atuin--history-as-a-database)) |
| `grep -r pattern .` | `rg pattern` — faster, `.gitignore`-aware ([ripgrep](#510-ripgrep-rg--a-better-grep)) |
| `find . -name '*.ts'` | `fd -e ts` — smart-case, ignores junk ([fd](#511-fd--a-better-find)) |
| `alias cat=bat` | leave `cat` alone; bat is the man-pager ([§5.9](#59-bat--a-better-cat--pager)) |
| `alias grep=rg` / `find=fd` | keep the names; use `rg`/`fd` directly (scripts stay portable) |
| Put secrets in a committed `*.zsh` | `~/.zshrc.local` (git-ignored) — public repo ([§10](#10-settings-reference-config-rationale)) |
| `git add -p` then `git commit -m …` | `lg` — stage + commit + push visually ([lazygit](#512-lazygit--git-as-a-tui)) |

---

## 7. The prompt (Starship)

[`starship.toml`](./starship.toml) styles the prompt with the terminal's **16 ANSI colors** (no
hardcoded palette), so it **follows Ghostty's live theme repaint** — whatever palette the terminal is on,
light or dark — with zero switching logic, the same way the rest of the stack tracks the macOS appearance.
Docs: <https://starship.rs/config>.

A compact **two-line** format: `directory · git branch · git status · command-duration`, then the `❯`
character on its own line (green on success, red on error). The `❮` **vimcmd** symbol appears when
[zsh-vi-mode](#55-zsh-vi-mode--vim-on-the-command-line) is in normal mode — a second mode indicator
beyond the cursor shape. `cmd_duration` only shows for commands over 2 s. The git-branch glyph needs a
Nerd Font (the stack assumes one).

---

## 8. Keeping `$HOME` tidy — XDG base directories

[`env.zsh`](./env.zsh) exports the [XDG base dirs](https://specifications.freedesktop.org/basedir/latest/)
(`XDG_CONFIG_HOME` · `XDG_DATA_HOME` · `XDG_STATE_HOME` · `XDG_CACHE_HOME`), so XDG-aware tools (Neovim,
atuin, bat, fd, gh, zoxide, …) keep their files under `~/.config` / `~/.local` / `~/.cache` instead of
scattering dotfiles across `$HOME`. It also redirects five common offenders that **don't** follow XDG on
their own — each via the tool's own documented variable (regenerable history/cache, so a fresh path is
safe):

| Was in `$HOME` | Now | Variable |
|---|---|---|
| `~/.zsh_history` | `~/.local/state/zsh/history` — existing history is **moved** over once | `HISTFILE` |
| `~/.lesshst` | `~/.local/state/less/history` | `LESSHISTFILE` |
| `~/.node_repl_history` | `~/.local/state/node/repl_history` | `NODE_REPL_HISTORY` |
| `~/.python_history` | `~/.local/state/python/history` | `PYTHON_HISTORY` (Python ≥ 3.13) |
| `~/.npm` (cache) | `~/.cache/npm` | `NPM_CONFIG_CACHE` |

**What we deliberately leave alone.** Tools whose `$HOME` dir holds real **state or secrets** are not
auto-redirected: repointing the variable doesn't move existing data, so it would hide your current
auth/config behind an empty path. Move the directory first, then export the var yourself in
`~/.zshrc.local`:

| Tool | Var → target | Why it's opt-in |
|---|---|---|
| Docker | `DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"` | `config.json` holds registry auth — `mv ~/.docker …` first |
| Rust | `CARGO_HOME="$XDG_DATA_HOME/cargo"` · `RUSTUP_HOME="$XDG_DATA_HOME/rustup"` | large toolchain dirs — move before re-pointing |
| AWS | `AWS_CONFIG_FILE` · `AWS_SHARED_CREDENTIALS_FILE` | credentials are secret — move the files or auth breaks |
| GnuPG | `GNUPGHOME` | 0700 perms + agent sockets make relocation fragile — best left at `~/.gnupg` |

A few `$HOME` entries can't move from the shell at all and stay put: `~/.zshrc` (zsh must read one file
from `$HOME`), `~/.gitconfig` (your identity — [git/](../git/README.md)), `~/.claude/`, and Finder's
`.DS_Store`.

---

## 9. Living inside a Zellij pane

This shell runs inside a [Zellij](../zellij/README.md) pane, and the two layers cooperate through **one
manual switch: `Alt+d`**. By default Zellij is in Normal mode and owns its hotkeys — so a full-screen
app's own Ctrl-keys (atuin's `Ctrl-R`, fzf's `Ctrl-T`/`Ctrl-J`/`Ctrl-K`) can be intercepted by the
multiplexer before they reach the tool. Press **`Alt+d`** to drop the pane to **Locked** mode: Zellij
then hands the app *every* keystroke, and those keys land where you mean them. `Alt+d` again returns to
Normal.

The trade-off is honest — **you lock by hand.** There's no autolock; nothing detects that you launched
`fzf`/`atuin` and locks for you. If atuin's `Ctrl-R` or fzf's `Ctrl-T` "doesn't work," the pane is in
Normal mode and Zellij ate the key — press `Alt+d` to lock, then use the tool (see the
[Zellij README §8](../zellij/README.md#8-living-with-claude-code--neovim--manual-lock)).

---

## 10. Settings reference (config rationale)

The *why* behind the load-bearing settings — the config states the *what*.

| Setting | Where | Why |
|---|---|---|
| `ZVM_INIT_MODE=sourcing` | `vi-mode.zsh` | Init zsh-vi-mode at source time (not first prompt) so fzf/atuin bind **after** it and survive ([§1](#1-the-mental-model)). |
| source order `env→vi-mode→…→plugins` | `.zshrc` | Three couplings depend on it — env-before-readers, vi-mode-before-binders, highlighting-last. |
| `ZSH_AUTOSUGGEST_STRATEGY=(history completion)` | `plugins.zsh` | History match first, else completion — array, tried in order. |
| `MANPAGER="sh -c 'col -bx \| bat -l man -p'"` | `tools.zsh` | Colour man pages via bat; `col -bx` strips overstrike (robust variant of upstream `bat -plman`). |
| `HISTSIZE`/`SAVEHIST=50000`, `SHARE_HISTORY`, `HIST_IGNORE_SPACE` | `env.zsh` | Big, pane-shared, de-duped history; a leading space hides a command from it. |
| `AUTO_CD` | `env.zsh` | Bare `foo/` ≡ `cd foo/`. |
| guarded `command -v tool &&` | every integration | Missing tool = silent skip, never a broken startup. |
| Starship ANSI-only colours | `starship.toml` | Prompt follows the live terminal theme with no switching logic ([§7](#7-the-prompt-starship)). |

> `fnm` (Node version manager) is initialised in `tools.zsh` (`fnm env --use-on-cd`) so the active Node
> is on `PATH` — Neovim's LSP tooling launched from this shell finds a runtime. It's non-interactive,
> but common enough to earn a short card ([§5.14](#514-fnm--node-version-manager)).

**Secrets & machine-local:** nothing secret goes in a committed file — this is a **public** repo.
Machine-local tweaks live in `~/.zshrc.local` (git-ignored), sourced last by `.zshrc`.

## 11. Reload & verify

- **Apply:** `source ~/.zshrc` or open a new shell. (fnm/zoxide/atuin/starship re-`eval` on each
  source; guards make re-sourcing idempotent.)
- **Validate:** `zsh -n zsh/.zshrc` (+ each `*.zsh`) — syntax only, never executes. Run by `/check`.
- **Try it now:** `make try` — the sandbox boots straight into this shell.

## 12. Install

`./install.sh` (or `make install`) links all of these. By hand:

```sh
ln -sf  "$PWD/zsh/.zshrc"        ~/.zshrc
mkdir -p ~/.config/zsh && ln -sf "$PWD"/zsh/*.zsh ~/.config/zsh/
ln -sf  "$PWD/zsh/starship.toml" ~/.config/starship.toml
```

Companion tools install via Homebrew (see [`.claude/rules/tooling.md`](../.claude/rules/tooling.md)):

```sh
brew install starship zoxide atuin fzf fd ripgrep eza bat lazygit yazi \
             zsh-vi-mode zsh-autosuggestions zsh-syntax-highlighting fzf-tab
```

### Go deeper (on demand — not front to back)

- **Piping these CLIs together** (into fzf, Neovim, Claude) → [docs/composing-tools.md](../docs/composing-tools.md)
- Starship modules & format → <https://starship.rs/config>
- fzf advanced binds / `FZF_DEFAULT_OPTS` → <https://github.com/junegunn/fzf#advanced-topics>
- atuin config & self-hosted sync → <https://docs.atuin.sh/configuration/config/>
- yazi plugins & the `y()` shell wrapper → <https://yazi-rs.github.io/docs/quick-start>

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).

<!--
This README is the per-tool doc pattern: ONE file per tool, at <tool>/README.md (GitHub renders it, the
root README links it). This is the SHELL tool — the biggest, because it fronts a dozen companion CLIs.
Section order mirrors zellij/README.md:
  1 mental model (the one load-bearing concept — here: launchpad + source order) · 2 quick-start "moves
  that pay rent" · 3 complete reference (aliases + keys) · 4 task-first recipes · 5 a CARD PER companion
  CLI (moves + one recipe + a gotcha) · 6 anti-patterns · 7+ prompt/XDG/Zellij coupling · settings
  rationale · reload/verify/install · "go deeper" pointers.
Rules honored: cite every key/alias/flag upstream OR in this repo's config (config.md · never invent);
config says what, prose says why (claude-md.md); public repo → assume world-readable.
Only the companion CLIs actually WIRED in this repo's config are documented — verified against
tools.zsh / aliases.zsh / plugins.zsh / vi-mode.zsh. delta is not wired here (git/ owns it), so it gets
no card.
-->
