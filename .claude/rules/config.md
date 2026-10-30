---
paths:
  - "ghostty/**"
  - "zellij/**"
  - "nvim/**"
  - "zsh/**"
  - "git/**"
  - "lazygit/**"
  - "claude/**"
  - "cursor/**"
  - "jetbrains/**"
  - "macos/**"
  - "chrome/**"
  - "install.sh"
---

# Config conventions

This repo *is* config — these are the cross-tool conventions every config
file follows so the stack stays coherent and validatable.

## Never invent a config key

Every key, keybind, KDL node, Lua option, or shell setting must be **citable in the tool's upstream
docs** (ghostty.org / zellij.dev / lazyvim.org / neovim.io / starship.rs). A guessed key is the
single most likely way to break a config silently — Ghostty rejects unknown keys, but a typo'd Lua
option or KDL node can fail quietly. If you can't cite it, don't write it: mark it `[TBD]` in the
spec and confirm it first. This is the discipline the whole SDD loop enforces (`@.claude/rules/sdd.md`).

The website documents the latest release, which may be ahead of (or behind) what Homebrew
installed, so confirm a key against the **installed** version before writing it:
`ghostty +show-config --default --docs`, `zellij setup --dump-config`,
`starship print-config --default`, `:h <option>` in nvim, and a plugin's source under
`~/.local/share/nvim/lazy/<plugin>/` for its options and defaults.

## One file owns one concern

- The **keymap for a tool lives in one place** — all Ghostty keybinds in `ghostty/config`, all
  Zellij binds in its keybind block, all nvim mappings in one keymap module. Don't scatter them;
  a single owning file is the source of truth and the only place to check for collisions.
- Shell config splits by concern (`env.zsh`, `aliases.zsh`, `prompt.zsh`) sourced from a thin
  `.zshrc` — see `@.claude/rules/naming.md`.

## No keybinding collisions across layers

The three keyboard layers must not fight:

- **Ghostty** owns the terminal-level keys (splits/tabs *of the terminal*, font, copy/paste).
- **Zellij** owns the keys that enter its modes and every key inside a mode. There is no tmux-style
  prefix: each mode has its own entry key.
- **Neovim** owns its leader and editor maps.

A key reaches the layer below only if every layer above leaves it free. So a Ghostty bind must not
take a Zellij mode key, and a Zellij mode key must not take a key that nvim or Claude Code uses
daily (free it, as `zellij/config.kdl` does). Each tool's keymap file is the record of which keys
are taken; never copy them into a rule.

## Validate every change

A config edit is not done until it **loads**. Run `/check` (`@.claude/commands/check.md`) for every
tool you touched — `ghostty +show-config`, `zellij setup --check`,
`nvim --headless "+checkhealth"/luafile`, `zsh -n`. See `@.claude/rules/testing.md`.

## Reloading

Tools differ — note the reload step in the cheatsheet / PR so a user isn't confused when a change
"doesn't take":

- **Ghostty** hot-reloads config on `reload_config` (or restart); some keys need a full restart.
- **Zellij** reloads on session restart; layouts apply to new sessions.
- **Neovim** picks up Lua on restart; plugin changes need `:Lazy sync`.
- **zsh / Starship** apply on a new shell or `source ~/.zshrc`.

## Secrets & machine-local overrides

Nothing secret goes in a committed file. Machine-local overrides live in git-ignored siblings
(`zsh/.zshrc.local`, `.claude/settings.local.json`, `*.local`) — already in `.gitignore`. This is a
**public** repo: assume every committed line is world-readable.
