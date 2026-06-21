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
| `theme` | `catppuccin-mocha` | Shared palette — defined **in-config** (themes block) so it doesn't depend on a built-in. |
| `default_layout` | `compact` | Minimal chrome; the `dev` layout is opt-in via `zellij -l dev`. |
| `pane_frames` | `false` | Cleaner splits; the theme marks the active pane. |
| `copy_on_select` | `true` | Select = copy (tmux-like). |
| `scrollback_editor` | `nvim` | "Edit scrollback" opens in the stack's editor. |
| `mouse_mode` | `true` | Scroll/select with the mouse when you want it. |

The Catppuccin Mocha palette is the official [catppuccin/zellij](https://github.com/catppuccin/zellij)
mapping, embedded in the `themes { … }` block so the config is self-contained.

## The `ctrl+a` prefix (tmux muscle memory)

Zellij is **modal** by default (each mode has its own keys, shown in the status bar). On top of that,
this config moves Zellij's **tmux mode** entry from the default `Ctrl+b` to **`Ctrl+a`**, so ex-tmux
hands feel at home:

| Keys | Action |
|---|---|
| `ctrl+a` | Enter tmux (prefix) mode |
| `ctrl+a` `c` | New tab |
| `ctrl+a` `"` / `%` | Split down / right |
| `ctrl+a` `h/j/k/l` | Move focus between panes |
| `ctrl+a` `n` / `p` | Next / previous tab |
| `ctrl+a` `x` | Close pane · `ctrl+a` `z` fullscreen · `ctrl+a` `d` detach |
| `ctrl+a` `ctrl+a` | Send a literal `Ctrl+a` to the app (tmux *send-prefix*) |

> All of Zellij's other modal defaults are **kept** — only the prefix key changed. The bare
> `ctrl+hjkl` keys are deliberately **not** grabbed globally: they belong to Neovim. Pane navigation
> goes through the prefix, or enable autolock below for seamless passthrough.

## Autolock (opt-in) — seamless editor/agent passthrough

[`zellij-autolock`](https://github.com/fresh2dev/zellij-autolock) auto-enters **locked** mode (every
key passes through to the running app) when it sees `nvim`/`vim`/`git`/`fzf`/`zoxide`/`atuin` focused — so Zellij never
eats a Neovim or Claude Code keystroke. It's shipped **disabled** (slashdash-commented `/-`) so the
base config validates without the binary. To enable:

```sh
# 1. fetch the plugin binary
mkdir -p ~/.config/zellij/plugins
curl -fsSL -o ~/.config/zellij/plugins/zellij-autolock.wasm \
  https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm
# 2. in config.kdl, delete the `/-` prefix on the `plugins`, `load_plugins`, and `keybinds` nodes
```

## The `dev` layout

[`layouts/dev.kdl`](./layouts/dev.kdl) opens the editor │ agent split:

```
zellij --layout dev
```

Left pane = editor, right pane (40%) = agent. Both open a shell by default; uncomment the `command`
lines to auto-launch `nvim` and `claude`.

## Reload & verify

- **Apply config:** new sessions pick it up; `zellij` options reload on session start.
- **Validate:** `zellij --config zellij/config.kdl setup --check` → `[CONFIG FILE]: Well defined.`
  (verified in the sandbox on zellij 0.44.3).
- **Try it now:** `make zellij` (the Docker sandbox) drops you straight into Zellij with this config.

## Install

`./install.sh` (or `make install`) symlinks `zellij/` into `~/.config/zellij/`.

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
