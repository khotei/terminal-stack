# Naming & file layout conventions

The repo is organised **by tool**, one top-level folder each, mirroring where the tool reads its
config under `~/.config` (or `$HOME`). The folder name *is* the index — a reader knows which tool a
file configures from its path alone.

## Top-level layout

| Folder | Tool | Maps to (on install) | Primary file |
|---|---|---|---|
| `ghostty/` | Ghostty (terminal) | `~/.config/ghostty/` | `config` (no extension — `key = value`) |
| `zellij/` | Zellij (multiplexer) | `~/.config/zellij/` | `config.kdl` (+ `layouts/*.kdl`, `plugins/`) |
| `nvim/` | Neovim / LazyVim (editor) | `~/.config/nvim/` | `init.lua` + `lua/**/*.lua` |
| `zsh/` | zsh + Starship (shell) | `$HOME` / `~/.config` | `.zshrc`, `*.zsh`, `starship.toml` |
| `.claude/` | Claude Code (agent) | repo-local | the SDD toolkit + rules |
| `docs/` | reference guides / cheatsheets | repo-local | `*.md` |

> `specs/` does **not** exist on disk — the live feature/task state is Notion-only (see
> `@.claude/rules/sdd.md`).

## File naming

- **Ghostty** uses a single `config` file with **no extension** (the program's expected name). Its
  syntax is `key = value`, one directive per line; repeated keys (e.g. `keybind`) accumulate.
- **Zellij** files are **KDL** with a `.kdl` extension — `config.kdl` for the main config, one file
  per layout under `layouts/`.
- **Neovim** files are **Lua** (`.lua`), kebab-case, under `lua/` namespaced by plugin/area
  (LazyVim convention: `lua/plugins/<name>.lua`, `lua/config/*.lua`). The entrypoint is `init.lua`.
- **zsh** files are kebab-case `.zsh` modules (`aliases.zsh`, `env.zsh`, `prompt.zsh`) sourced from
  `.zshrc`, which stays thin. Starship's prompt config is `starship.toml`.
- **Group by concern, not by line count.** A long single file (one giant `.zshrc`, one
  thousand-line keymap) splits into role files sourced/required from a thin entrypoint — so the same
  concern always reads from the same place.

## General

- **kebab-case** for every multi-word filename we author (`git-prompt.zsh`, `autolock.kdl`,
  `which-key.lua`). Single-word files stay single-word (`env.zsh`, `config`).
- **Match the tool's expected name where it's fixed** — Ghostty's `config`, Zellij's `config.kdl`,
  Neovim's `init.lua`, Starship's `starship.toml` are named by the tool, not by us; don't rename
  them.
- **Keep the keymap in one place per tool.** Don't scatter Ghostty keybinds across files or Zellij
  binds across layouts — a single owning file is the keybinding source of truth (see
  `@.claude/rules/comments.md` for the collision invariants).
