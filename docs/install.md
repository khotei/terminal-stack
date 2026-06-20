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

## Verify without installing

Prefer to try before you touch your machine? The [Docker sandbox](sandbox.md) runs the in-terminal
layers disposably: `make try`.
