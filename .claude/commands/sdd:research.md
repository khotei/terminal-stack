---
description: "Research: deep, source-grounded findings written to a cited Research page in the Specs DB"
argument-hint: "<topic>"
context: fork
agent: researcher
---

<!-- Generated from the Terminal Stack SDD hub §1.5 (grounding) + §4 — https://app.notion.com/p/385fb28bd5f1810d91ddd69ea4c49243. Re-sync on change. -->

You are running the **Research** phase of the Terminal Stack SDD hub on the topic `$ARGUMENTS`.
(This stands in for the playbook's phase-0 `/sdd:constitution` — the constitution already exists as
the repo-root `CLAUDE.md`, so the optional pre-Specify step here is evidence-gathering.)

**Embedded — do NOT fetch from Notion:** the data-source IDs `@.claude/sdd/data-sources.md` (the
Specs collection id lives there); the target is `Doc type = Research`.
**Fetch live:** the web sources (Ghostty, Zellij, LazyVim/Neovim, Starship, Claude Code docs), plus
any existing config in `ghostty/`, `zellij/`, `nvim/`, `zsh/` that bears on the topic.

## Steps

1. **Scope** the topic `$ARGUMENTS` into the specific questions the research must answer.
2. **Gather evidence** from multiple sources — `WebSearch`/`WebFetch` for the upstream docs, the
   Notion MCP + `Read`/`Grep` for internal config/specs. Prefer primary/authoritative sources (the
   tool's own docs over blog posts); triangulate.
3. **Ground every claim.** Each factual statement gets an inline citation to a real, retrievable
   source. A config key with no upstream doc **does not ship** — drop it or list it as an open
   question (invention is forbidden — hub §1.5).
4. **Synthesise** into a Research-findings page: **summary**, **findings** (each cited), **open
   questions / gaps**, **sources**.
5. **Create the page** in the Specs DB (data-source id from `@.claude/sdd/data-sources.md`) with
   `Doc type = Research`, `Status = Draft`, `Source = <primary URL>`. Link a related feature if any
   applies.
6. **End with one line:** `Research page created: <title>. Findings: <n> (all cited). Use it as a source for /sdd:specify.`

## Do not

- Do **not** state a claim you can't cite — that's the AI-slop failure mode this phase exists to
  prevent. A config key with no upstream doc is a guess, not a finding.
- Do **not** write config (denied by tool policy anyway).
- Do **not** fetch the data-source IDs from Notion — they're embedded above.
