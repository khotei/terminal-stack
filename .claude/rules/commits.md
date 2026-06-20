# Commit message convention

**Always-loaded rule.** Every commit in this repo MUST follow this format so any future
Claude Code session can `git log -p` on a branch and reconstruct full context without
re-reading Notion. This combines [gitmoji](https://gitmoji.dev/),
[Conventional Commits](https://www.conventionalcommits.org/),
[Chris Beams' 7 rules](https://cbea.ms/git-commit/), and a mandatory `Decision:` paragraph
(the "Contextual Commits / Lore" pattern for AI-readable history).

## Format

```
<gitmoji> <type>(<scope>): <subject>

<body — what + why, wrapped at 72 chars>

Decision: <non-obvious choice: trade-off, alternative rejected, or downstream implication>

Refs: <Notion task URL>
```

### Subject line (Chris Beams' 7 rules)

1. Separate subject from body with a blank line.
2. Limit the subject line to **≤50 characters** (the `<gitmoji> <type>(<scope>):` prefix is
   not counted against the 50, but keep the whole line legible).
3. Capitalise the subject.
4. Do **not** end the subject with a period.
5. Use the **imperative mood** ("Add", not "Added"/"Adds").
6. Wrap the body at **72 characters**.
7. Use the body to explain **what** and **why**, not how.

### Scope

- Tracked tasks: `F-AREA-NNN/T0N` (e.g. `F-MUX-001/T01`).
- Otherwise the tool/area name: `ghostty`, `zellij`, `nvim`, `zsh`, `starship`, `meta`, `ci`, etc.

### Decision paragraph

Mandatory whenever a choice is non-obvious — a trade-off made, an alternative rejected (this
keybind over that one and why), or a downstream implication. Trivial/mechanical commits may omit
it, but prefer including it.

### Refs footer

`Refs:` with the Notion task URL (and any related page). Last line of the message.

## Gitmoji table (covers ~90% of commits)

| Gitmoji | Code | Use for |
|---|---|---|
| ✨ | `:sparkles:` | `feat` — a new capability / keybind / plugin |
| 🐛 | `:bug:` | `fix` — a broken config / collision fix |
| ♻️ | `:recycle:` | `refactor` — restructure config without behaviour change |
| 🔨 | `:hammer:` | tooling / dev scripts |
| 📝 | `:memo:` | `docs` — README / cheatsheet |
| 🔧 | `:wrench:` | `config` — config files (the common case here) |
| 💄 | `:lipstick:` | theme / appearance |
| 🔒 | `:lock:` | security |
| 🚧 | `:construction:` | WIP — work in progress |

(Repo bootstrap may also use 🎉 `:tada:` for the initial commit.)

## Conventional Commits types

`feat` · `fix` · `refactor` · `chore` · `docs` · `config` · `ci`

## Worked example (feat — the full shape)

```
:sparkles: feat(zellij): Add ctrl+a>n to spawn a new tab

Bind the new-tab action under the existing ctrl+a prefix so tab
creation matches the pane keys already on that prefix.

Decision: Put new-tab on the ctrl+a prefix rather than a bare ctrl+t —
ctrl+t is claimed by fzf's file widget in the shell, and routing every
multiplexer action through one prefix keeps Ghostty's keymap free for
the terminal itself.

Refs: https://app.notion.com/p/<task-url>
```

More worked examples — `fix` (with `Decision`), `refactor` (the *no-`Decision`* case), and the
bootstrap `chore` (the `F-AREA-NNN/T0N` scope + the repo's permission policy) — live in
`.claude/agent-patterns/commit-examples.md` (on-demand; read it when a non-trivial commit needs a model).
