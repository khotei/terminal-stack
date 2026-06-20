---
description: "Phase 2 (Clarify): grill-me loop — resolve every [TBD] in a feature spec"
argument-hint: "F-AREA-NNN"
---

<!-- Generated from the Terminal Stack SDD hub §7.3 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running **Phase 2 (Clarify)** of the Terminal Stack SDD hub on `$ARGUMENTS`.

**Adopt the spec-author discipline** (`@.claude/agents/spec-author.md`): ground every claim in a
source, invent nothing (no invented config keys), never write config, ACs in EARS, Notion-only
artifacts.

> **This phase runs in the main context — NOT a forked subagent — on purpose.** The grill-me loop
> needs `AskUserQuestion`, and that tool (plus any mid-run pause for your input) is unavailable to
> subagents. So clarify is human-in-the-loop in the main thread; it borrows the spec-author *role*
> by reference, not as a hard tool-lock. See `@.claude/rules/sdd.md` (fork map).

**Goal:** drive `$ARGUMENTS` to **zero `[TBD]` blockers** — every unresolved decision either
answered (spec updated) or explicitly deferred.

## Steps

1. **Fetch the feature page** (`$ARGUMENTS`) from the Features DB and read it end to end.
2. **Walk the whole decision tree** — don't just collect existing `[TBD]`s. Surface every
   unresolved decision the spec implies, including assumptions the author never flagged (which exact
   key, whether it collides with the multiplexer prefix, whether the tool hot-reloads).
3. **Self-answer first.** Before asking anything, try to resolve each question from the upstream
   docs (`WebFetch` ghostty.org / zellij.dev / lazyvim.org / neovim.io / starship.rs), the existing
   config (`Read`/`Grep`/`Glob` over `ghostty/`, `zellij/`, `nvim/`, `zsh/`), and any Research page.
   Only escalate what *genuinely* needs a human — taste/ergonomics calls, muscle-memory-changing
   keybinds.
4. **For every remaining question, recommend an answer.** Propose 2–3 options with trade-offs (cite
   upstream docs/research) and state your recommendation. Never ask what the docs or existing config
   already decide.
5. **Ask via `AskUserQuestion`.** One question at a time when a decision depends on the previous
   answer; batch only genuinely independent questions (≤4 per round). Put your recommended option
   **first**, suffixed `(Recommended)`.
6. **After each answer, update the spec inline** (Notion) and add a **change-log row** capturing the
   decision and *why* — one row per resolved question.
7. **Exit at the gate:** zero `[TBD]` blockers in any AC, requirement, or dependency. Items may be
   explicitly deferred — mark them `[TBD — later]` (or similar) — but never leave one silent.
8. **End with one line:** `Clarify complete for $ARGUMENTS. Resolved: <n>, deferred: <m>. Next: /sdd:plan $ARGUMENTS.`

## Do not

- Do **not** write or run config — you're in the intent layer. If a question can only be answered by
  building something, it belongs in Plan/Implement; note it and move on.
- Do **not** silently pick an answer for a genuine taste/ergonomics call — recommend, then ask.
- Do **not** invent a config key to close a gap — confirm it upstream or mark it deferred.
