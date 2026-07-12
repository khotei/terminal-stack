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
├── env.zsh           # XDG base dirs + redirects, exports ($EDITOR), history, completion
├── vi-mode.zsh       # zsh-vi-mode — Vim editing on the command line
├── aliases.zsh       # ll/la, git shortcuts, lg/y (guarded) — no shadowing grep/find
├── tools.zsh         # zoxide · atuin · fzf · bat man-pager (each guarded)
├── prompt.zsh        # starship init
├── plugins.zsh       # autosuggestions · fzf-tab · syntax-highlighting (sourced LAST)
└── starship.toml     # prompt (ANSI colors → follows the terminal theme)
```

`.zshrc` sources `env → vi-mode → aliases → tools → prompt → plugins`. Order matters: env sets
`$EDITOR` before tools read it; **vi-mode loads before tools** (it rebinds the keymaps, so fzf/atuin
must bind *after* it); the prompt initialises over a ready shell; **plugins load last** because
zsh-syntax-highlighting must be the final thing sourced to wrap every other line-editor widget.
Anything machine-local or secret goes in `~/.zshrc.local` (git-ignored), sourced at the end.

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

## Plugins & power-ups

[`plugins.zsh`](./plugins.zsh) is sourced **last** from `.zshrc` and loads three zsh enhancements
(all from the Brewfile, each a silent skip if missing). Order is load-bearing:
**autosuggestions → fzf-tab → syntax-highlighting**, with syntax-highlighting strictly last so it
wraps every other line-editor widget.

| Plugin / tool | Gives you |
|---|---|
| [**zsh-autosuggestions**](https://github.com/zsh-users/zsh-autosuggestions) | grey inline suggestion from history as you type — **→** (right arrow) accepts it |
| [**fzf-tab**](https://github.com/Aloxaf/fzf-tab) | **Tab** completion becomes a fuzzy fzf menu |
| [**zsh-syntax-highlighting**](https://github.com/zsh-users/zsh-syntax-highlighting) | colours the command line live (valid command green, error red) — loaded last |

Two more power-ups live in the other role files: **[eza](https://github.com/eza-community/eza)** backs
`ls`/`ll`/`la`/`lt` when installed (icons, `--git` status, `--tree`), falling back to plain `ls`
otherwise (`aliases.zsh`); **[bat](https://github.com/sharkdp/bat)** is wired as the `MANPAGER` for
syntax-highlighted man pages — we do **not** alias `cat` (it breaks `cat > file`) (`tools.zsh`).

## The prompt

`starship.toml` styles the prompt with the terminal's **16 ANSI colors** (no hardcoded palette), so it
**follows Ghostty's live theme repaint** — Catppuccin Latte in light, Mocha in dark — with zero
switching logic, the same way the rest of the stack tracks the macOS appearance. A compact two-line
format: directory · git branch/status · command duration, then the `❯` character (green ok / red
error). The git-branch glyph needs a Nerd Font (the stack assumes one).

## Keeping `$HOME` tidy — XDG base directories

`env.zsh` exports the [XDG base dirs](https://specifications.freedesktop.org/basedir/latest/)
(`XDG_CONFIG_HOME` · `XDG_DATA_HOME` · `XDG_STATE_HOME` · `XDG_CACHE_HOME`), so XDG-aware tools
(Neovim, atuin, bat, fd, gh, zoxide, …) keep their files under `~/.config` / `~/.local` / `~/.cache`
instead of scattering dotfiles across `$HOME`. It also redirects four common offenders that **don't**
follow XDG on their own — each via the tool's own documented variable (these are regenerable
history/cache, so a fresh path is safe):

| Was in `$HOME` | Now | Variable |
|---|---|---|
| `~/.zsh_history` | `~/.local/state/zsh/history` — existing history is **moved** over once | `HISTFILE` |
| `~/.lesshst` | `~/.local/state/less/history` | `LESSHISTFILE` |
| `~/.node_repl_history` | `~/.local/state/node/repl_history` | `NODE_REPL_HISTORY` |
| `~/.python_history` | `~/.local/state/python/history` | `PYTHON_HISTORY` (Python ≥ 3.13) |
| `~/.npm` (cache) | `~/.cache/npm` | `NPM_CONFIG_CACHE` |

**What we deliberately leave alone.** Tools whose `$HOME` dir holds real **state or secrets** are not
auto-redirected: repointing the variable doesn't move existing data, so it would hide your current
auth/config behind an empty path. Move the directory first, then export the var yourself in
`~/.zshrc.local`:

| Tool | Var → target | Why it's opt-in |
|---|---|---|
| Docker | `DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"` | `config.json` holds registry auth — `mv ~/.docker …` first |
| Rust | `CARGO_HOME="$XDG_DATA_HOME/cargo"` · `RUSTUP_HOME="$XDG_DATA_HOME/rustup"` | large toolchain dirs — move before re-pointing |
| AWS | `AWS_CONFIG_FILE` · `AWS_SHARED_CREDENTIALS_FILE` | credentials are secret — move the files or auth breaks |
| GnuPG | `GNUPGHOME` | 0700 perms + agent sockets make relocation fragile — best left at `~/.gnupg` |

A few `$HOME` entries can't move from the shell at all and stay put: `~/.zshrc` (zsh must read one
file from `$HOME`), `~/.gitconfig` (your identity — [git/](../git/README.md)), `~/.claude/`, and
Finder's `.DS_Store`.

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

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
