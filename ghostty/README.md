# 👻 Ghostty — the terminal layer

The **outermost** layer of the stack: a GPU-accelerated, native terminal emulator. Everything else —
Zellij, Neovim, the shell, Claude Code — runs *inside* it. Ghostty draws the pixels, owns the font and
the theme, and then **gets out of the way** so the layers beneath it own the keyboard.

**This file is the single source for Ghostty in this stack** — the one idea, the handful of keys, the
config rationale. Nothing to hunt across other files. It's short *on purpose*: this tool is configured
to have almost no keybindings of its own.

- **File:** [`config`](./config) → `~/.config/ghostty/config` (single file, **no extension**)
- **Syntax:** `key = value`, one directive per line; a repeated key (`font-family`, `keybind`)
  **accumulates** rather than overwrites ([config](https://ghostty.org/docs/config)).
- **Validate:** `ghostty +show-config` (run by `/check`) · **Feature:** `F-TERM-001` ·
  **Upstream:** <https://ghostty.org/docs/config>

### Contents

1. [The one idea: a terminal that stays out of the way](#1-the-one-idea-a-terminal-that-stays-out-of-the-way)
2. [The moves that pay rent](#2-the-moves-that-pay-rent)
3. [Keybinding reference](#3-keybinding-reference) — the whole (tiny) surface
4. [Settings reference](#4-settings-reference-config-rationale)
5. [Translucency (opt-in)](#5-translucency-opt-in) · [Reload & verify](#6-reload--verify) · [Install](#7-install)

---

## 1. The one idea: a terminal that stays out of the way

Most terminal emulators want to *be* your multiplexer — they ship splits, tabs, and a thicket of
`⌘`/`ctrl` bindings. In this stack, **Zellij does all of that** ([Zellij README](../zellij/README.md)).
So Ghostty is configured to do the opposite of what it *could*: it binds **only two keys** and leaves
the entire `ctrl`-layer untouched.

**Why leave keys unbound is the *feature*.** Three tools compete for every keystroke — Ghostty, Zellij,
Neovim — and only one can win each one ([keyboard-layer contract](../.claude/rules/config.md)). Ghostty
sits on top, so anything it grabs never reaches the layers below. Keeping its keymap nearly empty is
what lets Zellij's modal prefix (`Ctrl+p/t/n/s/o…`) and Neovim's `<space>` leader arrive **intact**.

```
    keypress
       │
       ▼
   ┌ Ghostty ┐   binds only ⌘⇧R + ⌘` — everything else passes straight through
   └────┬────┘
        ▼
   ┌ Zellij ┐    owns the Ctrl-prefix + Alt shortcuts (the multiplexer)
   └────┬───┘
        ▼
   ┌ Neovim ┐    owns <space> leader + editor maps
   └────────┘
```

**The bridge that makes Alt work: [`macos-option-as-alt`](https://ghostty.org/docs/config/reference#macos-option-as-alt).**
On a Mac, the Option key normally *composes accented characters* (`⌥e` → `´`). This config sends a true
**Alt** instead — which is exactly what Zellij's `Alt+h/j/k/l` focus keys and nvim's Alt-maps expect.
Without it, those binds would silently type `˙`/`¬`/`…` and never reach the app. One key turns Option
from a dead-key composer into the modifier the layers below rely on.

So the mental model for Ghostty is a single sentence: **it's a fast, pretty window that owns the font
and the theme, and hands the keyboard down.**

---

## 2. The moves that pay rent

There are only two, plus the macOS defaults you already know. That's the whole muscle memory.

| Reflex | Keys |
|---|---|
| Reload this config after editing it | `⌘⇧R` |
| Drop a terminal down over *any* app (even when Ghostty is unfocused) | `⌘\`` |
| Grow / shrink / reset the font on the fly | `⌘=` / `⌘-` / `⌘0` *(built-in default)* |
| Copy / paste | `⌘C` / `⌘V` *(built-in default)* |

Everything *else* you'd reach for — new pane, new tab, switch window — is a **Zellij** move, not a
Ghostty one. If a split-or-tab reflex "isn't working," you're pressing it at the wrong layer: it lives
in [Zellij](../zellij/README.md).

---

## 3. Keybinding reference

The entire surface. Ghostty binds **only terminal-scoped actions**, never a multiplexer or editor key.

| Keys | Action | Why it's here |
|---|---|---|
| `⌘⇧R` | [`reload_config`](https://ghostty.org/docs/config/keybind/reference) | Re-read `config` live, no restart — the edit-and-see loop. Note: *not every* key applies at runtime (font changes may need a full restart). |
| `⌘\`` *(global)* | [`toggle_quick_terminal`](https://ghostty.org/docs/config/keybind/reference) | A Quake-style drop-down terminal. The [`global:`](https://ghostty.org/docs/config/keybind) prefix (macOS-only, needs Accessibility permission) fires it **even when Ghostty isn't focused** — a scratch shell from anywhere. State persists between toggles. |

**Built-in macOS defaults still apply** on top of these — `⌘=`/`⌘-`/`⌘0` (font size), `⌘C`/`⌘V`
(clipboard), and the rest of Ghostty's native menu shortcuts. Browse the full default set at the
[keybind reference](https://ghostty.org/docs/config/keybind/reference).

> **The invariant — do not break it.** Never add a `keybind` here whose trigger is a Zellij mode key
> (`ctrl+p/t/n/s/o…`) or the nvim `<space>` leader. Ghostty is on top of the stack; a bind here
> *shadows* the layer below and it vanishes silently. This is [§1](#1-the-one-idea-a-terminal-that-stays-out-of-the-way)
> made enforceable.

---

## 4. Settings reference (config rationale)

The *why* behind each key in [`config`](./config); the config file itself states the *what*.

| Key | Value | Why |
|---|---|---|
| [`font-family`](https://ghostty.org/docs/config/reference#font-family) | `Dank Mono` | Primary typeface — expressive italics. |
| [`font-family`](https://ghostty.org/docs/config/reference#font-family) | `Symbols Nerd Font Mono` | **Fallback** for icon glyphs — Dank Mono carries none, so LazyVim / Starship icons need it. A repeated `font-family` builds a fallback chain (later = lower priority). |
| [`font-size`](https://ghostty.org/docs/config/reference#font-size) | `20` | Comfortable default point size. |
| [`font-thicken`](https://ghostty.org/docs/config/reference#font-thicken) | `true` | macOS-only stroke thickening — Dank Mono's thin glyphs (esp. Cyrillic) render grainy at native weight. |
| [`alpha-blending`](https://ghostty.org/docs/config/reference#alpha-blending) | `linear-corrected` | Blend text in linear space (kills the dark fringing around glyph edges), then correct back so it matches macOS `native`. A cleaner edge without the darkening artifacts of plain `linear`. |
| [`theme`](https://ghostty.org/docs/config/reference#theme) | `light:<light>,dark:<dark>` | A bundled light/dark pair. The `light:…,dark:…` form is the load-bearing part: Ghostty **follows the OS appearance** and swaps live — and reports the change to apps inside via **CSI 2031**, which is what lets [Zellij](../zellij/README.md) and [Neovim](../nvim/README.md) light/dark in lockstep. Pick any pair from `ghostty +list-themes`; the config names the current one. |
| [`window-padding-x`](https://ghostty.org/docs/config/reference#window-padding-x) | `8` | Horizontal breathing room between cells and the window edge. |
| [`window-padding-y`](https://ghostty.org/docs/config/reference#window-padding-y) | `8` | Same, vertical. |
| [`macos-option-as-alt`](https://ghostty.org/docs/config/reference#macos-option-as-alt) | `true` | Send **Alt** on Option (vs. composing accents) so Alt-binds in Zellij / nvim / zsh fire — see [§1](#1-the-one-idea-a-terminal-that-stays-out-of-the-way). |

The chosen palettes ship **bundled with Ghostty** (browse them with `ghostty +list-themes`), so there's
no theme file to install — hence `theme` names them directly rather than pointing at a path. To re-theme
the whole stack, change this pair and mirror it in Zellij + Neovim (or ask Claude Code to do it).

---

## 5. Translucency (opt-in)

The terminal is **opaque by choice** — readability over the "glass" look. To turn it on, add:

```ini
background-opacity = 0.95
background-blur = true
```

See [`background-opacity`](https://ghostty.org/docs/config/reference#background-opacity) (0–1, `1` =
fully opaque) and [`background-blur`](https://ghostty.org/docs/config/reference#background-blur) (blurs
only when opacity < 1).

## 6. Reload & verify

- **Reload:** `⌘⇧R` inside Ghostty, or restart. Most keys hot-reload; a few (some font changes) want a
  full restart ([`reload_config`](https://ghostty.org/docs/config/keybind/reference) notes this).
- **Validate it parses:** `ghostty +show-config` — exits cleanly and echoes the effective config;
  **unknown keys surface as errors** (Ghostty rejects anything it doesn't recognise, which is why every
  key above is citable upstream). This is what `/check` runs.
- **List valid themes:** `ghostty +list-themes`.

> ℹ️ These commands need Ghostty installed locally. `/check` **skips and notes** the Ghostty validator
> on a machine without it rather than failing the run.

## 7. Install

`./install.sh` (or `make install`) symlinks `config` into `~/.config/ghostty/` and installs the
bundled fonts. To do just this layer by hand:

```sh
mkdir -p ~/.config/ghostty
ln -sf "$PWD/ghostty/config" ~/.config/ghostty/config
```

Fonts: **Dank Mono** ships in [`../fonts/`](../fonts/) (installed by `install.sh`); the Nerd Font
fallback comes from the Brewfile:

```sh
brew install --cask font-symbols-only-nerd-font
```

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).

<!--
This README follows the per-tool doc pattern (ONE file per tool at <tool>/README.md; the root README
links it). Section order, adapted to a tool with a deliberately tiny key surface — kept SHORT, not
padded to match Zellij:
  1 the one idea (the load-bearing concept) · 2 quick-start "moves that pay rent" · 3 the (small)
  keybinding reference · 4 settings rationale · 5+ opt-ins / reload-verify / install.
Sections the exemplar has that DON'T earn their place here (this tool has no modes, sessions, panes,
or recipe surface) are omitted on purpose.
Rules honored: cite every key upstream (config.md · never invent — Ghostty rejects unknown keys);
config says what, prose says why (claude-md.md); public repo → assume world-readable.
-->
