---
description: "Phase 6 (Verify): fresh-context check of every AC + the Definition of Done"
argument-hint: "F-AREA-NNN"
context: fork
agent: verifier
---

<!-- Generated from the Terminal Stack SDD hub §7.7 + §5 (DoD) — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running **Phase 6 (Verify)** of the Terminal Stack SDD hub on `$ARGUMENTS`.

**You are a fresh-context verifier** — you have no memory of how this feature was built (that's why
this command forks into the `verifier` agent). Check **behavior, not authorship**. You never edit
config: on a failure you reopen the task and report, you do not fix it.

## Steps

1. **Read the feature's ACs verbatim** (`$ARGUMENTS`) from Notion.
2. **Check each AC** by running the relevant validator (`/check` — `ghostty +show-config`,
   `zellij setup --check`, `nvim --headless …`, `zsh -n`) and inspecting the produced config, or —
   for a behavior only a keypress can show — by reproducing it and observing the result. Record
   **pass/fail + how verified** (exact command + output, or the observed behavior).
3. **Run the Definition of Done** checklist below, applying each item relevant to the feature.
4. **Write a Verify report** as a collapsible toggle on the feature page (Notion MCP) — one row per
   AC with its verdict + how-verified, then the DoD results.
5. **Decide the gate:** if **every** AC and applicable DoD item passes → set the feature
   `Status = Done`. If anything fails → leave it open, **reopen the relevant task(s)** (`Status`
   back to `In progress`/`Not started`), and list exactly what failed. **Do not silently fix.**

## Definition of Done (§5) — apply what's relevant

- [ ] **Spec updated** — feature change-log has a new row; ACs reflect *shipped* behavior.
- [ ] **All ACs verified** — re-checked against the actual config / a live keypress (this report).
- [ ] **Config validates** — `/check` is green for every touched tool (Ghostty/Zellij/nvim/zsh);
      new keys cite an upstream doc, none invented.
- [ ] **No keybinding collisions** — new binds don't clash with the multiplexer prefix or the editor
      leader. *(Features that add binds only.)*
- [ ] **Cheatsheet / README current** — any new keybinding or alias is documented for the user.
- [ ] **No new `[TBD]`** — any TBD found during build is resolved or filed as a new task.
- [ ] **PR is a reference guide** — the PR body explains each setting's what/why, how to try it, and
      maps to the Feature/ACs (see `@.claude/rules/pull-requests.md`); the Feature's `PR` field is
      set so the reviewer reaches the spec in one click.
- [ ] **Feature `Status = Done`** — and all linked Tasks are `Done`.

## Do not

- Do **not** edit or fix config — reopen the task instead (denied by tool policy anyway).
- Do **not** pass an AC you couldn't observe — "looks right" is a fail.
