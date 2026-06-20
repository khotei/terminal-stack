---
description: "Phase 1 (Specify): draft a Drafted feature row in Notion from a one-line idea"
argument-hint: "<feature idea>"
context: fork
agent: spec-author
---

<!-- Generated from the Terminal Stack SDD hub §7.2 (+ §6.1 template, §4 contract) — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running **Phase 1 (Specify)** of the Terminal Stack SDD hub.

**Input:** a one-line feature idea — `$ARGUMENTS`.
**Goal:** one fully-filled **Feature page** in the Features DB, `Status = Drafted`. Notion-only —
no local `spec.md` (see `@.claude/rules/sdd.md`).

**Embedded — do NOT fetch from Notion** (in-repo, so the run works even if the hub page is
renamed/moved): the feature template `@.claude/sdd/feature-template.md`, the property contract
`@.claude/sdd/property-contract.md`, and the data-source IDs `@.claude/sdd/data-sources.md` (the
Features collection id lives there).
**Fetch live — volatile content:** the upstream docs / Research pages to cite, and the current max
Feature ID.

## Steps

1. **Pick the `Area`** for the idea (exactly one of the §4 enum: Terminal · Multiplexer · Editor ·
   Shell · Agent · Meta). Then find the **current max `Feature ID`** in that area: search the
   Features DB (scope to its data-source id from `@.claude/sdd/data-sources.md`) and assign
   `F-<AREA>-<max+1>`, the number zero-padded to three digits.
2. **Read the sources to cite.** Search the Specs DB for any Research pages, and read the upstream
   doc sections that justify this feature's config choices. Open the relevant existing config in
   `ghostty/`, `zellij/`, `nvim/`, `zsh/` if it grounds a claim.
3. **Fill every section** of `@.claude/sdd/feature-template.md`. Crystallise what the config must do
   — do **not** restate the upstream doc; cite it by section/URL (`ghostty.org §keybind`).
4. **Write acceptance criteria in EARS** — *WHEN \<event\> THE SYSTEM SHALL \<behavior\>*. Each AC
   observable from outside the config; checkable by a fresh-context agent, a validator, or a visible
   keypress. No Gherkin.
5. **Mark unresolved decisions `[TBD]`** with a one-line note on what blocks each — never invent an
   answer (or a config key) to close a gap.
6. **Create the Feature row** in the Features DB (data-source id from
   `@.claude/sdd/data-sources.md`) with **every field set** per `@.claude/sdd/property-contract.md`,
   and `Status = Drafted`. Put the template body (§1–§15) in the page.
7. **End with one line:** `Spec drafted at F-<AREA>-<NNN>. Open TBDs: <count>. Next: /sdd:clarify F-<AREA>-<NNN>.`

## Do not

- Do **not** plan or implement. If you catch yourself choosing exact keybinds, layouts, or plugin
  versions, **stop** — that's Phase 3 (`/sdd:plan`). (Writing config is impossible for you by tool
  policy anyway.)
- Do **not** invent a config key. If you can't cite it upstream, mark it `[TBD]`.
- Do **not** fetch the template / contract / data-source IDs from Notion — they're embedded above.
