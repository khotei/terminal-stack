# 🐳 Sandbox & validation

A disposable **Linux container** to spin up and try the stack without touching your machine, plus the
**shared validator** that gates every PR. Feature: `F-META-001`.

> **Why not Ghostty too?** Ghostty is a host-side **GPU/GUI** terminal — it draws a window, it
> doesn't run *inside* a shell. So it can't live in a headless container. The sandbox covers
> everything that runs *inside* the terminal — **Zellij, Neovim, zsh, Starship** — which is the whole
> interactive stack. Ghostty's config is validated separately by `ghostty +show-config` on a real
> machine (the validator notes-skips it everywhere else).

---

## Quick start

```sh
make try      # build + drop into an interactive zsh in the sandbox (repo mounted live)
make zellij   # build + jump straight into Zellij
make check    # run the validators inside the sandbox (Linux-accurate)
make clean    # remove the image
make help     # list targets
```

The repo is **bind-mounted** at `/work`, so edits on your host are live in the container — change a
config, re-run, see the result. Nothing is installed on your machine.

## What's in the image

`debian:bookworm-slim`, arch-aware (builds natively on Intel **and** Apple Silicon):

| Tool | Source | Role |
|---|---|---|
| **Zellij** | latest musl release | multiplexer |
| **Neovim** | `stable` release tarball | editor |
| **zsh** + **Starship** | apt + install script | shell + prompt |
| ripgrep · fd · fzf · zoxide | apt | companion CLIs |

The sandbox now includes **Zellij**, **Neovim**, and **zsh + Starship** (plus the companion CLIs).
On start, [`scripts/entrypoint.sh`](../scripts/entrypoint.sh) symlinks whatever config layers the
repo has into `~/.config`, **skipping any that are absent**. Ghostty is host-only — the terminal
itself isn't run inside the container.

> **Note:** the image carries the core in-terminal layers (Zellij, Neovim, zsh, Starship,
> ripgrep/fd/fzf/zoxide/atuin). The newer power-ups — **eza**/**bat**/**delta** and the zsh plugins
> (autosuggestions, syntax-highlighting, fzf-tab) — are **not** baked into the sandbox; install them
> via `brew bundle` on a real machine.

## Validation — `scripts/check.sh`

One script is the **single source of validation truth**, run identically by `make check`, by CI, and
by the `/check` Claude command ([`.claude/commands/check.md`](../.claude/commands/check.md)) — so
local and CI never drift.

**Contract:** run each tool's validator **iff** both the config and the tool are present; otherwise
print a `↷ skip` note. Exit non-zero **only on a real failure**. Style gates (`stylua`, `shfmt`) are
soft — they warn, never fail.

| Layer | Validator | Gate |
|---|---|---|
| Ghostty | `ghostty +show-config` | hard (host-only → usually skipped) |
| Zellij | `zellij --config zellij/config.kdl setup --check` | hard |
| Neovim | `nvim --headless -u nvim/init.lua +qa` (timeout-guarded) | hard |
| Shell | `zsh -n <file>` per `zsh/*.zsh`, `zsh/.zshrc` | hard |
| Lua style | `stylua --check nvim/` | soft |
| Shell style | `shfmt -d zsh/` | soft |

> **Neovim caveat:** loading a LazyVim config triggers first-run plugin bootstrap (network). The
> validator is a timeout-guarded load and may pull plugins; CI caching / a lighter check will be
> tuned when the **Editor** feature lands.

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs on every PR and every push to `main`:
it installs the same toolchain and runs `scripts/check.sh`. No separate CI logic — the script *is*
the gate.

## References

- Neovim releases — `stable`, `nvim-linux-<arch>.tar.gz` · <https://github.com/neovim/neovim/releases>
- Zellij releases — `zellij-<arch>-unknown-linux-musl.tar.gz` · <https://github.com/zellij-org/zellij/releases>
- Starship install — <https://starship.rs/install.sh>
