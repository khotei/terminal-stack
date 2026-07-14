# 🔍 Reviewing changes — reading what the agent wrote

The stack is built to *generate* code fast (Claude Code in a pane). This guide is the other half:
**reading it back**, so a long agent session doesn't ship code you can't vouch for. The main scenario
is the awkward one — you and Claude iterate for an hour, the working tree keeps mutating, and you need
to review **uncommitted** changes without losing the thread. It also covers the committed / PR case.

Everything here runs on the tools you already have — **diffview.nvim**, **gitsigns**, **lazygit**,
**git-delta** (already your git pager), **gh**, and **Claude Code** itself. No new tool to install;
one small config tweak ([§10](#10-enable-it-on-the-stack)) makes it click.

### Contents

1. [The mental model](#1-the-mental-model) — reviewing AI code is *harder* self-review, not lighter
2. [Three ranges — pick what you're reviewing](#2-three-ranges--pick-what-youre-reviewing)
3. [Scenario A — reviewing while Claude iterates (uncommitted)](#3-scenario-a--reviewing-while-claude-iterates)
4. [What to hunt for in AI code](#4-what-to-hunt-for-in-ai-code) — the failure modes
5. [Reviewing *with* AI — a fresh-context second pair of eyes](#5-reviewing-with-ai)
6. [Working alongside a live Claude session](#6-working-alongside-a-live-claude-session)
7. [Prove it, don't just read it](#7-prove-it-dont-just-read-it)
8. [Scenario B — committed work, branches & PRs](#8-scenario-b--committed-work-branches--prs)
9. [Cheatsheet](#9-cheatsheet)
10. [Enable it on the stack](#10-enable-it-on-the-stack) — the one config tweak

---

## 1. The mental model

**Reviewing AI code is self-review turned up, not turned down.** The trap is subtle:

> "AI does not write *bad* code — it writes *plausible* code." — [René Bulsing](https://rbulsing.medium.com/the-rubber-stamp-problem-how-ai-outpaces-the-oversight-it-promises-ff8372752673)

Plausible code defeats a skim: the surface looks right, so your eye slides over it. The honest tell —
[Bryan Finster](https://bryanfinster.substack.com/p/ai-broke-your-code-review-heres-how): **if
reviewing an agent's diff takes you as long as a human's, you're rubber-stamping.** Agent code should
take *longer* per line, because its failure modes are subtler ([§4](#4-what-to-hunt-for-in-ai-code)).
The baseline rule ([mcsee](https://dev.to/mcsee/ai-coding-tip-006-review-every-line-before-commit-bmm)):
**never commit a line you can't explain.**

Two things you're actually doing when you "read the diff", and the stack splits them cleanly:

| Task | The question | The tool |
|---|---|---|
| **See the delta** | *What changed?* | diffview / gitsigns / `git diff` |
| **Understand the code** | *What does this now do?* | LSP (`gd`/`gr`/`K`), grep, run it |

The old caveat "LSP doesn't work in a diff buffer" is **solved** by diffview's `--imply-local`
([§10](#10-enable-it-on-the-stack)): it puts the *real working-tree file* on the right side, so
`gd`/`gr`/diagnostics work **inside the review** — both tasks in one view.
([diffview USAGE.md](https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md))

**Three tiers of safety net — don't confuse them:**

1. **Claude checkpoints / `/rewind`** — *session* undo (restores code + conversation to before a
   prompt). Great for "that turn went wrong, back up." Blind spots: it does **not** track files a
   `bash` step changed (`rm`/`mv`) or edits from another session. ([Checkpointing](https://code.claude.com/docs/en/checkpointing))
2. **A git commit** — the *real* safety net. Commit a green baseline **before** a big session, so any
   mess is one `git reset` away and every failure is attributable.
3. **`/check`** — the *proof*. In a config repo, "does it load" is the test ([§7](#7-prove-it-dont-just-read-it)).

---

## 2. Three ranges — pick what you're reviewing

Every review is a *diff over a range*. Naming the range is half the battle:

| You want to review… | git range | On the stack |
|---|---|---|
| What Claude just changed (not yet staged) | working tree vs `HEAD` | `<leader>gv` · `git diff` |
| Exactly what a commit will contain | staged vs `HEAD` | `git diff --staged` · `git add -p` |
| The whole session / your branch vs main | `origin/main...HEAD` (merge-base) | `<leader>gm` · `gh pr diff` |

The **three-dot** `main...HEAD` compares against the *merge-base* — the same delta a reviewer sees on
GitHub, unpolluted by commits that landed on main meanwhile. That's the one you want for "review my
whole branch." ([diffview USAGE.md](https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md))

---

## 3. Scenario A — reviewing while Claude iterates

The hard case: a long session, the tree mutating each turn. Two disciplines keep it tractable.

**Gate per turn, not once at the end.** The [3-checkpoint framework](https://codeongrass.com/blog/where-to-gate-your-ai-coding-agent-3-checkpoint-framework/)
— redirect early, it's cheap; reverse after execution, it's expensive:

1. **Plan gate** — approve the *approach* before a file is touched (plan mode `Shift+Tab`). Correcting
   here costs seconds.
2. **Findings gate** — sanity-check what the agent *discovered* before it acts on it.
3. **Diff gate** — the final veto before it's staged/committed.

**Keep each reviewable chunk small.** The [SmartBear/Cisco study](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/):
defect-finding **collapses past ~400 LOC**. A 50-line diff is a two-minute read; a 600-line one never
gets a real review even if correct ([codeongrass](https://codeongrass.com/blog/how-to-review-ai-generated-code-faster-than-you-can-read/)).
So have Claude commit after each logical sub-task, and review the pieces as they land.

### The reading loop, on the stack

**① Triage first — 30-second scope scan.** Before reading a line, see *where* it touched:

```sh
git diff --stat        # how big, which files
git diff --name-only    # did it touch something it shouldn't have?
```

Scope creep is the #1 agent tell — files edited or deleted outside the task
([codeongrass](https://codeongrass.com/blog/where-to-gate-your-ai-coding-agent-3-checkpoint-framework/)).

**② Read the delta.** For a sweep, `<leader>gv` (diffview working tree): `<Tab>`/`<S-Tab>` between
files, `]c`/`[c` between hunks. With `--imply-local` on, stop on any line and `gd`/`gr`/`K` work right
there — no context switch to "understand" mode. For a stray hunk without leaving the file, gitsigns:
`]h`/`[h` to jump, `<leader>ghp` to preview inline, `<leader>gb` to blame.

**③ Stage as the gate — `git add -p`.** This is the forcing function every practitioner names: patch
mode walks you **hunk by hunk** (`y`/`n`, `s` to split, `e` to edit), so when you're done you have
*provably* looked at every change, and unrelated edits stay out of the commit.
([git-scm](https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging) ·
[nuclearsquid](https://nuclearsquid.com/writings/git-add/)) In **lazygit** (`<leader>gg` / `lg`) this is
visual: `Enter` on a file opens the hunk view, `Space` stages a hunk, `v` then `Space` stages just
selected lines. Delta renders it all readable (already your pager).

> **The point of staging-as-review:** `git add -A` is a rubber stamp; `git add -p` is a decision per
> hunk. In a mutating tree it's also how you carve one messy session into focused, separately-reviewable
> commits — never mixing a refactor with a behavior change ([Swett](https://www.codewithjason.com/dont-mix-refactorings-behavior-changes/)).

**④ Wrong turn? Rewind.** `Esc Esc` (empty prompt) or `/rewind` restores to before a prompt — undo a
bad turn without nuking your start point. But commit the good stuff first: checkpoints don't see
`bash`-driven file changes.

---

## 4. What to hunt for in AI code

Standard review isn't calibrated for AI output because *humans rarely produce plausible-but-wrong code*.
Review **against** the plausibility. The recurring patterns
([Hannecke](https://medium.com/@michael.hannecke/three-patterns-where-agent-generated-code-quietly-fails-1b9735493468),
[Osmani](https://addyosmani.com/blog/code-review-ai/)):

| Failure mode | The tell | How to catch it on the stack |
|---|---|---|
| **Hallucinated API** | a plausible method/flag that doesn't exist (worse on niche/new libs) | verify the name upstream — `context7` MCP, or `/btw does X exist?` |
| **Swallowed errors** | `try?` / `pcall` / `\|\| true` / bare `catch {}` that hides a failure | `rg 'pcall\|2>/dev/null\|\\|\\| true\|catch'` over the diff — question each |
| **Escape hatches for silence** | `@ts-ignore`, `any`, `--no-verify`, `unsafe` used to mute a warning, not fix it | `rg` for them; ask "necessary, or suppression?" |
| **Scope creep** | files touched/deleted outside the task; oversized diff | the `--stat` / `--name-only` triage in [§3](#3-scenario-a--reviewing-while-claude-iterates) |
| **Plausible-but-wrong** | reads right, fails quietly; logic that *looks* correct | slow down; run it ([§7](#7-prove-it-dont-just-read-it)); don't trust the surface |
| **Invented config key** *(this repo)* | a keybind/option with no upstream citation | the never-invent rule — [`config.md`](../.claude/rules/config.md); is it cited? |

Concentrate scrutiny where agents err most — **imports, error handling, auth/security, and duplicated
implementations** ([Osmani](https://addyosmani.com/blog/code-review-ai/): AI code shows markedly more
logic and security defects than human code).

---

## 5. Reviewing *with* AI

A **fresh-context reviewer catches what the building agent, married to its own plan, cannot**
([Simon Willison](https://simonwillison.net/tags/sub-agents/)). Claude Code gives you three, in the
same pane:

- **`/code-review`** — reviews the working diff for correctness + simplifications; you read only the
  flagged spots, not the whole diff.
- **`/review <PR>`** — reviews a GitHub PR end to end.
- **`/security-review`** — a security-focused pass (complements, never replaces, your read).

Treat their output as **advisory** — a filter that tells you *where* to look harder, not a verdict.
Best paired with your own `git add -p`: the agent flags, you decide. For high-stakes changes,
cross-check with a second model — generate with one, audit with another.

---

## 6. Working alongside a live Claude session

Because Claude runs in a Zellij pane, review *next to* it — no window-switching:

- **Layout: `editor │ agent`** (`zellij --layout dev`). Claude works on the right; you review in the
  left nvim pane (diffview / lazygit). `Alt+h`/`Alt+l` hop between them; `Alt+d` locks a pane so its
  own `Ctrl`-keys reach the app ([zellij README §8](../zellij/README.md#8-living-with-claude-code--neovim--manual-lock)).
- **Green baseline first.** Before handing the tree over, `/check` clean + working tree clean — so any
  later failure is *attributable* to the session, not pre-existing.
- **One worktree per session** for parallel features — it isolates a mutating tree from your review
  copy, and is a natural checkpoint between "agent wrote it" and "I merge it". See
  [parallel-agents.md](parallel-agents.md).

---

## 7. Prove it, don't just read it

Reading catches *some* bugs; plausible-but-wrong code needs **running**. A perfect change ships with
its proof ([Simon Willison, "The Perfect Commit"](https://simonwillison.net/2022/Oct/29/the-perfect-commit/)).
For this config repo the proof is **[`/check`](../.claude/commands/check.md)** — `ghostty +show-config`,
`zellij setup --check`, `nvim --headless`, `zsh -n`: does the config actually **load**. Run it before a
change is "done" — a diff that reads clean but fails `/check` is not reviewed, it's *unread*. Confirm
the new behavior with the actual keypress/command too (the [testing rule](../.claude/rules/testing.md)).

---

## 8. Scenario B — committed work, branches & PRs

**Your own branch, before the PR** — the whole session's delta with LSP live:

```vim
:DiffviewOpen origin/main...HEAD    " <leader>gm — --imply-local is on by default
```

`<Tab>` through files, `]c` through hunks, `gd`/`gr` to understand, `-` to stage from the panel.

**Reviewing a PR (yours or incoming)** — the LSP-first path is a *local checkout*, not a raw diff:

```sh
gh pr checkout 46                    # PR branch becomes local — real files, full LSP
# …then in nvim:  :DiffviewOpen origin/main...HEAD
gh pr checkout main                  # back when done
```

Because the files are real, your whole editor works — `<leader>fg` grep, `gd`, run it
([why local checkout enables LSP review](https://github.com/ldelossa/gh.nvim)). For a **fast triage
without checking out**, read it in the terminal through delta:

```sh
gh pr diff 46 | delta                # readable, syntax-highlit
gh pr diff 46 --name-only            # just the file list — scope scan
```

**The rest of the round, still in the terminal** — see state, CI, and leave the verdict without a
browser trip:

| Command | What |
|---|---|
| `gh pr view <N>` | body, checks, comments (`--web` bounces to the browser) |
| `gh pr checks <N> --watch` | is CI green? follow it live |
| `gh pr status` | *your* PRs — created by you, review-requested |
| `gh pr review <N> --approve` | the verdict (`--request-changes -b "…"` / `--comment -b "…"`) |

Full `gh` card: [zsh/README §5.15](../zsh/README.md#515-gh--github-from-the-terminal).

**A big multi-commit PR — review commit by commit** rather than one giant diff:

```vim
:DiffviewFileHistory --range=origin/main...HEAD --right-only --no-merges
```

`--right-only` keeps just the branch's commits; `--no-merges` drops merges.
([diffview USAGE.md](https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md))

---

## 9. Cheatsheet

| Keys / command | Action | Where |
|---|---|---|
| `git diff --stat` / `--name-only` | 30-second scope triage (do this first) | shell |
| `<leader>gv` | Review working-tree changes (what Claude just did) | Neovim · diffview |
| `<leader>gm` | Review branch vs main (`origin/main...HEAD`) | Neovim · diffview |
| `<Tab>` / `<S-Tab>` · `]c` / `[c` | next/prev file · next/prev hunk | diffview |
| `gd` / `gr` / `K` | definition / references / hover — *in the diff* (`--imply-local`) | Neovim LSP |
| `]h` / `[h` · `<leader>ghp` · `<leader>gb` | jump hunks · preview inline · blame | gitsigns |
| `git add -p` | stage hunk-by-hunk = read every change | shell |
| `<leader>gg` / `lg` → `Enter` `Space` | stage hunks/lines visually | lazygit |
| `/code-review` · `/review <PR>` · `/security-review` | AI review passes | Claude Code |
| `Esc Esc` / `/rewind` | undo a bad turn (session-level) | Claude Code |
| `gh pr checkout <N>` → diffview | review a PR locally with full LSP | shell + nvim |
| `gh pr diff <N> \| delta` | fast PR triage, readable | shell |
| `gh pr view/checks/status` · `gh pr review --approve` | PR state · CI · leave the verdict | shell · gh |
| `/check` | prove the config loads (the "tests") | Claude Code |

---

## 10. Enable it on the stack

You already have the tools — **delta** is your git pager, **lazygit** is configured, **diffview** and
**gh** are wired. Only two tweaks unlock the LSP-in-diff flow, both in
[`nvim/lua/plugins/diffview.lua`](../nvim/lua/plugins/diffview.lua):

| Change | Why |
|---|---|
| `opts.default_args.DiffviewOpen = { "--imply-local" }` | Puts the working-tree file on the diff's right side, so LSP (`gd`/`gr`/diagnostics) works **inside** the review · [USAGE.md](https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md) |
| `<leader>gm` → `:DiffviewOpen origin/main...HEAD` | One key for "review my whole branch vs main" — the range `<leader>gv` (working tree) doesn't cover |

*Optional polish (already-installed tools):* delta `navigate = true` (n/N between files in any
`git show`) and `side-by-side = true` for a two-column view; a `lazygit-edit://` hyperlink pager in
lazygit so delta's line numbers click-to-open. See [git-delta](https://github.com/dandavison/delta) and
[lazygit Custom_Pagers](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md).

---

## References

- Addy Osmani — [Code review in the age of AI](https://addyosmani.com/blog/code-review-ai/) ·
  codeongrass — [3-checkpoint framework](https://codeongrass.com/blog/where-to-gate-your-ai-coding-agent-3-checkpoint-framework/) ·
  Bryan Finster — [AI broke your code review](https://bryanfinster.substack.com/p/ai-broke-your-code-review-heres-how)
- Simon Willison — [The Perfect Commit](https://simonwillison.net/2022/Oct/29/the-perfect-commit/) ·
  [sub-agents](https://simonwillison.net/tags/sub-agents/) · SmartBear — [Peer review best practices](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)
- [git add -p](https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging) ·
  [diffview USAGE.md](https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md) ·
  [Claude Code Checkpointing](https://code.claude.com/docs/en/checkpointing) ·
  [gh pr checkout](https://cli.github.com/manual/gh_pr_checkout)

> Part of [terminal-stack](../README.md) · pairs with [composing-tools.md](composing-tools.md) and
> [parallel-agents.md](parallel-agents.md).
