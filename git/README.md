# 🔱 Git — the diff & defaults layer

Sensible, **additive** git defaults plus [**delta**](https://github.com/dandavison/delta) as the
pager — syntax-highlighted, side-by-side-capable diffs with line numbers and navigable hunks. This
layer never touches your identity: git reads `~/.config/git/config` **in addition to** `~/.gitconfig`,
so your name/email/signing config in `~/.gitconfig` stays exactly as it is.

- **Files:** [`config`](./config) → `~/.config/git/config`
- **Validate:** `git config --file git/config --list` (parses; lists every key)
- **Feature:** `F-SHELL-003` · **Upstream:** <https://github.com/dandavison/delta>

---

## Settings reference

| Key | Value | Why |
|---|---|---|
| `core.pager` | `delta` | Pipe `git diff` / `git show` / `git log -p` through delta. |
| `interactive.diffFilter` | `delta --color-only` | Colour the hunks in `git add -p`. |
| `delta.navigate` | `true` | `n` / `N` jump between files/hunks in the pager. |
| `delta.line-numbers` | `true` | Show old/new line numbers beside the diff. |
| `merge.conflictStyle` | `zdiff3` | 3-way conflict markers with the common ancestor (clearer merges). |
| `diff.colorMoved` | `default` | Distinguish moved lines from real adds/deletes. |
| `init.defaultBranch` | `main` | New repos start on `main`. |
| `push.autoSetupRemote` | `true` | First `git push` auto-creates the upstream branch. |
| `pull.ff` | `only` | `git pull` only fast-forwards — never an implicit merge commit. |

## Additive — your identity is untouched

Git layers config: it reads the system file, then `~/.config/git/config`, then `~/.gitconfig` (your
home file wins on any conflict). This layer only sets the keys above; it sets **no** `[user]` block,
so your name, email, and signing config in `~/.gitconfig` are never read or overwritten. Remove the
symlink (or `./install.sh --prune`) and these defaults simply fall away.

## Reload & verify

- **Apply:** takes effect on the next `git` command (no reload).
- **Validate:** `git config --file git/config --list` — parses the file and prints every key.
- **See it:** run any `git diff` in a repo with changes — delta renders it. Needs `git-delta` from the
  Brewfile (`brew bundle`).

## Install

`./install.sh` (or `make install`) symlinks `git/config` → `~/.config/git/config`.

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
