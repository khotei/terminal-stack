# Pull requests

**Always-loaded rule.** This project's PRs have a **signature requirement**: every PR is written as
a **self-contained reference guide**. A reader who has never seen this repo should finish the PR
description understanding *what the change is for*, *what each config key does and why*, *how to try
it themselves*, and *how it maps back to its Feature and ACs* — without opening another file.

PRs here are **squash-merged**, and GitHub is set to *"Pull request title and description"*, so each
PR collapses to **one commit on `main`** whose **subject = PR title** and **body = PR description**.
The PR description therefore *is* the permanent git history a future developer or Claude Code
session reads via `git log -p`, and the standing cheatsheet a user reaches for. That double duty is
*why* the reference-guide format exists: a config repo's history is most useful when each entry
teaches the config it added.

**GitHub keeps HTML comments in that body** — the squash commits of the merged PRs carry the
author self-check (`git log --grep='Author self-check'`). So merge with the comments cut out:

```sh
gh pr view <n> --json body -q .body | perl -0pe 's/<!--.*?-->\n?//gs' > "$TMPDIR/pr-body.md"
gh pr merge <n> --squash --body-file "$TMPDIR/pr-body.md"
```

**Format source of truth for the title + the gitmoji/type vocabulary is `.claude/rules/commits.md`.**
This file adapts it to the PR surface; it does **not** restate the gitmoji table or type list.

## The rule

- **PR title = a `commits.md` subject line:** `<gitmoji> <type>(<scope>): <subject>` — imperative,
  Capitalised, ≤50 chars, no trailing period. (The squash *subject* comes from the title, never the
  first body line, so only the title can set it.)
- **PR body = `.github/PULL_REQUEST_TEMPLATE.md`**, every section filled: Summary · Feature & ACs
  covered · What changed (one row per key, keybind, plugin spec or alias, each citing its upstream
  doc) · How to use / try it (file location, reload step, the keypress) · Keybindings / cheatsheet
  (when binds move) · Verification (`/check` output) · References. Every section survives the
  squash, so the committed history carries the full guide.
- **Reviewer-only content lives in `<!-- … -->` blocks:** the template's hints, the author
  self-check, screenshots. The merge command above leaves them out. HTML comments do **not** nest —
  never put `<!-- -->` inside another, and never write a literal `-->` inside one: it closes the
  block early and leaks review notes into history.
- **Set the Feature's `PR` field** to this PR's URL (one click from spec to diff), and put the
  Feature page URL in the `Refs:` so the reviewer reaches the spec in one click.
- Opening a PR, pushing and merging are outward-facing (the repo is public): ask the user first.

## Repo setting that makes this work

*Settings → General → Pull Requests* → **Allow squash merging** with **Default commit message =
"Pull request title and description"** (API: `squash_merge_commit_title=PR_TITLE`,
`squash_merge_commit_message=PR_BODY`). Without it, squash falls back to concatenating branch
commits and the template has no effect.
