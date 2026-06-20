<!-- Generated from the Terminal Stack SDD hub §6.1 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

# Feature page template (§6.1)

The body `/sdd:specify` fills when it creates a Features-DB row. §§5–11 are *implementation
surfaces* — include one section per concrete artifact the feature produces (config file touched,
keybindings, plugin spec, install step, cheatsheet). Add, remove, or rename §§6–11 to fit the
feature; keep the §1–§5 + §12–§15 spine intact. These are **config** features — there are no user
personas and no user stories; trace the §12 ACs straight to the observable end state.

```markdown
> **Feature ID:** F-XXX-NNN · **Area:** <Area> · **Target release:** <Release> · **Priority:** P0 | P1 | P2 | P3
> **Reflects:** <mention source hub section / upstream doc> §<section> *<section title>*, §<section> *<section title>*.
> This page is a **feature-level reflection** of the source hub/spec — it does **not** restate it, it crystallises what the config must do and how it splits into tasks.
---
## 1. Goal
One paragraph, plain language. The end state in operational terms: what can the user (or Claude Code) *do* in the terminal on completion that they couldn't before. Phrase as "Wire / configure / deliver X so that Y is possible — with Z preventing regression."

## 2. Why this exists
One paragraph. The ergonomic / workflow / consistency rationale. Why this config has to land now, before what, instead of what. What compounds across later features if this is done wrong.

## 3. Outcomes (definition of done)
- High-level outcomes — *what's true when this is done*, not per-task checks.
- Each bullet observable from outside the config (a visible behavior, a keypress that works, a validator that passes).
- Aim for 5–8 outcomes; if you have 15, the feature is two features.

## 4. Scope
### In scope
- ...
### Out of scope
- ...

## 5. Stack reflection
Which tool owns this (Ghostty / Zellij / Neovim / zsh+Starship / Claude Code) and how it interacts with the others (e.g. Zellij keybinds must not collide with Ghostty's; nvim's leader must not clash with the multiplexer prefix). Call out the single most important invariant the config must protect (no keybinding collision, config still validates, etc.).

## 6. <Implementation surface — e.g. "Config keys (what to set)" | "Keybindings" | "Plugin spec">
Concrete listing of what this section produces — the exact config keys / KDL nodes / Lua spec / shell lines. Be exhaustive within the section's scope. Cite the upstream doc for any non-trivial choice (never invent a config key).

## 7. <Implementation surface — e.g. "Layouts" | "Theme / appearance" | "Aliases & functions">
...

## 8. <Implementation surface — e.g. "Install / dependencies (Homebrew)" | "Integration with other tools">
...

## 9. <Implementation surface — e.g. "Validation hook" | "Cheatsheet">
...

## 10. <Implementation surface — e.g. ".claude/ files" | "README / docs">
...

## 11. <Implementation surface — e.g. "Migration / dotfile symlinks">
...
> Add or remove §§6–11 to fit the feature. Each section describes one tangible thing the config must produce.

## 12. Acceptance criteria
- [ ] AC-1 — <observable from outside the config; verifiable by a fresh-context agent, a single validator command, or a visible keypress result>.
- [ ] AC-2 — ...
- [ ] AC-N — ...

## 13. Proposed task breakdown (seeds for the Tasks DB)
Each bullet becomes one Claude Code task. Vertical slices where possible so they can run in parallel.
1. **<Imperative task title>.** One-line description of what it produces.
2. **<Imperative task title>.** ...

Ordering: <which tasks are strictly sequential, which can fan out, which run last (verification)>.

## 14. Open questions / risks
- **<Question or risk title>.** One-line description + mitigation or the next step to resolve it.
- ...

## 15. References
- **Source hub/spec:** <mention-page>, §<sections cited>.
- **Upstream docs:** <links to ghostty.org / zellij.dev / lazyvim.org / neovim.io / starship.rs / docs.claude.com>.
- **Related features:** <mention-pages>.

## Change log
| Version | Date | Author | Change |
|---|---|---|---|
| 0.1 | YYYY-MM-DD | <author> | Initial draft |
```

## Acceptance-criteria notation (Terminal Stack)

Write the §12 ACs in **EARS** form — *WHEN \<event\> THE SYSTEM SHALL \<behavior\>* (also WHILE /
WHERE / IF–THEN). EARS only — do **not** mix in Gherkin's *Given/When/Then* (a different system).
Each AC must be observable from outside the config and checkable by a fresh-context agent or a
single command (e.g. *WHEN `ghostty +show-config` runs THE SYSTEM SHALL report no errors and list
`keybind=ctrl+a>n`*). See `@.claude/rules/sdd.md`.
