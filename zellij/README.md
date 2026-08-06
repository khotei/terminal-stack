# 🧬 Zellij — the multiplexer layer

Sessions, tabs, and panes — the workspace that hosts **Neovim │ Claude Code** side by side. Zellij is
a modern, modal alternative to tmux: discoverable (it shows its keys), KDL-configured, sessions as
workspaces.

**This file is the single source for Zellij in this stack** — the mental model, every keybinding, the
fast recipes, and the config rationale. Nothing to hunt across other files.

- **Files:** [`config.kdl`](./config.kdl) → `~/.config/zellij/config.kdl`,
  [`layouts/dev.kdl`](./layouts/dev.kdl) → `~/.config/zellij/layouts/dev.kdl`
- **Validate:** `zellij --config zellij/config.kdl setup --check` (run by `/check` + CI)
- **Feature:** `F-MUX-001` · **Upstream:** <https://zellij.dev/documentation>

### Contents

1. [The mental model](#1-the-mental-model) — modal, no prefix, and the one reflex that outranks all keys
2. [Quick start: the moves that pay rent](#2-quick-start--the-moves-that-pay-rent)
3. [Complete keybinding reference](#3-complete-keybinding-reference) — every mode, every key
4. [Recipes — "I want to… → do this"](#4-recipes--i-want-to--do-this)
5. [Sessions are workspaces](#5-sessions-are-workspaces) — plus [fuzzy-jump with choose-tree](#fuzzy-jump-anywhere--ctrlo-f-choose-tree) · [Zellij from the shell — CLI flags](#zellij-from-the-shell--cli-flags)
6. [Advanced pane craft](#6-advanced-pane-craft)
7. [Anti-patterns](#7-anti-patterns)
8. [Living with Claude Code / Neovim — manual lock](#8-living-with-claude-code--neovim--manual-lock)
9. [The status bar](#9-the-status-bar) · [The `dev` layout](#10-the-dev-layout)
10. [Settings reference](#11-settings-reference-config-rationale) · [Reload & verify](#12-reload--verify) · [Install](#13-install)

---

## 1. The mental model

Zellij is **modal**, not prefix-based. Instead of tmux's *hold a prefix, then a key*, you **switch
into a mode**, press plain keys while it's active, then **leave**:

```
Normal ──[ Ctrl+<mode> ]──▶ <mode> ──[ act with single keys ]──▶ [ Enter | Esc ]──▶ Normal
```

The **status bar always lists the active mode's keys** — it is the live cheatsheet; the tables below
are the offline copy (Zellij 0.44.x defaults; this config keeps them, so **no prefix**).

**The one reflex that outranks every hotkey.** Zellij and the app inside a pane both want the
keyboard, and they clash on `Ctrl` keys — Zellij's `Ctrl+t`/`Ctrl+s`/`Ctrl+p` against Claude Code's
`Ctrl+t`/`Ctrl+r` and nvim's `Ctrl+p`. (`Ctrl+h`/`Ctrl+o`/`Ctrl+n` are unbound here so the app gets
them even unlocked — their modes live behind `Ctrl+p`.) This config gives you **one manual switch** to
decide who wins ([§8](#8-living-with-claude-code--neovim--manual-lock)):

> **`Ctrl+q`** — toggle **Locked** ⇄ Normal. In Locked, Zellij hands the pane *every* keystroke (the app
> gets its `Ctrl`s back); press `Ctrl+q` again to take the multiplexer back. Same `Ctrl` modifier as
> every other action — the hand never swaps to `Alt` mid-flow.

So the reflex to build: **entered nvim/Claude and its `Ctrl` keys "don't work"? Zellij is eating them —
`Ctrl+q` to lock the pane.** There is **no** auto-locking here; you hold the lock yourself, by choice.

---

## 2. Quick start — the moves that pay rent

Learn these ten before anything else; they cover ~90% of real use. (Grouped by *reflex*; the exhaustive
per-mode tables are in [§3](#3-complete-keybinding-reference).)

| Reflex | Keys |
|---|---|
| Lock ⇄ unlock a pane (hand keys to the app, or take Zellij back) | `Ctrl+q` |
| Jump **straight** to a tab | `Ctrl+t` then `1`…`9` |
| Toggle to the last tab (A↔B) | `Ctrl+t` then `Tab` |
| Glide focus across panes *and* tabs | `Alt+h` / `Alt+l` (rolls into the next tab at the edge) |
| Focus a pane up / down | `Alt+k` / `Alt+j` |
| Zoom the focused pane full-screen | `Ctrl+p` then `f` (again to un-zoom) |
| Throwaway popup pane over your work | `Alt+f` (toggle floating) |
| New split | `Alt+n` |
| Name this tab (so `Ctrl+t N` means something) | `Ctrl+t` then `r` |
| See / switch / resurrect sessions | `Ctrl+p o` then `w` |
| Fuzzy-jump to any tab / pane (even in another session) | `Ctrl+p o` then `f` |

> `Alt+i` / `Alt+o` **move** (reorder) the tab — they don't switch to it. Mnemonic: `h/l` = go,
> `i/o` = shove.

---

## 3. Complete keybinding reference

**Enter a mode from Normal**, act with single keys, `Enter`/`Esc` to leave (`Ctrl+c` also backs out of
Scroll/Search):

| Key | Mode | For |
|---|---|---|
| `Ctrl+p` | **Pane** | split · focus · close · fullscreen · float · pin · rename |
| `Ctrl+t` | **Tab** | new · close · switch · jump-to-number · break out |
| `Ctrl+p` `R` | **Resize** | grow / shrink the focused pane *(repo — default `Ctrl+n` freed for nvim's completion-next)* |
| `Ctrl+p` `m` | **Move** | relocate a pane within the layout *(repo — default `Ctrl+h` freed for nvim's window-left)* |
| `Ctrl+s` | **Scroll** | scrollback · search · edit-scrollback in nvim |
| `Ctrl+p` `o` | **Session** | detach · session / plugin manager · config *(repo — default `Ctrl+o` freed for nvim's jumplist-back + Claude Code)* |

**Pane** (`Ctrl+p`) — move focus with `h/j/k/l` or arrows:

| Key | Action | Key | Action |
|---|---|---|---|
| `n` | new pane | `x` | close focused |
| `d` / `r` | split down / right | `f` | fullscreen (zoom) toggle |
| `s` | new **stacked** pane | `w` | floating panes toggle |
| `e` | embed ↔ float | `i` | pin a floating pane (always-on-top) |
| `c` | rename pane | `z` | toggle pane frames (declutter / +2 cols) |
| `p` | focus the **previous** pane | | |

**Tab** (`Ctrl+t`):

| Key | Action | Key | Action |
|---|---|---|---|
| `n` | new tab | `1`…`9` | jump to tab N |
| `x` | close tab | `←`/`→` (or `h/j/k/l`) | previous · next tab |
| `r` | rename tab | `Tab` | toggle last-active |
| `s` | **sync** — broadcast typing to every pane in the tab | | |
| `b` | break pane into its own tab | `[` / `]` | break pane to prev / next tab |

> **Every mode is sticky — repeat, don't re-enter.** A mode stays live until `Enter`/`Esc` (or its own
> `Ctrl+…` toggle), so once inside you **keep tapping** its single keys — the *same* reflex in all of
> them:
> - **Tab / Pane** — tap the **arrows** (or `h/j/k/l`) to walk tab-by-tab / pane-by-pane while watching
>   the bar; the move for when you *don't recall the number* (browse, don't `Ctrl+t` `N`).
> - **Resize** — `=` `=` `=` grows in steps · **Move** — `h h h` shoves the pane across slots ·
>   **Scroll** — hold `j`/`k`.
>
> Mirror image of the `Alt+…` shortcuts, which fire *one* hop from Normal: the modes are for
> *repeating* — hunting, sizing, sculpting.

**Resize** (`Ctrl+p` `R`) — grow / shrink the focused pane in steps (sticky: keep tapping). *(repo:
the default `Ctrl+n` entry is unbound so `<C-n>` always reaches nvim, lock or no lock.)*

| Key | Action |
|---|---|
| `h/j/k/l` (or arrows) | grow the pane toward that side |
| `H/J/K/L` | shrink from that side |
| `=` / `-` | grow / shrink on **all** sides at once |

**Move** (`Ctrl+p` `m`) — relocate the *pane itself* (not the focus) within the layout. *(repo:
the default `Ctrl+h` entry is unbound so `<C-h>` always reaches nvim, lock or no lock.)*

| Key | Action |
|---|---|
| `h/j/k/l` (or arrows) | push the pane that way |
| `n` / `Tab` | send it to the next slot |
| `p` | send it to the previous slot |

**Scroll** (`Ctrl+s`) — read back through a pane's output; also the gateway to search and the nvim dump.

| Key | Action |
|---|---|
| `j` / `k` | one line down / up |
| `d` / `u` | half-page down / up |
| `PageDown` / `PageUp` (or `Ctrl+f` / `Ctrl+b`) | full page down / up |
| `s` | enter **Search** (below) |
| `e` | dump the scrollback into nvim — read/copy it as a file (copy-mode) |
| `Ctrl+c` | jump to bottom and exit |

**Search** (`s` from Scroll) — live find within the scrollback.

| Key | Action |
|---|---|
| type term + `Enter` | search |
| `n` / `p` | next / **previous** hit — it's `p`, **not** Vim's `N` |
| `c` | toggle case-sensitivity |
| `w` | toggle wrap-around |
| `o` | toggle whole-word |
| `Ctrl+c` | exit to the bottom |

**Session** (`Ctrl+p` `o`) — the session and the tree beneath it. *(repo: the default `Ctrl+o`
entry is unbound so `<C-o>` always reaches nvim and Claude Code, lock or no lock.)*

| Key | Action |
|---|---|
| `w` | **session manager** — fuzzy-switch between / resurrect past sessions |
| `f` | **choose-tree** (plugin) — fuzzy tree of *sessions → tabs → panes*; `1-9`/`A-Z` jump straight to one. The pane-level finder `w` isn't — see [§5](#5-sessions-are-workspaces) |
| `d` | detach (leave it running; reattach later with `zellij attach`) |
| `c` | configuration |
| `p` | plugin manager |
| `l` | layout manager |
| `a` | about |
| `s` | share the session over the web |

**Skip the mode dance — direct `Alt` shortcuts.** For the moves you make constantly, hold `Alt` from
Normal and act in one stroke:

| Keys | Action |
|---|---|
| `Alt+n` | new pane |
| `Alt+f` | toggle floating panes (the "popup" window) |
| `Alt+←/→/↑/↓` or `Alt+h/j/k/l` | move focus (`h`/`l` cross into adjacent tabs) |
| `Alt+i` / `Alt+o` | shift the current tab left / right |
| `Alt+=` / `Alt+-` | resize the focused pane |
| `Alt+[` / `Alt+]` | previous / next swap-layout |

> These `Alt` keys are deliberately swallowed inside a **locked** Claude/nvim pane (that's the point —
> the app gets them). Use them from a shell pane, or `Ctrl+q` out of lock first ([§8](#8-living-with-claude-code--neovim--manual-lock)).

---

## 4. Recipes — "I want to… → do this"

**Stop cycling `next-next-next` through tabs.** Name them once (`Ctrl+t` `r` → `edit`, `logs`, `agent`),
then `Ctrl+t` `<number>` jumps directly — or, from any shell, jump by *name*:
`zellij action go-to-tab-name logs` ([cli-actions](https://zellij.dev/documentation/cli-actions)). The
bottom bar always shows the tab list, and with `mouse_mode true` a **click on a tab** switches to it.

**Peek at something without wrecking your layout.** `Alt+f` floats a pane on top; do the quick thing;
`Alt+f` hides it again (it keeps its state). Want it to stay up while you work underneath? **Pin it:**
`Ctrl+p` `i` (or click the `PIN` badge) makes a floating pane always-on-top
([pinned panes, 0.42](https://zellij.dev/news/stacked-resize-pinned-panes/)).

**Type one command into every pane at once.** `Ctrl+t` `s` toggles **tab sync** — keystrokes broadcast
to *all* panes in the tab: `git pull` three repos, restart four services, `tail -f` a fleet identically.
The bar shows a `SYNC` marker; `Ctrl+t` `s` again stops it
([sync-tab](https://zellij.dev/documentation/keybindings-possible-actions.html)). Broadcast is
per-*tab*, so corral the panes you want yoked into their own tab first — then break them back out with
`Ctrl+t` `b`.

**Ping-pong between two panes without aiming.** `Ctrl+p` `p` snaps to the **previously focused** pane —
the pane-level twin of `Ctrl+t` `Tab` for tabs. When you're bouncing editor↔shell it beats aiming
`Alt+h/j/k/l` at a moving target.

**Strip the chrome for a clean copy (or two more columns).** `Ctrl+p` `z` toggles **pane frames** off:
no border glyphs to snag in a mouse-drag selection, and the content reclaims the frame's cells for wide
output (a 180-col diff, a table). Toggle back the same way — it's global, not per-pane.

**Read a pane like a document — scroll, select, copy, search.** This is Zellij's answer to tmux's
*copy-mode*: freeze a pane's output and move through it as text. Works over **any** pane — a shell, a
build log, `claude`, a `tail -f`. There are **three tiers**; reach for the lightest that does the job.

| When you want to… | Do this | Why this tier |
|---|---|---|
| Grab a line or two, right now | **Drag-select with the mouse** — `copy_on_select` copies on release; the wheel scrolls | Zero mode-switch, and it works even inside a *locked* Claude pane |
| Scroll back and *find* something, keyboard-only | `Ctrl+s` → **Scroll**: `j/k` line · `d/u` half-page · `Ctrl+f`/`Ctrl+b` page. `s` starts a **search** — type, `Enter`, then `n`/`p` walk the hits. `Ctrl+c` snaps to the bottom and exits | Stays in the pane, incremental, no editor spin-up |
| Yank a stack trace · Vim-select a block · save it out | `Ctrl+s` → `e` — **EditScrollback** dumps the whole buffer into **nvim** (`scrollback_editor`) | The *full* editor: `v`/`V` visual, `/` + `n`, macros, `:w /tmp/err.log` — more than copy-mode ever gave |

> **The locked-pane catch (Claude / nvim).** If you've **locked** the pane (`Ctrl+q`), `Ctrl+s` goes *to
> the app*, not Zellij. Reflex: **`Ctrl+q` first** (unlock → Normal), *then* `Ctrl+s` `e`; `Ctrl+q` again to
> re-lock ([§8](#8-living-with-claude-code--neovim--manual-lock)). For a one-off grab, skip all that — a
> **mouse drag** copies without unlocking.

> **The alt-screen catch (Claude in fullscreen rendering).** Claude Code's
> [fullscreen renderer](https://code.claude.com/docs/en/fullscreen) (`/tui fullscreen`) draws on the
> *alternate screen*, like nvim — the conversation lives **outside** the pane's scrollback, so `Ctrl+s`
> Scroll sees only what's on screen, not the history above. Hand it back from *inside Claude*: **`Ctrl+o`**
> (transcript) then **`[`** dumps the whole conversation into the pane's native scrollback — and now
> `Ctrl+s` Scroll, its search, the mouse-wheel, and `e`→nvim all reach it again. (The **classic** renderer
> already keeps the conversation in scrollback, so there Scroll just works — this catch is fullscreen-only.)

**When to pick which — and a few secrets:**

- **Past a glance? Go straight to `e` (nvim).** Searching a 5k-line log is faster with `/` `n` `*` than
  stepping hits in Scroll mode, and you can `V`-select a range and `:w` it to a file. Scroll mode is for
  *"where did that error scroll off to,"* EditScrollback for *"I need to work with this output."*
- **`Ctrl+c` = "done, back to live."** It scrolls to the bottom **and** leaves Scroll mode in one key —
  the clean way to rejoin a running `tail`, no `Esc`-then-jump.
- **Search from where you are.** In Scroll mode you can `k` up a bit, *then* `s` — the search starts at
  your cursor, and `n`/`p` walk matches without losing your place.
- **No copy key on purpose.** `copy_on_select` makes *releasing the mouse* the copy — which is why the
  default `Alt+c` Copy bind is left commented in the scroll block.

**Run a command *into* a new pane from the shell** — no mode dance: `zellij run -- cargo test` (new
pane running it), `zellij run -f -- htop` (floating), `zellij edit ./src/main.rs` (open a file)
([run & edit](https://zellij.dev/documentation/zellij-run-and-edit.html)). Great inside scripts/hooks.

**Make a workspace reproducible.** You already have [`layouts/dev.kdl`](./layouts/dev.kdl) —
`zellij --layout dev` rebuilds the editor │ agent split every time. To keep a layout you arranged **by
hand**, dump it to a file from *inside* that session: `zellij action dump-layout >
zellij/layouts/mine.kdl` ([dump-layout](https://zellij.dev/documentation/cli-actions)) — **not** the old
`zellij layout dump` from stale blog posts; Zellij layouts are KDL now. Then `zellij --layout mine`
(name = filename, no `.kdl`) rebuilds it into any new session. `dump-layout` captures the **shape** —
panes, tabs, and the `command` for panes you launched with one — **not** scrollback or a running
program's state, and it bakes in each pane's absolute `cwd`; trim those for a portable, general-purpose
layout (compare the deliberately minimal `dev.kdl`). Validate with `zellij setup --check` before commit.

> **A layout outlives every session — once you commit it.** A layout is a *file*, not session state:
> `kill-all-sessions`, `delete-all-sessions`, clearing the cache — none of it touches the layout. And
> because `install.sh` symlinks `zellij/` into `~/.config/zellij`, the dump above already landed in the
> repo working tree. **Commit it** and the layout returns on every machine `install.sh` runs on, whatever
> you deleted — that, not session metadata, is how a hand-built workspace becomes truly permanent.

---

## 5. Sessions are workspaces

Think of a **session per project**, not one giant session. This is where Zellij out-classes a pile of
terminal tabs.

- **Detach, don't kill.** `Ctrl+p o` `d` detaches: the session (and every running process — builds,
  `claude`, servers) keeps living in the background. Re-enter with `zellij attach <name>` (`zellij a`);
  `zellij ls` lists them ([session tutorial](https://zellij.dev/tutorials/session-management/)).
- **Survive a reboot — resurrection.** Zellij stores each session's *metadata*: the pane/tab layout
  **and** the command each pane ran. After a crash or restart, `Ctrl+p o` `w` → pick an **exited**
  session → it rebuilds the workspace. Rename an exited one with `Ctrl+r` in the manager to label it
  before resurrecting.
- **Switch projects.** `Ctrl+p o` `w` is a fuzzy, type-to-filter picker over all sessions — the fast path
  between repos without leaving Zellij.

> *Resurrection* = rebuilding a session from saved layout metadata, not from a live process. The
> processes are gone; the shape (and the commands to relaunch them) comes back.

### Fuzzy-jump anywhere — `Ctrl+p o f` (choose-tree)

The built-in manager (`Ctrl+p o w`) stops at the **session** level. To jump *inside* — to a named tab or
pane, or across sessions in one motion — this stack adds **choose-tree**
([laperlej/zellij-choose-tree](https://github.com/laperlej/zellij-choose-tree), a clone of tmux's
`choose-tree`) on **`Ctrl+p o f`**. It opens a floating **tree of every session → its tabs → their
panes**:

| In the finder | Does |
|---|---|
| *type* | fuzzy-filter the whole tree by name |
| `↑`/`↓` (or `k`/`j`) | move the cursor |
| `→`/`←` (or `l`/`h`) | unfold / fold a session or a tab |
| `1`–`9`, `A`–`Z` | **jump straight** to that row — the label-jump muscle memory from tmux `display-panes` |
| `Enter` | switch to the selection — session, tab, **or pane** |
| `x` | kill the selected session |

Name your tabs (`Ctrl+t` `r`) and panes (`Ctrl+p` `c`) so the filter has something to match — then
`Ctrl+p o f` → type `db` → `Enter` drops you on the `db` pane wherever it lives.

> **It is a picker, not a literal `display-panes` overlay.** tmux flashes a number *on each pane*; a
> Zellij plugin can only paint its own pane, so it can't — native support is
> [issue #790, still open](https://github.com/zellij-org/zellij/issues/790). choose-tree gives the same
> reflex (a labelled list you filter and jump from) as a floating list instead. The `.wasm` is vendored
> in [`plugins/`](./plugins/) so it travels with the repo (`install.sh` symlinks it into place); the
> first launch may pause a beat while Zellij compiles it.

### Zellij from the shell — CLI flags

The whole multiplexer is drivable from a plain shell prompt (or a script/hook), no mode dance. The
tables below are the offline reference for the `zellij` binary itself — pick a goal, read the command.
Every flag is confirmed against `zellij --help` on **0.44.3**; short forms in `()`. Aliases already in
this stack: **`zja`** = `zellij attach`, **`zjd`** = `zellij --layout dev` (zsh).

**Start & name a session:**

| I want to… | Command |
|---|---|
| Start a new session | `zellij` |
| Start a **named** session | `zellij -s <name>` (`--session`) |
| Start with a layout | `zellij --layout <name\|path>` (`-l`) — *inside* a session this adds tabs instead |
| Force a **new** session with a layout | `zellij --new-session-with-layout <name\|path>` (`-n`) — always new, even when nested |
| Tweak startup behaviour | `zellij options <flag>…` (e.g. `--default-layout compact`) |

**Attach · list · kill · delete:**

| I want to… | Command |
|---|---|
| Attach to a session | `zellij attach <name>` (`a` · `zja`) |
| Attach, creating it if absent | `zellij attach -c <name>` (`--create`) |
| List running sessions | `zellij ls` (`list-sessions`) |
| Kill one · all running sessions | `zellij kill-session <name>` (`k`) · `zellij kill-all-sessions` (`ka`) |
| Permanently delete one · all *exited* (resurrectable) sessions | `zellij delete-session <name>` (`d`) · `zellij delete-all-sessions` (`da`) |

> **Kill vs delete.** `kill-*` stops a *running* session (its resurrectable metadata survives — you can
> still bring it back via `Ctrl+p o` `w`). `delete-*` erases an already-exited session's saved metadata for
> good ([session resurrection](https://zellij.dev/documentation/session-resurrection.html)).

**Run a command / open a file in a pane** — the fast path from a shell or script (recipe form in
[§4](#4-recipes--i-want-to--do-this)):

| I want to… | Command |
|---|---|
| Run a command in a **new pane** | `zellij run -- <cmd>` |
| …floating · in a direction | `zellij run -f -- <cmd>` (`--floating`) · `-d right\|down` (`--direction`) |
| …named · auto-close when it exits | `zellij run -n build -- <cmd>` (`--name`) · `-c` (`--close-on-exit`) |
| …in place of the current pane | `zellij run -i -- <cmd>` (`--in-place`) |
| Open a **file** in a pane | `zellij edit <file>` (`e`) |
| …floating · in place · at a line | `zellij edit -f <file>` · `-i <file>` · `-l <N> <file>` (`--line-number`) |

**Script the running session** — `zellij action <sub>` targets the current session (or another with
`zellij --session <name> action …`). Full list: [cli-actions](https://zellij.dev/documentation/cli-actions).

| I want to… | Command |
|---|---|
| Dump the live layout to KDL | `zellij action dump-layout > mine.kdl` |
| New tab, named / from a layout | `zellij action new-tab --name <n> --layout <l>` |
| Jump to a tab by name (create if absent) | `zellij action go-to-tab-name <name> [--create]` |
| Rename the current tab | `zellij action rename-tab <name>` |
| New pane, directional / floating / running a cmd | `zellij action new-pane [-d <dir>] [-f] -- <cmd>` |
| List panes / tabs (machine-readable) | `zellij action list-panes` · `list-tabs` `[--json]` (`-j`) |
| Close the focused pane | `zellij action close-pane` |
| Type text into the pane | `zellij action write-chars <text>` |
| Launch/focus a plugin · pipe data to one | `zellij action launch-or-focus-plugin <url>` · `zellij action pipe --name <n> -- <data>` |

**Setup & introspection:**

| I want to… | Command |
|---|---|
| Validate config + layouts | `zellij setup --check` (the `/check` gate) |
| Print the effective config / a built-in layout | `zellij setup --dump-config` · `--dump-layout <name>` |
| Shell completion · auto-start snippet | `zellij setup --generate-completion <shell>` · `--generate-auto-start <shell>` |

---

## 6. Advanced pane craft

- **Stacked panes** — layer panes in one slot, each keeping its title bar so you can navigate the
  stack. Open with `Ctrl+p` `s`; move through the stack with `Alt+↑`/`Alt+↓`
  ([stacked panes](https://zellij.dev/news/stacked-panes-swap-layouts/)). Since 0.42, **resize is
  stacked by default**: `Alt+=` grows the focused pane ~30% and tucks neighbors into a stack instead of
  squeezing everything ([stacked resize](https://zellij.dev/tutorials/stacked-resize/)).
- **Swap layouts** — `Alt+[` / `Alt+]` cycle *predefined arrangements* of the current panes, so you
  reflow a tab instead of hand-resizing ([swap layouts](https://zellij.dev/documentation/swap-layouts.html)).
  The mental model: panes aren't a "group" — they just belong to the **tab**; a swap layout is a
  *template* for arranging however many panes the tab holds, and cycling reshapes them **all at once**
  (this is how you turn a top/bottom split into side-by-side without `Move`). The label at the far
  right of the status bar (`VERTICAL`, `HORIZONTAL`, …) names the active template. Hand-resize or
  `Move` a pane and you drift *off-template* — the next `Alt+]` snaps everything back into a template,
  which is why a hand-tuned layout can seem to "jump".
- **Embed ↔ float** — `Ctrl+p` `e` turns a floating pane into a tiled one (or back); `Ctrl+p` `w`
  toggles the whole floating layer.
- **Break a pane out** — `Ctrl+t` `b` moves the focused pane into its own tab; `Ctrl+t` `[` / `]` sends
  it to the previous/next tab.
- **Resize — usually *without* the mode.** `Ctrl+p` `R` opens Resize (`h/j/k/l` grow a side · `H/J/K/L`
  shrink · `=`/`-` all sides), but the fast paths skip it: `Alt+=` / `Alt+-` nudge straight from Normal,
  and `Alt+[` / `Alt+]` reflow the *whole* tab via swap-layouts. Reserve the mode for fine, one-side
  tuning; reach for `Alt+=` / swap-layouts for everything else.
- **Move the pane, not the focus** — two verbs people conflate. `Alt+h/j/k/l` moves *focus* (which pane
  you're in); `Ctrl+p` `m` (**Move** mode) relocates the *pane itself* — `h/j/k/l` shoves it, `n` / `Tab`
  cycles it through the layout's slots (`p` backwards). Use Move to reshuffle a mosaic without closing
  and reopening anything.

---

## 7. Anti-patterns

| Don't | Do instead |
|---|---|
| Arrow through tabs `→ → →` to find one | Name tabs, `Ctrl+t N` or `go-to-tab-name` |
| Fight a locked pane when a hotkey "won't work" | `Ctrl+q` to unlock (or lock) |
| Rebuild your layout by hand every morning | `zellij --layout dev`, or resurrect via `Ctrl+p o w` |
| Cram 12 panes into one tab | Split across named tabs / a session per project |
| `exit` a session you'll want back | `Ctrl+p o d` detach — processes keep running |

---

## 8. Living with Claude Code / Neovim — manual lock

Zellij's modal keys (`Ctrl+p`/`Ctrl+t`/`Ctrl+s`) sit on the same `Ctrl` chords that
the app *inside* a pane wants — Claude Code's `Ctrl+t`/`Ctrl+r`, nvim's `Ctrl+p`. (`Ctrl+h`/`Ctrl+o`/
`Ctrl+n` are already unbound — those reach the app even unlocked.)
Whoever isn't locked out wins. You arbitrate with **one manual switch** — there is **no** auto-locking
plugin (a deliberate choice: predictable control over convenience):

- **`Ctrl+q` toggles Locked ⇄ Normal.** In **Locked**, Zellij hands the pane *every* keystroke, so the
  app's `Ctrl` keys reach it; press `Ctrl+q` again to take the multiplexer back. It stays on the same
  `Ctrl` modifier as every other action (reclaimed from Zellij's default Quit) — the one key Locked
  mode honours, so it's always your way out.
- **`Ctrl+g` is freed** (unbound from Zellij's default lock toggle) so Claude Code's own `Ctrl+g` —
  *edit prompt in `$EDITOR`* — reaches it. Leave Locked with `Ctrl+q`, not `Ctrl+g`.

> ⚠️ **The trade-off you chose.** With no autolock, entering nvim/Claude/fzf does **not** lock the pane
> for you — until you press `Ctrl+q`, Zellij keeps eating those apps' `Ctrl` keys. The reflex: **`Ctrl+q`
> the moment a nested app's `Ctrl` key "doesn't work."** Lock it once on entry, `Ctrl+q` again on exit.

---

## 9. The status bar

The bar is Zellij's built-in [`compact-bar`](https://zellij.dev/documentation/plugin-aliases) — a
single line that is **theme-aware**: it follows `theme_dark`/`theme_light`, so it lightens with the rest
of the stack in light appearance and darkens in dark (this is what closes the auto-theme loop — a plugin
bar with hard-coded colours could not). For the current mode it shows the **mode name, that mode's keybinding
hints, and the tabs** — the live cheatsheet the tables above summarise. At the far right it also names
the active **swap layout** (`VERTICAL`, `HORIZONTAL`, …) — the template `Alt+[` / `Alt+]` cycle
([§6](#6-advanced-pane-craft)). It ships with Zellij (no wasm, no permission grant) and loads via
`default_layout "compact"` for every session.

## 10. The `dev` layout

[`layouts/dev.kdl`](./layouts/dev.kdl) opens the editor │ agent split:

```
zellij --layout dev
```

Left pane = editor, right pane (40%) = agent. Both open a shell by default; uncomment the `command`
lines to auto-launch `nvim` and `claude`. The tab is named **`dev`** (not the default `Tab #1`); rename
any tab live with `Ctrl+t` → `r`.

---

## 11. Settings reference (config rationale)

The *why* behind each key in [`config.kdl`](./config.kdl) — the config states the *what*.

| Key | Value | Why |
|---|---|---|
| `theme` | `github-light-hc` | Pre-handshake fallback only — the palette shown until Ghostty answers the light/dark query (a fraction of a second). |
| `theme_light` / `theme_dark` | `github-light-hc` / `github-dark-hc` | The pair Zellij swaps between when the terminal reports its appearance over **CSI 2031 / DSR 997** (zellij ≥ 0.44.2, answered by Ghostty). Both must be set, or auto-switching stays off. Defined in [`themes/github-high-contrast.kdl`](./themes/github-high-contrast.kdl) — auto-loaded, since `themes/` is Zellij's default `theme_dir` and `~/.config/zellij` symlinks to this folder. |
| `default_layout` | `compact` | Built-in **compact-bar** — theme-aware, shows mode + keys + tabs ([§9](#9-the-status-bar)). |
| `pane_frames` | `true` | Frames on so splits read as distinct cards; the frame lends a 1-cell content offset (Zellij has no native inner padding). |
| `ui.pane_frames.rounded_corners` | `true` | Round the frame corners — softer look; inert without `pane_frames true`. |
| `copy_on_select` | `true` | Select = copy (tmux-like). |
| `scrollback_editor` | `nvim` | "Edit scrollback" (`Ctrl+s` `e`) opens in the stack's editor. |
| `mouse_mode` | `true` | Scroll/select — and click a tab/pane to focus it. |

### Why not the built-in `ansi` theme

`theme "ansi"` looks like the zero-duplication answer — every colour an ANSI slot index, so the
multiplexer repaints from whatever palette Ghostty holds. It **breaks under GitHub High Contrast**:
that theme hard-codes the bar's background to *slot 0*, and in the GitHub HC palettes slot 0 is a
**text** colour (`#0e1116` near-black in light, `#7a828e` grey in dark) — never the terminal
background. Result: a black status bar under a white terminal. The palettes carry no light neutral at
all, so no ANSI-only theme can fix it.

Hence the local pair in [`themes/github-high-contrast.kdl`](./themes/github-high-contrast.kdl), and it
is built from **Primer's UI tokens**, not the terminal slots: `canvas.subtle` fills the bar,
`accent.emphasis` marks the focused tab and pane frame, `neutral.emphasis` the idle ones,
`success`/`danger` the exit codes. Those primitives are the same file
[github-nvim-theme](https://github.com/projekt0n/github-nvim-theme) generates from, so the bar and the
editor under it are literally the same palette — which the 16 slots could never express.

The cost is one file to keep in sync: **re-theme in `ghostty/config`, then mirror the tokens here**
(and in the three env-driven tools — [`zsh/README.md` §8](../zsh/README.md#8-one-theme-across-the-stack)).
Swapping to a theme Zellij already
[bundles](https://github.com/zellij-org/zellij/tree/main/zellij-utils/assets/themes) (catppuccin,
tokyo-night, everforest, …) removes that cost entirely — point `theme_light`/`theme_dark` at the
built-in names and delete the local file.

## 12. Reload & verify

- **Apply config:** new sessions pick it up; `zellij` options reload on session start.
- **Validate:** `zellij --config zellij/config.kdl setup --check` → `[CONFIG FILE]: Well defined.`
  (verified on zellij 0.44.3).
- **Try it now:** `make zellij` (the Docker sandbox) drops you straight into Zellij with this config.

## 13. Install

`./install.sh` (or `make install`) symlinks `zellij/` into `~/.config/zellij/`.

### Go deeper (on demand — not front to back)

- Every possible action → [keybindings-possible-actions](https://zellij.dev/documentation/keybindings-possible-actions.html)
- Write your own layouts → [creating a layout](https://zellij.dev/documentation/creating-a-layout.html)
- CLI / scripting Zellij → [cli-actions](https://zellij.dev/documentation/cli-actions)
- Plugins & aliases → [plugin manager `Ctrl+p o p`](https://zellij.dev/documentation/plugin-aliases)

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).

<!--
This README is the per-tool doc pattern: ONE file per tool, at <tool>/README.md (GitHub renders it, the
root README links it). To enrich another tool's README to this shape, follow the section order:
  1 mental model (the one load-bearing concept) · 2 quick-start "moves that pay rent" · 3 complete
  reference · 4 task-first recipes · 5 a domain multiplier · 6 advanced craft · 7 anti-patterns ·
  8+ deep dives (integration/gotchas) · settings rationale · reload/verify/install · "go deeper" pointers.
Rules honored: cite every key upstream (config.md · never invent); config says what, prose says why
(claude-md.md); public repo → assume world-readable.
-->
