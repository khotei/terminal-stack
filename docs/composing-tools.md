# 🧬 Composing tools — pipes, pickers & handoffs

Each CLI in the stack has its own card in [`zsh/README.md §5`](../zsh/README.md#5-companion-clis--a-card-each)
— what `fd`, `rg`, `fzf`, `bat`, `zoxide`, `yazi` do *alone*. This guide is about the **joins**: how you
pipe one into the next, and how a result crosses into **Neovim**, **Claude Code**, or **lazygit** — and
back out. That composition, not any single tool, is what makes the terminal beat an IDE for "find →
act" loops.

Every command below is **copy-pasteable** and **cited upstream** (never invented — the repo rule,
[`config.md`](../.claude/rules/config.md)). Version note: `fzf`'s `become` action needs **fzf ≥ 0.38**
and `fzf --zsh` needs **≥ 0.48**; the stack ships ≥ 0.48, so both are available.

### Contents

1. [The mental model](#1-the-mental-model) — everything is text in a pipe
2. [fzf is the universal glue](#2-fzf-is-the-universal-glue)
3. [NUL-safety — spaces in filenames](#3-nul-safety--spaces-in-filenames)
4. [Live-grep → jump to the line](#4-live-grep--jump-to-the-line) *(the killer recipe)*
5. [Into Neovim, and back out](#5-into-neovim-and-back-out)
6. [Into Claude Code, and back out](#6-into-claude-code-and-back-out)
7. [Pickers as pipe nodes — zoxide & yazi](#7-pickers-as-pipe-nodes--zoxide--yazi)
8. [Ready-made recipes](#8-ready-made-recipes)
9. [Gotchas](#9-gotchas)

---

## 1. The mental model

Think of every workflow as a **three-stage pipe**:

```
 PRODUCE            FILTER              SINK
 ───────            ──────              ────
 fd    (files)  →   fzf  (pick)    →    nvim     (edit)
 rg    (matches)→   (preview/grep) →    claude   (reason)
 git   (diff/log)                       shell    (xargs / act)
```

- **Producers** emit lines of text — filenames (`fd`), matches (`rg --vimgrep`), a diff (`git diff`).
- **`fzf` is the filter** you reach for 90% of the time: it turns any line-list into an interactive
  picker with a live preview.
- **Sinks** consume the choice — open it in the editor, hand it to Claude, or `xargs` it into any
  command.

Two rules make the joins reliable: **keep it text** (line-per-item), and **NUL-separate when names can
contain spaces** ([§3](#3-nul-safety--spaces-in-filenames)). Everything else is choosing the right
producer and the right sink.

> In this stack `Ctrl-R` is **atuin's** and `Ctrl-T` inserts a path (see
> [`zsh/README.md`](../zsh/README.md#3-complete-reference--aliases--shell-keys)); `fd` is *not* wired as
> fzf's default source — so every recipe below pipes its producer in explicitly (`fd … | fzf`), which
> always works.

---

## 2. fzf is the universal glue

The base pattern is **produce → `fzf` → act**. `{}` inside `--preview`/`--bind` is the current line.

```sh
# Pick a file, preview it with bat
fd -t f | fzf --preview 'bat --color=always {}'
# what: fuzzy-pick one file; the preview pane shows it highlighted. The building block for "choose then act".
```

```sh
# Open the pick straight in nvim — no subshell (fzf ≥ 0.38)
fd -t f | fzf --preview 'bat --color=always {}' --bind 'enter:become(nvim {})'
# what: on Enter, fzf replaces itself with `nvim <pick>`. `become` is the modern, quote-safe alternative to $(...).
```

```sh
# Portable equivalent via command substitution (any fzf version)
nvim "$(fd -t f | fzf --preview 'bat --color=always {}')"
# what: same result without `become`. Caveat: if you abort with Esc, it opens nvim on an empty name.
```

```sh
# Multi-select (-m), send every pick to a command
fd -t f | fzf -m --preview 'bat --color=always {}' | xargs nvim
# what: Tab marks several files; all chosen paths go to nvim. Use the -0 / xargs -0 form (§3) if names can have spaces.
```

```sh
# Toggle the preview, size the window
fd -t f | fzf --preview 'bat --color=always {}' \
    --preview-window 'right,60%,border-left' --bind 'ctrl-/:toggle-preview'
# what: ctrl-/ hides/shows the preview; --preview-window controls side, size, border — handy on a narrow pane.
```

---

## 3. NUL-safety — spaces in filenames

Newline-separated lists break on any path with a space or newline: `xargs` splits `my file.ts` into two
"files". The fix is **NUL separation** — `-0`/`--null` on the producer *and* `-0` on `xargs`:

```sh
fd -t f -0 | xargs -0 nvim          # fd: -0 NUL-separates paths
rg -l -0 'TODO' | xargs -0 nvim     # rg: -l lists matching files, -0 (==--null) NUL-terminates them
```

```sh
# Find files containing `foo`, rewrite foo→bar in each (ripgrep FAQ recipe)
rg -l -0 'foo' | xargs -0 sed -i 's/foo/bar/g'
# what: the NUL join makes the in-place edit safe for any filename.
# macOS: BSD sed needs an arg — `sed -i '' 's/foo/bar/g'` (or `brew install gnu-sed` and use `gsed`).
```

> **Rule of thumb:** the moment a pipe ends in `xargs`, reach for `-0` on both ends. It's the same
> discipline as the classic `find -print0 | xargs -0`.

---

## 4. Live-grep → jump to the line

*The recipe that replaces an IDE's "Find in Files".* `fzf` runs the UI; `rg` re-runs on **every
keystroke** via `change:reload`; Enter opens the hit **at its line** in nvim. Straight from fzf's
[`ADVANCED.md`](https://github.com/junegunn/fzf/blob/master/ADVANCED.md), tidied:

```sh
RG='rg --column --line-number --no-heading --color=always --smart-case'
fzf --ansi --disabled \
    --bind "start:reload:$RG {q}" \
    --bind "change:reload:sleep 0.1; $RG {q} || true" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,+{2}+3/3' \
    --bind 'enter:become(nvim {1} +{2})'
```

Why each flag is there:

| Flag | Role |
|---|---|
| `--disabled` | fzf **stops** fuzzy-filtering; `rg` is the filter now |
| `--ansi` | render `rg`'s `--color=always` output |
| `change:reload:… {q}` | re-run `rg` with the typed query `{q}` on each keystroke (`sleep 0.1` debounces) |
| `--delimiter :` | split each `file:line:col:text` line into fields `{1}`/`{2}`/`{3}` |
| `--preview 'bat … --highlight-line {2}'` | preview the file with the matched line lit |
| `become(nvim {1} +{2})` | open **file `{1}` at line `{2}`** |
| `\|\| true` | keep fzf alive when `rg` finds nothing |

> **Make it an alias.** Drop the block into a function `rgf() { … }` in `~/.zshrc.local` (git-ignored,
> [`config.md`](../.claude/rules/config.md#secrets--machine-local-overrides)) and you have a one-word
> project-wide search that lands your cursor on the match.

---

## 5. Into Neovim, and back out

Neovim is both a **sink** (pull results in) and a **source** (push buffer text out to the shell).
Every item cites a `:help` tag.

### Shell → editor

```sh
rg foo | nvim -                       # stdin → a scratch buffer            (:h --)
nvim +42 file                         # open at line 42 (+/pat = first match) (:h -+)
nvim -q <(rg --vimgrep 'pat')         # quickfix from a search; jump to first  (:h -q)
rg --vimgrep 'pat' | nvim -q -        # quickfix, errorfile read from stdin    (:h -q)
rg -l 'pat' | xargs nvim -p           # one tab per matching file (-o = splits) (:h -p / :h -o)
```

### Editor → shell (staying in nvim)

```vim
:set grepprg=rg\ --vimgrep     " point :grep at ripgrep (:h 'grepprg')
:grep pattern                  " matches → quickfix, jump to first (:h :grep)
:%!jq .                        " pipe the whole buffer through jq  (:h :range!)
:'<,'>!sort                    " filter the visual selection       (:h :range!)
:r !date                       " read a command's output into the buffer (:h :r!)
:!make                         " run a shell command, non-interactively  (:h :!cmd)
:terminal                      " an interactive shell in a buffer (:h :terminal)
```

> **Two parse-option gotchas.** `:grep` parses `rg` output with **`grepformat`**, but `-q`/`:cfile`
> parses it with **`errorformat`** — same `rg --vimgrep` output, two different options; set the one that
> matches the path you use. And `:!cmd` is a **pipe, not a tty** — interactive tools (`less`, a REPL,
> `lazygit`) must go through `:terminal`, not `:!`.

> **The ergonomic path.** You rarely type `:grep` by hand — LazyVim's `<leader>/` (Grep, root dir) is
> the live picker over the same engine ([`nvim/README.md`](../nvim/README.md#3-complete-keybinding-reference)).
> Use the raw commands above when you're *scripting* the editor, the picker when you're *driving* it.

---

## 6. Into Claude Code, and back out

Claude Code is a **reasoning sink** — pipe it text and it answers. Verified against the
[CLI reference](https://code.claude.com/docs/en/cli-reference) and
[interactive-mode](https://code.claude.com/docs/en/interactive-mode) docs.

### Shell → Claude (headless `-p`)

```sh
rg -n 'TODO|FIXME' | claude -p "Summarize these TODOs and group them by file."
git diff | claude -p "Review this diff. Flag anything risky; suggest nothing cosmetic."
cat error.log | claude -p "What's the root cause? Give me the one line to change."
fd -e ts | claude -p "Which of these files likely hold auth logic? List paths only."
```

- **`-p` / `--print`** runs one-shot, non-interactive, and reads **stdin** combined with your prompt —
  "`cat file | claude -p "query"`" is the documented shape.
- **Route the answer onward** with a normal pipe: `… | claude -p "…" | tee notes.md`, `… | pbcopy`,
  `> out.md`.
- **Machine-readable output:** `claude -p "…" --output-format json | jq` (`text` default ·
  `stream-json` for realtime).
- **Continue a thread in a script:** `claude -c -p "now fix the first one"` (`-c`/`--continue` resumes
  the most recent conversation in this dir; `-r <id>` resumes a specific one).

> ⚠️ **`-p` has no memory across calls** — each invocation is a fresh context unless you add `-c`. And
> each call costs like a prompt; don't loop it over a thousand files without thinking. The repo's `yolo`
> alias (`claude --dangerously-skip-permissions`, ≡ `--permission-mode bypassPermissions`) is opt-in and
> **never** the default ([`zsh/README.md`](../zsh/README.md#3-complete-reference--aliases--shell-keys)).

### Shell → an *interactive* Claude session

Inside a running `claude` (not `-p`), two prefixes pull the shell in without leaving the chat:

| Type | Does |
|---|---|
| `! npm test` | **Shell mode** — runs the command, adds its output to the session, and Claude responds to it |
| `@src/auth.ts` | **File mention** — pulls the file into context (Tab-completes the path) |

`@path` beats `cat file \| claude -p` for an interactive session: it's tracked as a real file reference,
not a one-off paste, so Claude can re-read it as it changes.

---

## 7. Pickers as pipe nodes — zoxide & yazi

Both a **directory jumper** and a **file manager** can act as an interactive *producer* in a pipe.

```sh
zi                              # zoxide: fuzzy-pick a known dir (via fzf) and cd into it
cd "$(zoxide query -i)"         # same, but the path flows through a pipe you control
```

```sh
# yazi as a file picker feeding another command (chooser mode)
tmp="$(mktemp)"; yazi --chooser-file="$tmp"; nvim "$(cat "$tmp")"; rm -f "$tmp"
# what: --chooser-file makes yazi WRITE the selection to a file and exit instead of opening it — so nvim consumes the pick.
```

> **`cd`-on-quit for `y`.** The bare `y='yazi'` alias doesn't move the shell on quit. To land in the
> last-browsed dir, add the upstream `y()` wrapper (it runs `yazi --cwd-file` and `cd`s there on `q`) to
> `~/.zshrc.local` — full snippet in [`zsh/README.md §5.13`](../zsh/README.md#513-yazi--a-tui-file-manager).

---

## 8. Ready-made recipes

| I want to… | Do this |
|---|---|
| Open a file I can't name | `fd -t f \| fzf --preview 'bat --color=always {}' --bind 'enter:become(nvim {})'` |
| Search code and edit the hit | the [live-grep block](#4-live-grep--jump-to-the-line) (`rgf`) → Enter lands in nvim at the line |
| Edit every file matching a pattern | `rg -l -0 'pattern' \| xargs -0 nvim -p` |
| Bulk find-and-replace | `rg -l -0 'foo' \| xargs -0 sed -i 's/foo/bar/g'` *(macOS: `sed -i ''`)* |
| Review my changes with Claude | `git diff \| claude -p "Review this diff; flag risky changes."` |
| Explain a failing test run | `!` inside Claude: `! npm test` → Claude reads the failure and responds |
| Pretty-print JSON in a buffer | in nvim: `:%!jq .` |
| Pull a command's output into a buffer | in nvim: `:r !rg --stats 'pattern'` |
| Jump to a project, then grep it | `z termi` → `rgf` |

---

## 9. Gotchas

- **`xargs` + spaces → use `-0` on both ends** ([§3](#3-nul-safety--spaces-in-filenames)). The single
  most common silent breakage.
- **`sed -i` is GNU syntax.** macOS/BSD `sed` needs `sed -i '' '…'`; or `brew install gnu-sed` → `gsed`.
- **`:grep` vs `-q` parse differently** — `grepformat` for `:grep`, `errorformat` for `-q`/`:cfile`
  ([§5](#5-into-neovim-and-back-out)).
- **`:!cmd` isn't a tty** — interactive TUIs need `:terminal`.
- **`claude -p` is stateless per call** — add `-c` to continue; mind the per-call cost.
- **Inside a Zellij pane, `Ctrl`-keys may be eaten** — if fzf's `Ctrl-`bindings or atuin's `Ctrl-R`
  "do nothing", the pane is in Normal mode; press `Alt+d` to lock it to the app
  ([`zsh/README.md §9`](../zsh/README.md#9-living-inside-a-zellij-pane)).

### Go deeper (upstream)

- fzf recipes (`become`, live-reload, field indices) → [ADVANCED.md](https://github.com/junegunn/fzf/blob/master/ADVANCED.md)
  · [README](https://github.com/junegunn/fzf#readme)
- ripgrep flags & FAQ (`--vimgrep`, `-l`, `--null`) → [GUIDE.md](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
  · [FAQ.md](https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md)
- Neovim pipe endpoints → `:h --` · `:h -q` · `:h :range!` · `:h :terminal` ([neovim.io/doc](https://neovim.io/doc/))
- Claude Code CLI → [cli-reference](https://code.claude.com/docs/en/cli-reference) ·
  [interactive-mode](https://code.claude.com/docs/en/interactive-mode)

---

> Part of [terminal-stack](../README.md) · per-tool keys in [zsh](../zsh/README.md) ·
> [nvim](../nvim/README.md) · learn the stack in [guide.md](guide.md).
