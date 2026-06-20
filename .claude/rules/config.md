# Config conventions

**Always-loaded rule.** This repo *is* config — these are the cross-tool conventions every config
file follows so the stack stays coherent and validatable.

## Never invent a config key

Every key, keybind, KDL node, Lua option, or shell setting must be **citable in the tool's upstream
docs** (ghostty.org / zellij.dev / lazyvim.org / neovim.io / starship.rs). A guessed key is the
single most likely way to break a config silently — Ghostty rejects unknown keys, but a typo'd Lua
option or KDL node can fail quietly. If you can't cite it, don't write it: mark it `[TBD]` in the
spec and confirm it first. This is the discipline the whole SDD loop enforces (`@.claude/rules/sdd.md`).

## One file owns one concern

- The **keymap for a tool lives in one place** — all Ghostty keybinds in `ghostty/config`, all
  Zellij binds in its keybind block, all nvim mappings in one keymap module. Don't scatter them;
  a single owning file is the source of truth and the only place to check for collisions.
- Shell config splits by concern (`env.zsh`, `aliases.zsh`, `prompt.zsh`) sourced from a thin
  `.zshrc` — see `@.claude/rules/naming.md`.

## No keybinding collisions across layers

The three keyboard layers must not fight:

- **Ghostty** owns the terminal-level keys (splits/tabs *of the terminal*, font, copy/paste).
- **Zellij** owns the multiplexer prefix (e.g. `ctrl+a`) and everything under it.
- **Neovim** owns its leader (e.g. `<space>`) and editor maps.

A new bind in any layer must not shadow the layer below it (a Ghostty key must not eat Zellij's
prefix; an nvim map must not eat the multiplexer prefix). Record the chosen prefix/leader as an
invariant in the relevant `CLAUDE.md`.

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
