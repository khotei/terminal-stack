# 🤖 Claude Code — the agent layer

How Claude Code lives inside the stack: a custom **status line**, the **pane layout** it runs in, and
a **worktree** helper for running several agents in parallel.

> **Note on directories.** This `claude/` folder is the *user-facing* Claude Code config — it installs
> to `~/.claude/`. It is **not** the repo's own [`.claude/`](../.claude/), which is the SDD toolkit
> that *builds* this repo. Two different things, deliberately separate.

- **Files:** [`statusline.sh`](./statusline.sh) → `~/.claude/statusline.sh`,
  [`cc-worktree.sh`](./cc-worktree.sh) → a `$PATH` dir
- **Validate:** `bash -n` (syntax) + a mock-input render — run by `/check` + CI
- **Feature:** `F-AGENT-001` · **Upstream:** <https://code.claude.com/docs/en/statusline>

---

## Status line

`statusline.sh` reads Claude Code's session JSON on stdin and prints one line:

```
Opus 4.8   terminal-stack   feat/x*   23% ctx   $0.04
   model        dir          git¹     context²    cost
```
¹ branch, `*` = uncommitted changes · ² context-window usage. Colours are Catppuccin Mocha accents;
the glyphs need a Nerd Font (the stack assumes one). Falls back from `jq` to `grep` if `jq` is absent.

**Enable it** — add to `~/.claude/settings.json` (merge, don't overwrite):

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

Fields consumed: `.model.display_name`, `.workspace.current_dir`, `.context_window.used_percentage`,
`.cost.total_cost_usd` ([schema](https://code.claude.com/docs/en/statusline)). Test it:

```sh
echo '{"model":{"display_name":"Opus"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":25}}' \
  | ./statusline.sh
```

## The pane layout — editor │ agent

Claude Code is a TUI, so it lives in a **Zellij pane** next to Neovim, not an IDE sidebar. Use the
[`dev` layout](../zellij/layouts/dev.kdl) shipped with the Multiplexer layer:

```sh
zellij --layout dev      # left: editor · right (40%): agent
```

Switch editor ↔ agent with the Zellij prefix nav (`ctrl+a h/l`), or enable
[`zellij-autolock`](../zellij/README.md#autolock-opt-in--seamless-editoragent-passthrough) so keys
pass straight through to whichever app is focused.

## Parallel agents — git worktrees

To run several Claude Code agents on the same repo at once without collisions, give each its own
**git worktree** + Zellij session. `cc-worktree.sh` does both:

```sh
cc-worktree.sh feat/new-thing          # worktree off HEAD + a Zellij dev session
cc-worktree.sh fix/bug origin/main     # worktree off a specific base
```

It creates `../<repo>-<branch>/`, checks out the branch there, and (if Zellij is installed) opens a
`dev`-layout session named after the branch. Install by symlinking onto your `$PATH`:

```sh
ln -sf "$PWD/claude/cc-worktree.sh" ~/.local/bin/cc-worktree
```

## Verify

- `bash -n claude/*.sh` — syntax clean (run by `/check` + CI).
- Status line renders from mock JSON (verified: model · dir · git · context% · cost).
- Try the layout live in the sandbox: `make zellij`.
