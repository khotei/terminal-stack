---
description: "Phase 5 (Implement): take one task to Done — scoped config change, validated, commit per commits.md"
argument-hint: "<task-id or task URL>"
---

<!-- Generated from the Terminal Stack SDD hub §7.6 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running **Phase 5 (Implement)** of the Terminal Stack SDD hub on task `$ARGUMENTS`.

**Adopt the implementer discipline** (`@.claude/agents/implementer.md`): Autonomy gate, validate the
config, stay scoped, living spec, respect the repo rules, commit per `@.claude/rules/commits.md`.

> **This phase runs in the main context — NOT a forked subagent** — so the HITL gate and the
> spec-gap STOP can pause for you. See `@.claude/rules/sdd.md` (fork map).

## Steps

1. **Autonomy gate.** Fetch the task `$ARGUMENTS` and read its `Autonomy`. If `HITL`, surface the
   decision or review it needs and get the human's call **before** writing config; if `AFK`,
   proceed. Move the task to `Status = In progress`.
2. **Read the context.** The parent Feature spec (linked from the task), the upstream doc sections
   it cites, and the task's `Covers ACs:` list. Resolve open questions from the upstream docs +
   existing config (`ghostty/`, `zellij/`, `nvim/`, `zsh/`) before asking the user. **Never invent a
   config key** — if you can't cite it upstream, stop and ask.
3. **Make the scoped config change**, then **validate it loads** via `/check`
   (`@.claude/commands/check.md`) — `ghostty +show-config`, `zellij setup --check`,
   `nvim --headless "+checkhealth"/luafile`, `zsh -n`, `stylua`/`shfmt` as applicable. A config that
   doesn't validate is not Done.
4. **Stay scoped.** Implement only this task. File a **new Tasks-DB row** for any unrelated tweak or
   improvement you find — don't fix it inline.
5. **Living spec.** If implementation reveals a spec gap (a key that doesn't exist, a keybind that
   collides), **STOP** — add a change-log row to the feature page, propose the spec change, and get
   the user's confirmation before continuing.
6. **Finish.** When every AC in `Covers ACs:` passes and `/check` is green, update the cheatsheet /
   README if the change adds a keybinding or alias, commit per `@.claude/rules/commits.md`
   (`Refs: <task URL>`), set the task `Status = Done`, and — if it's the last task in the feature —
   propose `/sdd:verify <feature-id>`.

## Do not

- Do **not** start a task whose `Blocked by` tasks aren't `Done`.
- Do **not** widen scope, invent config keys, or `git commit --no-verify` on `main`.
