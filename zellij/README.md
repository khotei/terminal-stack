# 🧬 Zellij — the multiplexer layer

Sessions, tabs, and panes — the workspace that hosts **Neovim │ Claude Code** side by side. Zellij is
a modern, modal alternative to tmux: discoverable (it shows its keys), KDL-configured, sessions as
workspaces.

- **Files:** [`config.kdl`](./config.kdl) → `~/.config/zellij/config.kdl`,
  [`layouts/dev.kdl`](./layouts/dev.kdl) → `~/.config/zellij/layouts/dev.kdl`
- **Validate:** `zellij --config zellij/config.kdl setup --check` (run by `/check` + CI)
- **Feature:** `F-MUX-001` · **Upstream:** <https://zellij.dev/documentation>

---

## Settings reference

| Key | Value | Why |
|---|---|---|
| `theme` | `catppuccin-mocha` | Fallback palette if the terminal reports no appearance — defined **in-config** (themes block) so it doesn't depend on a built-in. |
| `theme_dark` / `theme_light` | `catppuccin-mocha` / `catppuccin-latte` | Auto-switch with the OS: Ghostty follows the macOS appearance and reports it via **CSI 2031 / DSR 997**; Zellij picks the matching palette live. |
| `default_layout` | `compact` | Built-in **compact-bar** — theme-aware, shows mode + keys + tabs (see below). |
| `pane_frames` | `true` | Frames on so splits read as distinct cards; the frame lends a 1-cell content offset (Zellij has no native inner padding). |
| `ui.pane_frames.rounded_corners` | `true` | Round the frame corners — softer look; inert without `pane_frames true`. |
| `copy_on_select` | `true` | Select = copy (tmux-like). |
| `scrollback_editor` | `nvim` | "Edit scrollback" opens in the stack's editor. |
| `mouse_mode` | `true` | Scroll/select with the mouse when you want it. |

Both palettes — Catppuccin **Mocha** and **Latte** — are the official
[catppuccin/zellij](https://github.com/catppuccin/zellij) mappings, embedded in the `themes { … }`
block so the config is self-contained.

## Using Zellij: the modes

Zellij is **modal**, not prefix-based. Instead of tmux's *hold a prefix, then a key*, you **switch
into a mode**, press plain keys while it's active, then **leave**. The loop is always the same:

```
Normal ──[ Ctrl+<mode> ]──▶ <mode> ──[ act with single keys ]──▶ [ Enter | Esc ]──▶ Normal
```

The **status bar** always lists the active mode's keys — it is the live cheatsheet; the tables below
are a quick reference (Zellij 0.44.x defaults; this config keeps them, so **no prefix** and nothing
to memorise beyond the entry keys).

### Entering a mode (from Normal)

| Key | Mode | What it's for |
|---|---|---|
| `Ctrl+p` | **Pane** | split · focus · close · fullscreen · float · rename |
| `Ctrl+t` | **Tab** | new · close · switch · jump-to-number · break out |
| `Ctrl+n` | **Resize** | grow / shrink the focused pane |
| `Ctrl+h` | **Move** | relocate a pane within the layout |
| `Ctrl+s` | **Scroll** | scrollback · search · edit-scrollback in nvim |
| `Ctrl+o` | **Session** | detach · session / plugin manager · config |

Leaving any mode: **`Enter`** or **`Esc`** → Normal (or press the entry key again). `Ctrl+c` also
backs out of Scroll/Search.

### Inside each mode (the keys that earn their keep)

**Pane** (`Ctrl+p`) · move focus with `h/j/k/l` (or arrows):

| Key | Action | Key | Action |
|---|---|---|---|
| `n` | new pane | `x` | close focused |
| `d` / `r` | split down / right | `f` | fullscreen toggle |
| `s` | new stacked pane | `w` | floating panes toggle |
| `c` | rename pane | `e` | embed ↔ float |

**Tab** (`Ctrl+t`):

| Key | Action | Key | Action |
|---|---|---|---|
| `n` | new tab | `1`…`9` | jump to tab N |
| `x` | close tab | `h`/`k` · `l`/`j` | previous · next tab |
| `r` | rename tab | `Tab` | toggle last-active |
| `b` | break pane into its own tab | `[` / `]` | break pane left / right |

**Resize** (`Ctrl+n`): `h/j/k/l` grow a side · `H/J/K/L` shrink · `=` / `-` all sides.
**Move** (`Ctrl+h`): `h/j/k/l` push the pane · `n`/`Tab` next slot · `p` previous.
**Scroll** (`Ctrl+s`): `j/k` line · `d/u` half-page · `PageUp/PageDown` page · `s` search · `e` open
scrollback in nvim · `Ctrl+c` jump to bottom and exit.
**Session** (`Ctrl+o`): `w` **session manager** (fuzzy-switch sessions/tabs) · `d` detach · `c`
configuration · `p` plugin manager.

### Skip the mode dance — direct `Alt` shortcuts

For the moves you make constantly, hold **`Alt`** from Normal and act in one stroke — no mode:

| Keys | Action |
|---|---|
| `Alt+n` | new pane |
| `Alt+f` | toggle floating panes (the "popup" window) |
| `Alt+←/→/↑/↓` or `Alt+h/j/k/l` | move focus (`h`/`l` cross into adjacent tabs) |
| `Alt+i` / `Alt+o` | shift the current tab left / right |
| `Alt+=` / `Alt+-` | resize the focused pane |
| `Alt+[` / `Alt+]` | previous / next swap-layout |

> These `Alt` keys are deliberately swallowed inside a **locked** Claude/nvim pane (that's the point —
> the app gets them). Use them from a shell pane, or `Alt+z` out of lock first (see below).

## Living with Claude Code / Neovim

A **locked** pane passes every key straight to the app — that's [autolock](#autolock) below. Two
rebinds make a locked pane cooperate with both the app and you:

- **`Ctrl+g` is freed** (unbound from Zellij's lock toggle) so Claude Code's own `Ctrl+g` — *edit
  prompt in `$EDITOR`* — reaches it. `Ctrl+g` is the one key Locked mode can't otherwise pass through.
- **`Alt+z` is the master switch.** From inside a locked Claude/nvim pane, `Alt+z` **disables autolock
  and drops to Normal** — so at any moment you reach the *full* modal Zellij without leaving the app.
  It's sticky (won't re-lock). Press `Alt+z` again to re-arm autolock and return to transparent mode.

## Autolock (on by default) — seamless editor/agent passthrough {#autolock}

[`zellij-autolock`](https://github.com/fresh2dev/zellij-autolock) auto-enters **locked** mode (every
key passes straight through to the running app) when it sees
`nvim`/`vim`/`git`/`fzf`/`zoxide`/`atuin`/`claude` focused — so Zellij never eats a Neovim or Claude
Code keystroke, and you don't lock/unlock by hand.

It's **enabled in `config.kdl`**, and `install.sh` fetches the plugin binary to
`~/.config/zellij/plugins/zellij-autolock.wasm` automatically. **No wasm = no problem:** if the fetch
is skipped (offline) the keybinds stay harmless (Enter still types; the plugin message is a no-op),
so the config is valid either way. To fetch it manually:

```sh
mkdir -p ~/.config/zellij/plugins
curl -fsSL -o ~/.config/zellij/plugins/zellij-autolock.wasm \
  https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm
```

Use **`Alt+z`** whenever you need the full multiplexer back while an editor/agent is focused (see
above) — it disables autolock and drops to Normal; `Alt+z` again re-arms it.

## The status bar (built-in compact-bar)

The bar is Zellij's built-in [`compact-bar`](https://zellij.dev/documentation/plugin-aliases) — a
single line that is **theme-aware**: it follows `theme_dark`/`theme_light`, so it lightens with the
rest of the stack in Latte and darkens in Mocha (this is what closes the auto-theme loop — a plugin
bar with hard-coded colours could not). For the current mode it shows the **mode name, that mode's
keybinding hints, and the tabs** — the live cheatsheet the mode tables above summarise.

Nothing to install: it ships with Zellij — **no wasm, no permission grant**. It loads via
`default_layout "compact"` (`config.kdl`) for every session, and `layouts/dev.kdl` references it as
`plugin location="compact-bar"` so the editor │ agent split carries the same bar.

## The `dev` layout

[`layouts/dev.kdl`](./layouts/dev.kdl) opens the editor │ agent split:

```
zellij --layout dev
```

Left pane = editor, right pane (40%) = agent. Both open a shell by default; uncomment the `command`
lines to auto-launch `nvim` and `claude`. The tab is named **`dev`** in the bar (not the default
`Tab #1`); rename any tab live with `Ctrl+t` → `r`.

## Reload & verify

- **Apply config:** new sessions pick it up; `zellij` options reload on session start.
- **Validate:** `zellij --config zellij/config.kdl setup --check` → `[CONFIG FILE]: Well defined.`
  (verified in the sandbox on zellij 0.44.3).
- **Try it now:** `make zellij` (the Docker sandbox) drops you straight into Zellij with this config.

## Install

`./install.sh` (or `make install`) symlinks `zellij/` into `~/.config/zellij/`.

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
