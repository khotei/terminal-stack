# 📦 Install

| Path | What it does |
|---|---|
| **Try first** — `make try` | The in-terminal layers (Zellij + Neovim + Starship) in a disposable Docker container. No Ghostty, nothing touched on your machine. See [`sandbox.md`](sandbox.md). |
| **Commit** — `./bootstrap.sh` | The full stack incl. Ghostty + fonts. Installs Homebrew + the toolchain and symlinks the configs — **modifies your machine** (safely; see below). |

## Fresh Mac — one command

`bootstrap.sh` takes a clean machine from zero: it ensures the **Xcode Command Line Tools**, installs
**Homebrew** if missing, runs `brew bundle`, then `install.sh`. Idempotent — anything already present
is skipped. Feature: `F-META-005`.

```text
  ./bootstrap.sh  ──  four stages, in order
      ①  Xcode CLT     git · compiler · make             (prep · skipped if present)
      ②  Homebrew      the package manager               (prep · skipped if present)
      ③  brew bundle   the toolchain — Ghostty · Zellij · Neovim · Starship · CLIs · fonts
      ④  install.sh    symlink configs → ~/.config · copy fonts · fetch autolock plugin
```

If you already have Homebrew, you only need stages ③–④ (the
[two steps](#already-have-homebrew--the-two-steps) below); `bootstrap.sh` just adds the ①–② prep.

```sh
git clone https://github.com/khotei/terminal-stack.git ~/terminal-stack
cd ~/terminal-stack
./bootstrap.sh        # or: make bootstrap
```

> The Homebrew installer also installs the Command Line Tools (git/cc) if they're missing — a dialog
> may appear; accept it. On **Linux**, install Homebrew yourself first, then run `brew bundle &&
> ./install.sh` (`bootstrap.sh` is macOS-only and will say so).

## Already have Homebrew — the two steps

```sh
brew bundle          # 1. install the toolchain (see ./Brewfile)
./install.sh         # 2. symlink the configs into ~/.config etc.
```

## 1. `brew bundle` — the toolchain

[`Brewfile`](../Brewfile) is organised in three sections: **The stack** (Ghostty, Zellij, Neovim,
Starship, **Claude Code**, the companion CLIs, validators, `gh`, Docker, Nerd Fonts), **Personal**
(the GUI apps that drive the machine — Arc, Notion, Raycast, …), and **Development** (bun, fnm, …).
Tools the stack **retires** (`intellij-idea` → Neovim, `warp` → Ghostty) are kept **commented** for
reference, not installed. All names are verified against Homebrew.

> **Trim the Personal section first.** `brew bundle` pulls the GUI casks (Arc, Notion, Raycast, …) —
> on a work machine or one you've already set up, comment out what you don't want **before** running
> it. Re-run `brew bundle` any time to pick up what you later uncomment.

```sh
brew bundle              # install everything
brew bundle check        # is everything installed?
brew bundle list         # list the deps
```

> **Claude Code installs here.** `brew bundle` installs it via `cask "claude-code"`. It needs an
> Anthropic account — run `claude` once after install and log in.

> **Dank Mono** (Ghostty's primary font) isn't on Homebrew — it's **bundled under `fonts/`** and
> installed by `install.sh` (step 2). Prefer a free font? Switch `ghostty/config`'s `font-family` to
> `JetBrainsMono Nerd Font` (installed by the Brewfile). See [`fonts/README.md`](../fonts/README.md).

> **Node for the editor's TypeScript LSP.** Neovim's TS support (vtsls, installed by mason) needs a
> Node runtime. The Brewfile installs **fnm**, `bootstrap.sh` installs a default LTS, and
> `zsh/tools.zsh` puts it on `PATH`. Installing by hand (no `bootstrap.sh`)? Run it once:
> `fnm install --lts && fnm default lts-latest`.

## 2. `install.sh` — symlink the configs

[`install.sh`](../install.sh) links each layer to where its tool expects it:

| Repo | → | Installed |
|---|---|---|
| `ghostty/config` | → | `~/.config/ghostty/config` |
| `zellij/` | → | `~/.config/zellij` |
| `nvim/` | → | `~/.config/nvim` |
| `zsh/.zshrc` · `zsh/*.zsh` · `zsh/starship.toml` | → | `~/.zshrc` · `~/.config/zsh/` · `~/.config/starship.toml` |
| `git/config` | → | `~/.config/git/config` (additive; never touches `~/.gitconfig`) |
| `claude/statusline.sh` · `claude/cc-worktree.sh` | → | `~/.claude/statusline.sh` · `~/.local/bin/cc-worktree` |
| `fonts/*.otf` | ⇒ | `~/Library/Fonts` (macOS) · `~/.local/share/fonts` (Linux) — **copied**, skip-if-present |

It is **idempotent** and **safe**:
- Re-running relinks nothing already correct (reports `ok`); a font already installed is skipped.
- A real file/dir in the way is backed up to `<path>.bak` before linking.
- `./install.sh --dry-run` shows what it would do, changing nothing.
- Fonts are **copied** (not symlinked), so `--prune` never touches them.
- It also **fetches the `zellij-autolock` plugin wasm** (best-effort) so autolock — on by default —
  works out of the box; offline, it just stays inert (harmless).

## 3. Finish

### Status line

```json
// ~/.claude/settings.json — create the file if it doesn't exist; otherwise merge this key in
{ "statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 0 } }
```

If the file already exists, add only the `statusLine` key — don't replace the whole file (invalid JSON
silently disables the status line). It needs `jq` (in the Brewfile) and a Nerd Font. Verify by
launching `claude` — the line appears at the bottom. (More detail in
[`claude/README.md`](../claude/README.md).)

- Open a new terminal (zsh + Starship loads), then `zellij --layout dev` for the editor │ agent split.
- First `nvim` launch installs the LazyVim plugins.
- The shell keeps `$HOME` tidy — tool histories/caches go under `~/.local/state` · `~/.cache` (XDG),
  not scattered dotfiles; an existing `~/.zsh_history` is moved over once. See
  [`zsh/README.md`](../zsh/README.md).

### Git identity

The repo's `git/config` is **additive** — delta + sane defaults, but **no `[user]` block**, so your
name/email never live in this public repo. Set them on this machine (or change them later):

```sh
make git-setup        # interactive; or: ./git/setup.sh --show · --dry-run · --name/--email
```

It writes only to `~/.gitconfig` (never the shared config). See [`git/README.md`](../git/README.md).

### Optional: macOS system defaults

Want the OS itself tuned for this keyboard-first workflow (Dock auto-hide, full trackpad gestures,
**fast key-repeat for Vim**, and the `⌘⇧/` Help / man-page shortcuts disabled)? Run the opt-in
[`macos/defaults.sh`](../macos/README.md):

```sh
./macos/defaults.sh --dry-run   # preview every change
make macos                      # apply (then log out/in for key-repeat + shortcuts)
```

It's **not** run by `bootstrap.sh`/`install.sh` — it changes system settings, so you opt in. Every
setting is reversible; see [`macos/README.md`](../macos/README.md).

## Troubleshooting

**First, run `make doctor`** — a read-only health-check that tells you, line by line, whether each
tool is installed, each config is symlinked, and the fonts/plugin/`$PATH` are right (with the fix for
anything that isn't). Then, if needed:

| Symptom | Fix |
|---|---|
| Install stalls early on a fresh Mac | The **Xcode Command Line Tools** dialog is waiting — accept it, then re-run. |
| `cc-worktree: command not found` | `~/.local/bin` must be on `$PATH` — `zsh/env.zsh` adds it, so **open a new shell**. (Using a different shell? Add `~/.local/bin` to its `$PATH`.) |
| Icons show as boxes (□) | Fonts need a **terminal restart** to be picked up after `install.sh` copies them. Restart Ghostty. |
| Status line is blank | Check `jq` is installed (Brewfile), that `~/.claude/settings.json` is **valid JSON** (a syntax error silently disables it), and that you're using a **Nerd Font**. |
| "Did install even do anything?" | `./install.sh --dry-run` shows what it would do, changing nothing. |
| Re-running install | It's **idempotent** — anything already correct is reported `ok` and left alone. Safe to run again any time. |

## Uninstall

There's no uninstall script — the install is just symlinks plus copied fonts, so reverting is manual:

- **Remove the symlinks** `install.sh` created (`~/.config/ghostty/config`, `~/.config/zellij`,
  `~/.config/nvim`, `~/.zshrc`, `~/.config/zsh/`, `~/.config/starship.toml`, `~/.claude/statusline.sh`,
  `~/.local/bin/cc-worktree`).
- **Restore your originals:** each path `install.sh` replaced was backed up to `<path>.bak` — move it
  back.
- **Fonts** were *copied* to `~/Library/Fonts` (macOS) / `~/.local/share/fonts` (Linux) — delete the
  Dank Mono files there if you don't want them.

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

## Experimenting without disturbing your setup

The flip side of symlinks: editing a repo file changes your **live** setup the moment the tool
re-reads it (the next `nvim` launch / `:Lazy sync`, a new shell, a Ghostty reload). Great for daily
use, awkward for tinkering. Two ways to experiment safely:

- **Docker sandbox — zero risk.** `make try` runs the in-terminal layers against a throwaway profile;
  nothing on your machine changes, and the repo is mounted live so edits show up inside the container.
  See [`sandbox.md`](sandbox.md).
- **A scratch clone + isolated profile** — when you want it native, not in Docker. Clone elsewhere and
  point Neovim at it via [`NVIM_APPNAME`](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME),
  so it reads `~/.config/<name>/` instead of your real `~/.config/nvim`:
  ```sh
  git clone https://github.com/khotei/terminal-stack.git ~/ts-scratch
  ln -s ~/ts-scratch/nvim ~/.config/ts-scratch
  NVIM_APPNAME=ts-scratch nvim        # isolated; your daily nvim is untouched
  ```
  Tinker there, then copy what you like back into the linked repo. (For a throwaway *branch* of your
  real setup, `claude/cc-worktree.sh` makes a git worktree in one step.)

## Verify without installing

Prefer to try before you touch your machine? The [Docker sandbox](sandbox.md) runs the in-terminal
layers disposably: `make try`.
