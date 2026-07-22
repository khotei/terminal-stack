# Commit message examples (on-demand)

Worked examples for `.claude/rules/commits.md`, which keeps the **format spec + gitmoji table + the
`feat` example** always-loaded. Read this when a non-trivial commit needs a model — the **format
source of truth is the rule**, not these examples.

## fix (with Decision)

```
:bug: fix(nvim): Stop the leader clobbering the multiplexer prefix

LazyVim's default leader was rebound to <space>, but a leftover
ctrl+a mapping in an older keymap module was swallowing the Zellij
prefix when nvim ran inside a pane. Remove the stale mapping.

Decision: Kept <space> as leader rather than moving it — the Zellij
prefix is ctrl+a and the editor must never claim it, so the fix is to
drop the editor binding, not to relocate the multiplexer prefix that
the whole keymap is built around.

Refs: https://app.notion.com/p/<task-url>
```

## refactor (no Decision needed)

```
:recycle: refactor(zsh): Split aliases out of .zshrc into aliases.zsh

Move the alias block into zsh/aliases.zsh sourced from .zshrc, so the
shell config groups by concern (env, aliases, prompt) instead of one
long file.

Refs: https://app.notion.com/p/<task-url>
```

## chore (with Decision) — the bootstrap commit

```
:wrench: chore(F-META-001/T01): Bootstrap repo layout + minimal .claude/

Add the dotfiles skeleton: ghostty/, zellij/, nvim/, zsh/ folders, a
.gitignore (settings.local.json + machine-local state), a README stub,
and a minimal .claude/ (CLAUDE.md, settings.json, the SDD toolkit).

Decision: settings.json pre-approves git add/commit/push + the config
validators (ghostty +show-config, zellij setup, nvim --headless, zsh -n)
so the SDD loop runs unattended, but keeps history-rewriting git
(rebase/reset/branch/checkout) and ad-hoc WebFetch/WebSearch on the
`ask` list as the human-in-the-loop safety belt. Decision: no .mcp.json
is committed — this is a public repo and the Notion connector is
per-machine. Chicken-and-egg: this very commit is commit #1 AND
introduces this rule, so its message was written by hand.

Refs: https://app.notion.com/p/<task-url>
```
