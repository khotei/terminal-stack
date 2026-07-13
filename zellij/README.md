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
5. [Sessions are workspaces](#5-sessions-are-workspaces)
6. [Advanced pane craft](#6-advanced-pane-craft)
7. [Anti-patterns](#7-anti-patterns)
8. [Living with Claude Code / Neovim + autolock](#8-living-with-claude-code--neovim--autolock)
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

**The one reflex that outranks every hotkey.** This config runs
[`zellij-autolock`](#8-living-with-claude-code--neovim--autolock): the moment a pane runs
`nvim`/`claude`/`git`/`fzf`/`zoxide`/`atuin`, Zellij drops to **Locked** mode and hands the app *every*
keystroke (that's why Claude never loses a `Ctrl`). The cost: **while you're "inside" Claude, no Zellij
hotkey fires.** Exactly one key is honored:

> **`Alt+z`** — the master switch. From a locked pane it *disables* autolock and drops you to Normal
> (sticky — it won't re-lock). Now the full multiplexer is yours; press `Alt+z` again to re-arm.

So the first reflex to build: **a Zellij key "didn't work"? The pane was locked — `Alt+z` first.**

---

## 2. Quick start — the moves that pay rent

Learn these ten before anything else; they cover ~90% of real use. (Grouped by *reflex*; the exhaustive
per-mode tables are in [§3](#3-complete-keybinding-reference).)

| Reflex | Keys |
|---|---|
| Escape a locked app → full Zellij | `Alt+z` |
| Jump **straight** to a tab | `Ctrl+t` then `1`…`9` |
| Toggle to the last tab (A↔B) | `Ctrl+t` then `Tab` |
| Glide focus across panes *and* tabs | `Alt+h` / `Alt+l` (rolls into the next tab at the edge) |
| Focus a pane up / down | `Alt+k` / `Alt+j` |
| Zoom the focused pane full-screen | `Ctrl+p` then `f` (again to un-zoom) |
| Throwaway popup pane over your work | `Alt+f` (toggle floating) |
| New split | `Alt+n` |
| Name this tab (so `Ctrl+t N` means something) | `Ctrl+t` then `r` |
| See / switch / resurrect sessions | `Ctrl+o` then `w` |

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
| `Ctrl+n` | **Resize** | grow / shrink the focused pane |
| `Ctrl+h` | **Move** | relocate a pane within the layout |
| `Ctrl+s` | **Scroll** | scrollback · search · edit-scrollback in nvim |
| `Ctrl+o` | **Session** | detach · session / plugin manager · config |

**Pane** (`Ctrl+p`) · move focus with `h/j/k/l` or arrows:

| Key | Action | Key | Action |
|---|---|---|---|
| `n` | new pane | `x` | close focused |
| `d` / `r` | split down / right | `f` | fullscreen (zoom) toggle |
| `s` | new **stacked** pane | `w` | floating panes toggle |
| `e` | embed ↔ float | `i` | pin a floating pane (always-on-top) |
| `c` | rename pane | | |

**Tab** (`Ctrl+t`):

| Key | Action | Key | Action |
|---|---|---|---|
| `n` | new tab | `1`…`9` | jump to tab N |
| `x` | close tab | `h`/`k` · `l`/`j` | previous · next tab |
| `r` | rename tab | `Tab` | toggle last-active |
| `b` | break pane into its own tab | `[` / `]` | break pane to prev / next tab |

**Resize** (`Ctrl+n`): `h/j/k/l` grow a side · `H/J/K/L` shrink · `=` / `-` all sides.
**Move** (`Ctrl+h`): `h/j/k/l` push the pane · `n`/`Tab` next slot · `p` previous.
**Scroll** (`Ctrl+s`): `j/k` line · `d/u` half-page · `PageUp/PageDown` page · `s` search · `e` open
scrollback in nvim · `Ctrl+c` jump to bottom and exit.
**Session** (`Ctrl+o`): `w` **session manager** (fuzzy-switch/resurrect) · `d` detach · `c`
configuration · `p` plugin manager.

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
> the app gets them). Use them from a shell pane, or `Alt+z` out of lock first ([§8](#8-living-with-claude-code--neovim--autolock)).

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

**Mine your scrollback like a document.** `Ctrl+s` `e` opens the pane's entire scrollback in **nvim**
(this config's `scrollback_editor`) — search, yank a stack trace, save it. Or stay in-pane: `Ctrl+s`
`s` searches the buffer, `Ctrl+c` snaps back to the bottom.

**Run a command *into* a new pane from the shell** — no mode dance: `zellij run -- cargo test` (new
pane running it), `zellij run -f -- htop` (floating), `zellij edit ./src/main.rs` (open a file)
([run & edit](https://zellij.dev/documentation/zellij-run-and-edit.html)). Great inside scripts/hooks.

**Make a workspace reproducible.** You already have [`layouts/dev.kdl`](./layouts/dev.kdl) —
`zellij --layout dev` rebuilds the editor │ agent split every time. To capture a layout you arranged by
hand: `zellij action dump-layout > zellij/layouts/mine.kdl`
([dump-layout](https://zellij.dev/documentation/cli-actions)) — **not** the old `zellij layout dump`
from stale blog posts; Zellij layouts are KDL now.

---

## 5. Sessions are workspaces

Think of a **session per project**, not one giant session. This is where Zellij out-classes a pile of
terminal tabs.

- **Detach, don't kill.** `Ctrl+o` `d` detaches: the session (and every running process — builds,
  `claude`, servers) keeps living in the background. Re-enter with `zellij attach <name>` (`zellij a`);
  `zellij ls` lists them ([session tutorial](https://zellij.dev/tutorials/session-management/)).
- **Survive a reboot — resurrection.** Zellij stores each session's *metadata*: the pane/tab layout
  **and** the command each pane ran. After a crash or restart, `Ctrl+o` `w` → pick an **exited**
  session → it rebuilds the workspace. Rename an exited one with `Ctrl+r` in the manager to label it
  before resurrecting.
- **Switch projects.** `Ctrl+o` `w` is a fuzzy, type-to-filter picker over all sessions — the fast path
  between repos without leaving Zellij.

> *Resurrection* = rebuilding a session from saved layout metadata, not from a live process. The
> processes are gone; the shape (and the commands to relaunch them) comes back.

---

## 6. Advanced pane craft

- **Stacked panes** — layer panes in one slot, each keeping its title bar so you can navigate the
  stack. Open with `Ctrl+p` `s`; move through the stack with `Alt+↑`/`Alt+↓`
  ([stacked panes](https://zellij.dev/news/stacked-panes-swap-layouts/)). Since 0.42, **resize is
  stacked by default**: `Alt+=` grows the focused pane ~30% and tucks neighbors into a stack instead of
  squeezing everything ([stacked resize](https://zellij.dev/tutorials/stacked-resize/)).
- **Swap layouts** — `Alt+[` / `Alt+]` cycle *predefined arrangements* of the current panes, so you
  reflow a tab instead of hand-resizing ([swap layouts](https://zellij.dev/documentation/swap-layouts.html)).
- **Embed ↔ float** — `Ctrl+p` `e` turns a floating pane into a tiled one (or back); `Ctrl+p` `w`
  toggles the whole floating layer.
- **Break a pane out** — `Ctrl+t` `b` moves the focused pane into its own tab; `Ctrl+t` `[` / `]` sends
  it to the previous/next tab.

---

## 7. Anti-patterns

| Don't | Do instead |
|---|---|
| Arrow through tabs `→ → →` to find one | Name tabs, `Ctrl+t N` or `go-to-tab-name` |
| Fight a locked pane when a hotkey "won't work" | `Alt+z` out first |
| Rebuild your layout by hand every morning | `zellij --layout dev`, or resurrect via `Ctrl+o w` |
| Cram 12 panes into one tab | Split across named tabs / a session per project |
| `exit` a session you'll want back | `Ctrl+o d` detach — processes keep running |

---

## 8. Living with Claude Code / Neovim + autolock

[`zellij-autolock`](https://github.com/fresh2dev/zellij-autolock) auto-enters **locked** mode (every
key passes straight through to the running app) when it sees
`nvim`/`vim`/`git`/`fzf`/`zoxide`/`atuin`/`claude` focused — so Zellij never eats a Neovim or Claude
Code keystroke, and you don't lock/unlock by hand. Two rebinds make a locked pane cooperate with both
the app and you:

- **`Ctrl+g` is freed** (unbound from Zellij's lock toggle) so Claude Code's own `Ctrl+g` — *edit
  prompt in `$EDITOR`* — reaches it. `Ctrl+g` is the one key Locked mode can't otherwise pass through.
- **`Alt+z` is the master switch** (see [§1](#1-the-mental-model)): from a locked pane it disables
  autolock and drops to Normal — sticky, won't re-lock. `Alt+z` again re-arms.

It's **enabled in `config.kdl`**, and `install.sh` fetches the plugin binary to
`~/.config/zellij/plugins/zellij-autolock.wasm` automatically. **No wasm = no problem:** if the fetch is
skipped (offline) the keybinds stay harmless (Enter still types; the plugin message is a no-op), so the
config is valid either way. To fetch it manually:

```sh
mkdir -p ~/.config/zellij/plugins
curl -fsSL -o ~/.config/zellij/plugins/zellij-autolock.wasm \
  https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm
```

---

## 9. The status bar

The bar is Zellij's built-in [`compact-bar`](https://zellij.dev/documentation/plugin-aliases) — a
single line that is **theme-aware**: it follows `theme_dark`/`theme_light`, so it lightens with the rest
of the stack in Latte and darkens in Mocha (this is what closes the auto-theme loop — a plugin bar with
hard-coded colours could not). For the current mode it shows the **mode name, that mode's keybinding
hints, and the tabs** — the live cheatsheet the tables above summarise. It ships with Zellij (no wasm,
no permission grant) and loads via `default_layout "compact"` for every session.

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
| `theme` | `catppuccin-mocha` | Fallback palette if the terminal reports no appearance — defined **in-config** (themes block) so it doesn't depend on a built-in. |
| `theme_dark` / `theme_light` | `catppuccin-mocha` / `catppuccin-latte` | Auto-switch with the OS: Ghostty follows the macOS appearance and reports it via **CSI 2031 / DSR 997**; Zellij picks the matching palette live. |
| `default_layout` | `compact` | Built-in **compact-bar** — theme-aware, shows mode + keys + tabs ([§9](#9-the-status-bar)). |
| `pane_frames` | `true` | Frames on so splits read as distinct cards; the frame lends a 1-cell content offset (Zellij has no native inner padding). |
| `ui.pane_frames.rounded_corners` | `true` | Round the frame corners — softer look; inert without `pane_frames true`. |
| `copy_on_select` | `true` | Select = copy (tmux-like). |
| `scrollback_editor` | `nvim` | "Edit scrollback" (`Ctrl+s` `e`) opens in the stack's editor. |
| `mouse_mode` | `true` | Scroll/select — and click a tab/pane to focus it. |

Both palettes — Catppuccin **Mocha** and **Latte** — are the official
[catppuccin/zellij](https://github.com/catppuccin/zellij) mappings, embedded in the `themes { … }` block
so the config is self-contained.

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
- Plugins & aliases → [plugin manager `Ctrl+o p`](https://zellij.dev/documentation/plugin-aliases)

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
