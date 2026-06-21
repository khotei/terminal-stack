# 📦 Install

Provision the whole stack on a fresh macOS machine in two steps: install the toolchain with
Homebrew, then symlink the configs into place. Feature: `F-META-002`.

```sh
git clone https://github.com/khotei/terminal-stack.git ~/terminal-stack
cd ~/terminal-stack

brew bundle          # 1. install the toolchain (see ./Brewfile)
./install.sh         # 2. symlink the configs into ~/.config etc.
```

## 1. `brew bundle` — the toolchain

[`Brewfile`](../Brewfile) pins every tool: Ghostty (cask), Zellij, Neovim, Starship, the companion
CLIs (zoxide · atuin · fzf · fd · ripgrep · lazygit · yazi · jq), the validators (stylua · shfmt),
and Nerd Fonts. All names are verified against Homebrew.

```sh
brew bundle              # install everything
brew bundle check        # is everything installed?
brew bundle list         # list the deps
```

> **Dank Mono** (Ghostty's primary font) isn't on Homebrew — install it yourself, or switch
> `ghostty/config`'s `font-family` to `JetBrainsMono Nerd Font` (installed by the Brewfile).

## 2. `install.sh` — symlink the configs

[`install.sh`](../install.sh) links each layer to where its tool expects it:

| Repo | → | Installed |
|---|---|---|
| `ghostty/config` | → | `~/.config/ghostty/config` |
| `zellij/` | → | `~/.config/zellij` |
| `nvim/` | → | `~/.config/nvim` |
| `zsh/.zshrc` · `zsh/*.zsh` · `zsh/starship.toml` | → | `~/.zshrc` · `~/.config/zsh/` · `~/.config/starship.toml` |
| `claude/statusline.sh` · `claude/cc-worktree.sh` | → | `~/.claude/statusline.sh` · `~/.local/bin/cc-worktree` |

It is **idempotent** and **safe**:
- Re-running relinks nothing already correct (reports `ok`).
- A real file/dir in the way is backed up to `<path>.bak` before linking.
- `./install.sh --dry-run` shows what it would do, changing nothing.

## 3. Finish

- Add the status-line block to `~/.claude/settings.json` (see [`claude/README.md`](../claude/README.md)).
- Open a new terminal (zsh + Starship loads), then `zellij --layout dev` for the editor │ agent split.
- First `nvim` launch installs the LazyVim plugins.

## Updating

Because the configs are **symlinks into the repo**, a `git pull` already updates their *content* —
the installed file *is* the repo file. You only need more than `git pull` in two cases:

| You want to… | Run |
|---|---|
| Pick up edited config content | `git pull` (symlinks already point at the files) — then reload the tool |
| Link **newly added** files / remove links for **deleted** ones | `./install.sh --prune` |
| Upgrade the **tools** (brew) + everything above, in one shot | `make update` |

### `./install.sh --prune`
Re-links anything new and **removes our stale symlinks** — links pointing into the repo whose target
was deleted (e.g. you removed a `zsh/*.zsh` role file). It only ever touches symlinks that point into
this repo and are broken; a valid link, or any symlink pointing elsewhere, is left alone. Preview with
`./install.sh --dry-run --prune`.

> `nvim/` and `zellij/` are whole-directory symlinks, so files added *inside* them appear
> automatically — no re-install. The per-file `zsh/*.zsh` links are where `--prune` earns its keep.

### `make update` — the one-command update
```sh
make update
```
Runs, in order: `git pull --ff-only` → `brew update` → `brew bundle` (install any newly-added tool)
→ `brew upgrade` for the Brewfile's formulae **and** casks → `./install.sh --prune`. It finishes by
reminding you to run **`:Lazy update`** in Neovim and commit the refreshed `nvim/lazy-lock.json` to
pin the new plugin versions.

> `make update` upgrades only the tools the Brewfile lists — it won't touch the rest of your Homebrew.

## Verify without installing

Prefer to try before you touch your machine? The [Docker sandbox](sandbox.md) runs the in-terminal
layers disposably: `make try`.
