# Tooling

The stack installs and validates through a small, standard set of CLIs. Everything is available via
**Homebrew** on macOS.

## Install (Homebrew)

```sh
brew install ghostty zellij neovim starship zoxide atuin fzf fd ripgrep lazygit yazi stylua shfmt
```

`zsh` ships with macOS. `ghostty` is also available as a cask depending on the channel. The
validators below come from `ghostty`, `zellij`, `neovim`, `stylua`, `shfmt`; the rest are the
runtime tools the configs wire together (see `@.claude/rules/tech-stack.md`).

## Validators

| Command | Validates | Where it runs |
|---|---|---|
| `ghostty +show-config` | Ghostty `config` (parses; unknown keys surface) | `/check`, `/sdd:implement`, `/sdd:verify` |
| `zellij setup --check` | Zellij config + layouts | same |
| `nvim --headless "+checkhealth" +qa` | Neovim health (plugins, providers, deps) | same |
| `nvim --headless -c 'luafile <file>' -c qa` | a single Lua module loads | same |
| `zsh -n <file>` | shell file syntax (no execution) | same |
| `stylua --check nvim/` | Lua formatting (style gate) | `/check` |
| `shfmt -d zsh/` | shell formatting (style gate) | `/check` |

All of these run through **`/check`** (`@.claude/commands/check.md`), which **skips and notes** any
validator whose tool isn't installed rather than failing the whole run.

## Formatters

- **`stylua`** formats Neovim Lua. Config lives in `stylua.toml` (or `.stylua.toml`) at the repo
  root if present; otherwise it uses defaults. `stylua --check` is the gate, `stylua` (write) the fix.
- **`shfmt`** formats zsh / shell. `shfmt -d` diffs, `shfmt -w` writes.

These are **style** gates, not load checks — a formatting diff is a soft fail. The load validators
above are the hard gate.

## No commit hook (yet)

There is no Husky/lefthook commit hook running validators on `git commit` — `/check` is run manually
(and by the SDD loop before a task is `Done`). If a future feature adds a hook, wire it to `/check`
and record the decision here.
