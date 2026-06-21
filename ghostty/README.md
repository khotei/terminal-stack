# 👻 Ghostty — the terminal layer

The outermost layer of the stack: a GPU-accelerated, native terminal emulator. Everything else
(Zellij, Neovim, the shell, Claude Code) runs *inside* it.

- **File:** [`config`](./config) → symlinks to `~/.config/ghostty/config`
- **Syntax:** `key = value`, one directive per line; a repeated key (like `font-family` or `keybind`)
  **accumulates** rather than overwrites.
- **Feature:** `F-TERM-001` · **Upstream:** <https://ghostty.org/docs/config>

---

## Settings reference

Every key set in [`config`](./config), why it's there, and where it's documented.

| Key | Value | Why | Upstream |
|---|---|---|---|
| `font-family` | `Dank Mono` | Primary typeface (expressive italics). | [font](https://ghostty.org/docs/config/reference#font-family) |
| `font-family` | `Symbols Nerd Font Mono` | **Fallback** for icon glyphs — Dank Mono has none, so LazyVim/Starship icons need it. Repeated `font-family` = fallback chain. | [font](https://ghostty.org/docs/config/reference#font-family) |
| `font-size` | `14` | Comfortable default point size. | [font-size](https://ghostty.org/docs/config/reference#font-size) |
| `theme` | `Catppuccin Mocha` | Bundled theme; one palette shared across the stack. Verify with `ghostty +list-themes`. | [theme](https://ghostty.org/docs/config/reference#theme) · [catppuccin/ghostty](https://github.com/catppuccin/ghostty) |
| `window-padding-x` | `8` | Breathing room between cells and the window edge. | [window-padding-x](https://ghostty.org/docs/config/reference#window-padding-x) |
| `window-padding-y` | `8` | Same, vertical. | [window-padding-y](https://ghostty.org/docs/config/reference#window-padding-y) |
| `macos-option-as-alt` | `true` | Option → **Alt**, so Alt-binds in nvim/zsh fire (vs. composing accents). | [macos-option-as-alt](https://ghostty.org/docs/config/reference#macos-option-as-alt) |

### Translucency (opt-in)

The terminal is **opaque by choice** — readability over the "glass" look. To enable it, add:

```ini
background-opacity = 0.95
background-blur = true
```

See [`background-opacity`](https://ghostty.org/docs/config/reference#background-opacity) and
[`background-blur`](https://ghostty.org/docs/config/reference#background-blur).

---

## Keybindings

Ghostty owns **only terminal-level** keys. The multiplexer prefix (`ctrl+a`) and the editor leader
are deliberately **left unbound** here so Zellij and Neovim get them cleanly — this is the
[keyboard-layer contract](../.claude/rules/config.md).

| Keys | Action | Notes |
|---|---|---|
| `⌘⇧R` | `reload_config` | Re-read this file without restarting. |
| `⌘\`` (global) | `toggle_quick_terminal` | Drop-down terminal from anywhere — `global:` works even when Ghostty isn't focused. |

Ghostty's built-in macOS defaults still apply on top (e.g. `⌘=` / `⌘-` / `⌘0` for font size,
`⌘C` / `⌘V` for clipboard) — see [keybind reference](https://ghostty.org/docs/config/keybind/reference).

> **Boundary:** never add a `keybind` here whose trigger is `ctrl+a` (Zellij) or the nvim leader.

---

## Reload & verify

- **Reload config:** `⌘⇧R` inside Ghostty, or restart. Most keys hot-reload; a few (font changes on
  some platforms) want a full restart.
- **Validate it parses:** `ghostty +show-config` — exits cleanly and echoes the effective config;
  unknown keys surface as errors.
- **List valid themes:** `ghostty +list-themes`.

> ℹ️ Run `ghostty +show-config` once on a machine with Ghostty installed to confirm the config parses.

---

## Install

Install with `./install.sh` (or `make install`) — it symlinks `config` into `~/.config/ghostty/` and
installs the bundled fonts. To do just this layer by hand:

```sh
mkdir -p ~/.config/ghostty
ln -sf "$PWD/ghostty/config" ~/.config/ghostty/config
```

Fonts: **Dank Mono** ships in [`../fonts/`](../fonts/) and is installed by `install.sh`; the Nerd Font
fallback comes from the Brewfile (`brew bundle`).

```sh
brew install --cask font-symbols-only-nerd-font
```

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
