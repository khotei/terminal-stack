# 🤖 Claude Code — the agent layer

How Claude Code lives inside the stack: a custom **status line**, the **pane layout** it runs in, and
a **worktree** helper for running several agents in parallel.

> **Note on directories.** This `claude/` folder is the *user-facing* Claude Code config — it installs
> to `~/.claude/`. It is **not** the repo's own [`.claude/`](../.claude/), which is the SDD toolkit
> that *builds* this repo. Two different things, deliberately separate.

- **Files:** [`statusline.sh`](./statusline.sh) → `~/.claude/statusline.sh`,
  [`settings.json`](./settings.json) → `~/.claude/settings.json`,
  [`rules/*.md`](./rules/) → `~/.claude/rules/` (one link per file),
  [`cc-worktree.sh`](./cc-worktree.sh) → a `$PATH` dir, [`mcp-setup.sh`](./mcp-setup.sh) → run once
- **Validate:** `bash -n` (syntax) + valid JSON + a mock-input render — run by `/check` + CI
- **Feature:** `F-AGENT-001` … `F-AGENT-004` · **Upstream:** <https://code.claude.com/docs/en/statusline> · <https://code.claude.com/docs/en/memory> · <https://code.claude.com/docs/en/settings> · <https://code.claude.com/docs/en/mcp>

---

## Status line

`statusline.sh` reads Claude Code's session JSON on stdin and prints one line:

```
Opus 4.8   terminal-stack   feat/x*   23% ctx   $0.04
   model        dir          git¹     context²    cost
```
¹ branch, `*` = uncommitted changes · ² context-window usage. Colours are Catppuccin Mocha accents;
the glyphs need a Nerd Font (the stack assumes one). Falls back from `jq` to `grep` if `jq` is absent.

**It's already enabled** — [`settings.json`](./settings.json) (linked to `~/.claude/settings.json` by
`install.sh`) carries the `statusLine` block, so a fresh install shows the line with no hand-editing:

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
echo '{"model":{"display_name":"Opus"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":25},"cost":{"total_cost_usd":0.04}}' \
  | ./statusline.sh
```

## The pane layout — editor │ agent

Claude Code is a TUI, so it lives in a **Zellij pane** next to Neovim, not an IDE sidebar. Use the
[`dev` layout](../zellij/layouts/dev.kdl) shipped with the Multiplexer layer:

```sh
zellij --layout dev      # left: editor · right (40%): agent
```

Switch editor ↔ agent with Zellij's direct focus keys (`Alt+h`/`Alt+l`); [`zellij-autolock`](../zellij/README.md#autolock)
is on by default, so keys otherwise pass straight through to whichever app is focused. To reach the
full multiplexer from inside a locked agent pane, press `Alt+z`.

## Parallel agents — git worktrees

Two agents in one working tree **fight** — they overwrite each other's edits and stage stale
snapshots. The fix is a **git worktree per agent**: its own directory + branch, one shared `.git`, so
file races are impossible. `cc-worktree.sh` makes the worktree **and** opens a Zellij `dev` session
(editor │ agent) in it:

```sh
cc-worktree.sh feat/new-thing          # → ../<repo>-feat-new-thing/ + a Zellij dev session
cc-worktree.sh fix/bug origin/main     # branch from a specific base instead of HEAD
```

It creates a **sibling** `../<repo>-<branch>/` (outside the repo — never shows as untracked), checks
out the branch there, and (if Zellij is installed) opens a `dev`-layout session named after the
branch. Install by symlinking onto your `$PATH`:

```sh
ln -sf "$PWD/claude/cc-worktree.sh" ~/.local/bin/cc-worktree
```

Claude Code also has worktrees **built in** — `claude --worktree <name>` (a lone agent session, no
editor pane, in `.claude/worktrees/`), desktop `⌘N` (auto-isolated sessions), and `isolation:
worktree` for subagents. [`settings.json`](./settings.json) ships **`worktree.baseRef: "head"`** so a
native worktree branches from your *current* work, not the remote default.

> **The full model** — why they collide, the two isolation modes, launching each, and **merging the
> parallel branches back** — is [`docs/parallel-agents.md`](../docs/parallel-agents.md). Read it
> before running two agents on real code at once.

## Global rules — `rules/`

Each file in [`rules/`](./rules/) installs to `~/.claude/rules/<file>`, Claude Code's **user-level
rules** — loaded into every session, in every project ([docs](https://code.claude.com/docs/en/memory)).
A rule with **no `paths:` frontmatter loads always** (same priority as `~/.claude/CLAUDE.md`); add a
`paths:` glob list and it loads only when Claude touches matching files. Versioning rules here means a
fresh machine gets the same Claude behavior as the rest of the stack.

The first rule shipped is [`communication-style.md`](./rules/communication-style.md) — the persona's
**"dials"** (language, register, tone, lexicon).

- **Switch the style:** edit one dial line in [`communication-style.md`](./rules/communication-style.md)
  — e.g. `Тон → дружелюбно, на «ты»`, `Язык → English`, `Эмодзи → отключить`. The framework survives;
  only the value changes.
- **Add a rule:** drop a new `.md` in [`rules/`](./rules/) and re-run `./install.sh` — it links each
  file on its own (like `zsh/*.zsh`), so machine-local rules you keep directly in `~/.claude/rules/`
  coexist, and `./install.sh --prune` only ever removes *our* stale links. Keep each rule focused;
  prefer a new file over growing one past ~200 lines (the upstream size guidance).

## Settings, plugins & MCP

[`settings.json`](./settings.json) is the whole user-facing Claude Code config, linked to
`~/.claude/settings.json`. Beyond `statusLine` it declares **`enabledPlugins`** — so a trusted fresh
machine reinstalls them from the **preloaded** `claude-plugins-official` marketplace
([docs](https://code.claude.com/docs/en/discover-plugins)):

| Plugin | What it adds |
|---|---|
| `typescript-lsp` | TS/JS go-to-definition, find-references, post-edit diagnostics — a **plugin**, not an MCP, so it costs no MCP slot |
| `commit-commands` | `/commit`, `/push`, create-PR commands |
| `pr-review-toolkit` | PR-review agents |

**Why no GitHub MCP.** `gh` is already installed and authed ([`Brewfile`](../Brewfile)); for a fluent
`gh` user the GitHub MCP is heavier (more tokens, PR flakiness) for no gain. Git + GitHub run through
`gh` via the shell; the two plugins above add the ergonomic slash-commands on top. Add the GitHub MCP
only if you later want typed cross-repo tooling.

**MCP servers.** [`mcp-setup.sh`](./mcp-setup.sh) registers two **user-scope** servers, idempotently —
`install.sh` runs it best-effort (skipped if `claude` is absent), or run it yourself any time:

| Server | Auth | |
|---|---|---|
| `notion` (`https://mcp.notion.com/mcp`) | **OAuth** — `/mcp → notion → Authenticate` once; token in the OS keychain | the SDD knowledge base |
| `context7` (`https://mcp.context7.com/mcp`) | **keyless** | up-to-date library docs in context |

Neither server puts a secret in the repo (this repo is **public**). For any *future* token-based
server, reference it as `${VAR}` in the MCP config and keep the real value in the git-ignored
`~/.zshrc.local` — never a committed file ([`config.md`](../.claude/rules/config.md) §Secrets). Don't
also enable a `notion` *plugin*: it would double the hosted MCP's tools.

## Verify

- `bash -n claude/*.sh` — syntax clean (run by `/check` + CI).
- `settings.json` is valid JSON (`jq . claude/settings.json`).
- Status line renders from mock JSON (verified: model · dir · git · context% · cost).
- Try the layout live in the sandbox: `make zellij`.

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).
