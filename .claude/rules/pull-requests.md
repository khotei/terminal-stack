# Pull requests

**Always-loaded rule.** This project's PRs have a **signature requirement**: every PR is written as
a **self-contained reference guide**. A reader who has never seen this repo should finish the PR
description understanding *what the change is for*, *what each config key does and why*, *how to try
it themselves*, and *how it maps back to its Feature and ACs* — without opening another file.

PRs here are **squash-merged**, and GitHub is set to *"Pull request title and description"*, so each
PR collapses to **one commit on `main`** whose **subject = PR title** and **body = PR description** —
verbatim, except that **HTML comments (`<!-- … -->`) are stripped**. The PR description therefore
*is* the permanent git history a future developer or Claude Code session reads via `git log -p`, and
the standing cheatsheet a user reaches for. That double duty is *why* the reference-guide format
exists: a config repo's history is most useful when each entry teaches the config it added.

**Format source of truth for the title + the gitmoji/type vocabulary is `.claude/rules/commits.md`.**
This file adapts it to the PR surface and adds the reference-guide body sections — it does **not**
restate the gitmoji table or type list.

## The rule

- **PR title = a `commits.md` subject line:** `<gitmoji> <type>(<scope>): <subject>` — imperative,
  Capitalised, ≤50 chars, no trailing period. (The squash *subject* comes from the title, never the
  first body line, so only the title can set it.)
- **PR body = the reference-guide template below** — every section survives the squash, so the
  committed history carries the full guide.
- **Reviewer-only chrome lives in one `<!-- … -->` block:** the author self-check and any
  before/after screenshot. Stripped at merge, so it never pollutes history. HTML comments do **not**
  nest — never put `<!-- -->` inside another, and avoid a literal `-->` inside a comment.
- **Set the Feature's `PR` field** to this PR's URL (one click from spec to diff), and put the
  Feature page URL in the `Refs:` so the reviewer reaches the spec in one click.

## PR body template (the reference guide)

```markdown
## Summary
One paragraph (WHAT + WHY, ~72-char wrap). The end state in plain language: what can you now do in
the terminal that you couldn't before, and why it was worth a config change.

## Feature & ACs covered
- **Feature:** <Notion Feature page URL> (`F-AREA-NNN`)
- **ACs:** AC-1, AC-3 — one line each on how this PR satisfies them.

## What changed (annotated — per-setting rationale)
For **each** config key / keybind / plugin spec / alias added or changed, one row:

| File | Setting | Value | Why (cite upstream doc) |
|---|---|---|---|
| `ghostty/config` | `keybind` | `ctrl+a>n=new_tab` | New-tab on the shared prefix · ghostty.org/docs/config/keybindings |
| `zellij/config.kdl` | `default_layout` | `compact` | … · zellij.dev/documentation/layouts |

Never invent a config key — every row cites where the key is documented upstream.

## How to use / try it
Exact steps a reader follows to get the behavior on their own machine: where the file lives
(`~/.config/ghostty/config`, …), the reload step (Ghostty reload / `:Lazy sync` / `source ~/.zshrc`),
and the keypress or command that demonstrates it.

## Keybindings / cheatsheet
*(Include where the change adds or moves bindings.)*

| Keys | Action | Tool |
|---|---|---|
| `ctrl+a n` | New tab | Zellij |
| `<leader>ff` | Find files | Neovim |

## Verification
The validators that prove the config loads (`/check`), with their output:
- `ghostty +show-config` → no errors, lists the new keybind ✅
- `zellij setup --check` → ✅
- `nvim --headless "+checkhealth" +qa` → ✅

## References
- Upstream docs cited above.
- Related Feature / Research pages.

<!--
Author self-check (stripped at merge):
- [ ] Every new config key cited upstream — none invented
- [ ] `/check` green for every touched tool
- [ ] No keybinding collision with the multiplexer prefix / editor leader
- [ ] Cheatsheet / README updated
- [ ] Feature `PR` field set to this URL
Screenshots / asciinema (optional):
-->

Refs: <Notion Feature page URL> · Closes #<issue>
```

## Repo setting that makes this work

*Settings → General → Pull Requests* → **Allow squash merging** with **Default commit message =
"Pull request title and description"** (API: `squash_merge_commit_title=PR_TITLE`,
`squash_merge_commit_message=PR_BODY`). Without it, squash falls back to concatenating branch
commits and the template has no effect.

`.github/PULL_REQUEST_TEMPLATE.md` should encode exactly this shape so the description box
auto-fills and a squash-merge yields a compliant, reference-guide commit with zero hand-editing.
