# 🐚 zsh + Starship — the shell layer

A thin, modular zsh setup with the [Starship](https://starship.rs) prompt and the modern CLI
companions wired in. The `.zshrc` does almost nothing itself — it sources small **role files** in a
deliberate order, so each concern lives in one place.

- **Files:** [`.zshrc`](./.zshrc) → `~/.zshrc`; [`*.zsh`](.) → `~/.config/zsh/`;
  [`starship.toml`](./starship.toml) → `~/.config/starship.toml`
- **Validate:** `zsh -n <file>` (syntax, no execution) — run by `/check` + CI
- **Feature:** `F-SHELL-001` · **Upstream:** <https://starship.rs/config>

---

## Layout

```
zsh/
├── .zshrc            # thin entrypoint → sources the role files below, in order
├── env.zsh           # exports ($EDITOR=nvim), history, completion, options
├── aliases.zsh       # ll/la, git shortcuts, lg/y (guarded) — no shadowing grep/find
├── tools.zsh         # zoxide · atuin · fzf integrations (each guarded)
├── prompt.zsh        # starship init (sourced last)
└── starship.toml     # Catppuccin Mocha prompt
```

`.zshrc` sources `env → aliases → tools → prompt`. Order matters: env sets `$EDITOR` before tools
read it; the prompt initialises last over a ready shell. Anything machine-local or secret goes in
`~/.zshrc.local` (git-ignored), sourced at the end.

## Companion CLIs (each guarded)

Every integration is wrapped in `command -v <tool> && …`, so a missing tool **never** breaks shell
startup — same graceful-degradation rule as the rest of the stack.

| Tool | Gives you |
|---|---|
| [**zoxide**](https://github.com/ajeetdsouza/zoxide) | `z foo` — jump to dirs by frecency (`zi` to pick) |
| [**atuin**](https://atuin.sh) | searchable/syncable history (rebinds `Ctrl-R` / `Up`) |
| [**fzf**](https://github.com/junegunn/fzf) | `Ctrl-T` files · `Ctrl-R` history · `Alt-C` cd (via `fzf --zsh`, fzf ≥ 0.48) |

`ll`, `la`, `gs`/`gd`/`gl`, and (if installed) `lg` (lazygit) / `y` (yazi) round it out. We
deliberately **don't** alias over `grep`/`find` so scripts and habits keep working.

## The prompt

`starship.toml` sets the **Catppuccin Mocha** palette (official
[catppuccin/starship](https://github.com/catppuccin/starship) mapping) and a compact two-line format:
directory · git branch/status · command duration, then the `❯` character (green ok / red error). The
git-branch glyph needs a Nerd Font (the stack assumes one).

## Reload & verify

- **Apply:** `source ~/.zshrc` or open a new shell.
- **Validate:** `zsh -n zsh/.zshrc` (+ each `*.zsh`) — syntax only, never executes. Verified in the
  sandbox: all five files pass, and `.zshrc` sources cleanly at runtime with `$EDITOR=nvim` set and
  Starship active.
- **Try it now:** `make try` — the sandbox boots straight into this shell.

## Install

Until `install.sh` lands (Meta):
```sh
ln -sf  "$PWD/zsh/.zshrc"        ~/.zshrc
mkdir -p ~/.config/zsh && ln -sf "$PWD"/zsh/*.zsh ~/.config/zsh/
ln -sf  "$PWD/zsh/starship.toml" ~/.config/starship.toml
```
