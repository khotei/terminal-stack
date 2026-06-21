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
├── vi-mode.zsh       # zsh-vi-mode — Vim editing on the command line
├── aliases.zsh       # ll/la, git shortcuts, lg/y (guarded) — no shadowing grep/find
├── tools.zsh         # zoxide · atuin · fzf integrations (each guarded)
├── prompt.zsh        # starship init (sourced last)
└── starship.toml     # Catppuccin Mocha prompt
```

`.zshrc` sources `env → vi-mode → aliases → tools → prompt`. Order matters: env sets `$EDITOR` before
tools read it; **vi-mode loads before tools** (it rebinds the keymaps, so fzf/atuin must bind *after*
it); the prompt initialises last over a ready shell. Anything machine-local or secret goes in
`~/.zshrc.local` (git-ignored), sourced at the end.

## Vi mode on the command line

[`vi-mode.zsh`](./vi-mode.zsh) loads [**zsh-vi-mode**](https://github.com/jeffreytse/zsh-vi-mode)
(`brew install zsh-vi-mode`, in the Brewfile) — so the prompt has the same modal editing as Neovim:

- **`Esc`** → normal mode; `i`/`a`/`I`/`A` back to insert; `v` visual.
- Motions + text objects (`ci"`, `daw`, `0`/`$`/`w`/`b`), and **surround** (`ys"` add, `cs"'` change `"`→`'`, `ds"` delete).
- A **mode indicator** + cursor-shape change (beam in insert, block in normal).
- `dd`/`yy` use the system clipboard register where available.

**Keybinding survival:** zsh-vi-mode rebinds the keymaps when it initialises, which would otherwise
wipe fzf's `Ctrl-R`/`Ctrl-T` and atuin's `Ctrl-R`. We set `ZVM_INIT_MODE=sourcing` and load it
**before** `tools.zsh`, so those integrations bind *after* zvm and win. A missing plugin is a silent
skip (it never breaks startup); the plugin is found via the Homebrew path or `$ZVM_PLUGIN`.

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

`./install.sh` (or `make install`) links all of these. By hand:
```sh
ln -sf  "$PWD/zsh/.zshrc"        ~/.zshrc
mkdir -p ~/.config/zsh && ln -sf "$PWD"/zsh/*.zsh ~/.config/zsh/
ln -sf  "$PWD/zsh/starship.toml" ~/.config/starship.toml
```
