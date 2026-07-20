# 🤝 Working with agents — a repeatable skill, not a feature tour

> *"Programs must be written for people to read, and only incidentally for machines to execute."*
> — Harold Abelson & Gerald Jay Sussman, *SICP*, preface
>
> That was always the quiet truth of the craft. Agents make it the loud one. The machine now writes;
> the reading is yours — and reading, it turns out, was the whole job. This guide is about doing that
> reading well, at speed, without ceding the one thing you cannot delegate: **vouching for the result.**

*(Русская версия: [working-with-agents.ru.md](working-with-agents.ru.md). English is canonical; the
translation may lag.)*

Claude Code lives in a Zellij pane and writes code fast. That was always the easy half. This guide is
the **skill** that makes it pay: a repeatable loop for *shaping* work, *delegating* it, and *proving*
it correct — so a long agent session ships code you can actually vouch for, and several agents at once
don't outrun the one thing that doesn't scale: **your judgment**.

The whole guide hangs on one shift. **Generation got cheap; your edge moved to comprehension and
verification.** Read §1 for the model, §2 for the loop that operationalizes it, and keep the rest as
the deepening spiral — the same loop, seen through *who does what*, *many agents*, *reading the diff*,
*re-prompting*, and *why it works cognitively*. Everything runs on tools you already have — **diffview**,
**gitsigns**, **lazygit**, **git-delta**, **gh**, **git worktrees**, and Claude Code itself. Nothing new
to install.

### Contents

1. [The one idea](#1-the-one-idea) — comprehension & verification are the scarce resource, not tokens
2. [The loop: Frame → Delegate → Verify → Comprehend](#2-the-loop) — the named skill
3. [Who does what](#3-who-does-what) — split by *phase*, not by typing volume
4. [Run many without collisions](#4-run-many-without-collisions) — worktrees, and how to orient among them
5. [Read what it wrote](#5-read-what-it-wrote) — the reading loop on the stack
6. [Understand → Analyze → Re-prompt](#6-understand--analyze--re-prompt) — the return trip
7. [The cognitive edge](#7-the-cognitive-edge) — why the loop works, and how to train
8. [The frontier](#8-the-frontier) — what you're most likely missing in 2026
9. [Anti-patterns](#9-anti-patterns) — don't → do
10. [Cheatsheet](#10-cheatsheet) — the reference layer
11. [Definition of Done](#11-definition-of-done) — the portable checklist + a retrieval drill

---

## 1. The one idea

> **Generation got cheap; your edge is now *comprehension* and *verification*. The scarce resource is
> not the agent's tokens — it's *your* working memory. The whole craft is spending it on *judgment*,
> not *bookkeeping*. You own the *shape*; the agent fills it in.**

Hold that sentence; the rest of the guide is its unfolding.

**Why working memory is the bottleneck.** You reason over roughly **four chunks** at once — not the
folk "7±2", which conflated two different limits ([Cowan 2001](https://philpapers.org/rec/COWTMN),
peer-reviewed). A *chunk* is one meaningful unit your long-term memory has already learned to see as a
whole. Expertise *is* that store of chunks: shown a real position, chess masters recall it far better
than novices; shown a *random* one, they don't ([Chase & Simon 1973](https://en.wikipedia.org/wiki/Chunking_(psychology)),
peer-reviewed). The same holds for code — experts recall *meaningful* code far better than novices but
do no better on *scrambled* code ([McKeithen et al. 1981](https://www.sciencedirect.com/science/article/abs/pii/0010028581900128),
peer-reviewed, replicated). The agent can generate a thousand lines; you still have four chunks to
understand them with. That asymmetry is the entire game.

**Why the edge is verification, not generation.** Reading already dominated the work before agents —
about **58% of developer time is program comprehension** ([Xia et al., IEEE TSE 2018](https://baolingfeng.github.io/papers/tsecomprehension.pdf),
peer-reviewed). Agents raise the volume of code to comprehend without raising your capacity to
comprehend it. So the durable skill is not prompting cleverly enough to generate more — it's
*specifying what "correct" means and proving the output meets it*.

### The honest anti-hype (your #1 adversary is your own sense of speed)

- **You feel faster than you are.** In a randomized controlled trial, experienced developers working in
  *mature repositories they knew well* were about **19% slower** with early-2025 AI tools — while
  *believing* they were 20% faster ([METR 2025](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)).
  Treat this as a caution, not a law: `[RCT, but small N=16, narrow setting, early-2025 tooling — METR itself frames it as time-bound]`.
  The *perception* gap, though, is corroborated independently (GitHub's RCT, Stanford's 2023 telemetry
  study) — three measurements, same illusion. The lesson isn't "agents are slow"; it's *don't trust the
  feeling of speed — measure by what ships and holds*.
- **The bottleneck is your review, not the agent's throughput.** Five agents is not five times the
  output; it's five diffs queued behind one reviewer. "I can only review and land one significant change
  at a time" ([Willison](https://simonwillison.net/2025/Oct/5/parallel-coding-agents/), practitioner).
  Anthropic, GitHub, and independent practitioners converge on the same ceiling.

> **Mental image — the funnel.** Wide at the top (cheap generation), pinched at the neck (your ~4-chunk
> working memory), and the neck is where every line must pass to become *shipped*. Widening the top
> doesn't widen the neck. The craft is spending the neck on judgment.

**Retrieval check:** close the page for ten seconds. What is the scarce resource — and what are the two
skills that now carry your edge?

---

## 2. The loop

The skill has a name and four beats:

### **Frame → Delegate → Verify → Comprehend** → (back to Frame, with what you learned)

| Beat | You own | What happens |
|---|---|---|
| **Frame** | the *shape* | a small spec/plan naming interfaces, boundaries, seams, and **what NOT to do**; the tests/types as a **contract, committed first**; optionally one thin hand-written exemplar to mirror |
| **Delegate** | the *task* | the agent generates one small slice, with a runnable check attached |
| **Verify** | the *proof* | the check *ran* (evidence, not a claim), and you read the diff — **under ~400 LOC** |
| **Comprehend** | the *understanding* | you can explain every line; a fresh-context critic looks again; findings become the next **Frame** |

Two design decisions inside the loop earn their own emphasis:

- **The contract goes first.** Commit the tests/types *before* the agent implements. They are the seam
  the generation is poured into — and a guard against a subtle failure mode: an agent "will sometimes
  change the tests to make them pass" ([Kent Beck](https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes),
  expert). Own the contract; let the agent own only the fill.
- **Slice small.** Keep each delegated chunk small enough that its diff reviews in one sitting (§5
  explains the ~400-LOC cliff). Small slices turn *refactoring* from a giant post-hoc phase into
  something continuous and cheap.

> **Glossary.** *Seam* — a place designed for change: an interface, an extension point, a boundary you
> can substitute behind. *Contract* — the tests and types that define "correct" independently of the
> implementation.

### The worked walkthrough (the reasoning shown)

Here is the pain this loop cures, dramatized — then the fix, thinking aloud.

**The trap.** You prompt "build the email-validation feature." The agent returns 400 plausible lines in
one shot. It runs. You skim, it looks right, you commit. Then, for the next *week*, you refactor it:
the abstraction is wrong, the error handling swallows failures, a second feature can't extend it. You
generated in a minute and paid for it in days. This is [Osmani's **70% problem**](https://addyo.substack.com/p/the-70-problem-hard-truths-about)
(expert): AI nails the first 70% fast; the last 30% — edge cases, architecture, extensibility — is
exactly the engineering that doesn't compress.

**The fix is the loop, and the move is to pull the architecture *left* — into Frame.**

1. **Frame.** *Think:* "What's the shape? A `validate(email): Result` seam, a typed error set, and a
   rule: don't touch the existing `User` type." You write that as a short spec, and you commit **three
   failing tests** — valid address, malformed address, empty input — as the contract. Ten minutes.
2. **Delegate.** *Think:* "One slice: make these three tests pass, nothing more." The agent implements
   against the committed contract. It cannot quietly redefine "correct" — the tests already did.
3. **Verify.** *Think:* "Did the check *run*?" You look at the test output, not the agent's assurance.
   Green. Now the diff — 40 lines, one sitting. `git add -p`, a decision per hunk (§5).
4. **Comprehend.** *Think:* "Can I explain every line? Is the seam right for the *next* feature?" A
   fresh-context critic (`/code-review`) looks with eyes unmarried to the plan. Its findings — "the
   error type should be an enum, not a string" — become the **next Frame**. Small refactor, under green
   tests.

The refactoring never vanished — it *moved*. Instead of a week-long phase bolted on at the end, it
became four small turns, each under a contract, each comprehensible. Architecture done *before*
generation costs minutes; done *after* it costs the week.

> **Retrieval drill.** Close the page. Name the four beats. For each, say the one thing *you* own that
> the agent does not.

---

## 3. Who does what

The wrong split is "hand-written vs. AI-written" — typing volume barely matters. The right split is by
**phase**. Some phases are judgment (yours), some are mechanics (delegable), and the contract sits in
between.

| Phase | Who | What |
|---|---|---|
| 1. **Shape** — interfaces, boundaries, seams, what-NOT-to-do | **You** | in the spec; optionally one thin exemplar by hand |
| 2. **Contract** — tests / types | **You decide**, agent drafts, **you commit first** | the definition of "correct", before implementation |
| 3. **Implementation** | **Agent**, small slices | the bulk of the code |
| 4. **Refactor** | **You = judgment · Agent = mechanics** | under green tests, toward your spec |
| 5. **Verify** | runnable [`/check`](../.claude/commands/check.md) | proof, not eyeballing |

**The one bit of hand-writing that still pays: the seed exemplar.** Hand-write *one* reference
implementation or interface, then have the agent extend the pattern. It is far cheaper to write one
good exemplar than to drag ten generated files toward consistency through refactor. You hand-write
*less* than before — only the seed — but you still hand-write the seed.

### Which tasks to delegate

Grounded in where agents measurably help vs. hurt ([METR](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)):

- **Delegate:** greenfield code, boilerplate, unfamiliar-tech scaffolding, anything *well-specified*,
  mechanical refactors *under tests*.
- **Keep (or short-leash):** your **familiar hot core**, where you're already faster than the
  round-trip; and the architectural decisions themselves.
- **Exploration, where the shape is unknown:** run a fast **throwaway spike** (an agent is fine here) to
  *learn the shape* — then spec from what you learned, then generate cleanly. **Separate learning from
  shipping.** Do not try to make the first generation production-quality; that conflates two jobs and
  wins neither.

Anthropic's own guidance sharpens the same edge: *spec precision pays off more than watching the
implementation*, and — the useful inverse — *if you could describe the diff in one sentence, skip the
plan and just ask* ([Claude Code best practices](https://code.claude.com/docs/en/best-practices), official).

---

## 4. Run many without collisions

Sooner or later you run two agents on one repo — one shipping a feature while another cleans up, or
several SDD hand-offs in flight. Done naively they **fight**: they share one working tree, so they
overwrite each other's edits and stage stale snapshots.

**Every symptom traces to one root: two writers, one tree.**

- **Write race.** Agent A edits `words.api.ts`; while A's change sits unstaged, agent B (a tree-wide
  comment sweep) rewrites the same file. A's on-disk copy — and anything A already staged — is now
  stale, and A doesn't know.
- **Stale index.** `git add` snapshots the file *at that moment*. If another agent rewrites it after,
  the commit ships the **old** snapshot and silently clobbers the other's work.
- **Tree-wide tools hit foreign files.** A formatter, `tsc`, a codemod walk the *whole* tree — one
  agent's `format` reformats files another is mid-edit.

None of this is carelessness; it's physics. Fix the sharing and every symptom disappears.

### Two ways to isolate

| | **Mode A — split by file** | **Mode B — a worktree per agent** |
|---|---|---|
| **Isolation** | same tree; agents touch disjoint files | separate tree + branch each; shared `.git` |
| **Collisions** | prevented **by discipline** — one slip races | prevented **by physics** — different dirs can't race |
| **Setup** | none | one command per agent |
| **Merge-back** | already one branch — just commit | branch per agent → PR → squash-merge |
| **Good for** | one main agent + a light chore | real parallel work — **the default** |

**Mode A** holds only while every agent obeys: disjoint ownership decided up front, never `git add -A`
(stage an explicit path list, then confirm with `git diff --cached --name-only`), no tree-wide tools in
parallel, commit small and often. If keeping these straight feels like work, that's the signal to
switch to Mode B.

**Mode B** — a [git worktree](https://git-scm.com/docs/git-worktree) (official) is a second checkout of
the same repo: its own directory and branch, sharing the one `.git`. Give each agent its own worktree
and file races are *impossible* — they edit different directories. Three ways to get one:

- **The stack way — `cc-worktree <branch>`** ([`cc-worktree.sh`](../claude/cc-worktree.sh)): makes the
  worktree *and* opens a Zellij [`dev` layout](../zellij/layouts/dev.kdl) in it (editor │ agent). Reach
  for it when the parallel task wants the whole workspace. Branches from **`HEAD`** by default (your
  current local work, not a stale remote). Creates a *sibling* dir `../<repo>-<branch>/`, outside the
  repo, so it never shows as untracked in your main checkout.
- **The native way — `claude --worktree <name>`** (or `-w`) ([docs](https://code.claude.com/docs/en/worktrees),
  official): starts a session in a worktree, no editor pane. Lands in `.claude/worktrees/<name>/` on
  branch `worktree-<name>`. On desktop, **`⌘N`** auto-isolates each new session in its own worktree.
- **Subagents — `isolation: worktree`** in a custom subagent's frontmatter: each helper runs in its own
  temporary worktree, auto-cleaned if it leaves no changes. Practical ceiling **~3–5 in parallel** —
  each is a full context window, so N agents ≈ N× the tokens; parallelism buys wall-clock, not free work.

**Prep (one-time).** Set `worktree.baseRef: "head"` so native worktrees branch from your local HEAD, not
the remote default (this stack ships it in [`claude/settings.json`](../claude/settings.json)). In your
*application* repos, add a `.worktreeinclude` listing gitignored files to copy in (a backend's `.env`,
so the app boots) — terminal-stack itself has no secrets to copy. Keep `.gitignore → .claude/worktrees/`
so native worktrees don't show as untracked.

### Orient among them

Isolation makes a new problem: several trees, and you need to see what each agent did *without* pushing.

- **`git worktree list`** — the base overview. Because refs are shared, one agent's commits are visible
  from another tree as a branch, so you can **diff between trees without a push**:
  `git diff main..worktree-feat` ([git-worktree](https://git-scm.com/docs/git-worktree), official).
- **lazygit Worktrees panel** ([Keybindings_en.md](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md),
  official): `n` new · **`<space>` switch** · `o` open · `d` remove. (Some secondary guides say `Enter`;
  the in-UI hint is the arbiter. You can't remove the tree you're standing in.)
- **diffview** — `:DiffviewOpen main...worktree-feat` shows *exactly* one agent's contribution.
  History lives on **`<leader>gV`** (repo) / **`<leader>gF`** (current file) — *not* `gh/gH`, which
  belong to gitsigns' hunk prefix.
- **zellij** panes/tabs for the live sessions: `Alt+h`/`Alt+l` hop between them, `Alt+d` locks a pane so
  its own `Ctrl`-keys reach the app. ⚠️ **Stack gotcha:** Claude Code's *agent-teams* split-panes require
  **tmux or iTerm2 and do not work in Ghostty** ([agent-teams](https://code.claude.com/docs/en/agent-teams),
  official) — so navigate zellij panes by hand, or use in-process agents.

### Merge back

Isolation is half the job; reuniting is the other half — and it's ordinary Git, slotting into the
stack's [squash-merge PR flow](../.claude/rules/pull-requests.md): push each branch, open a **PR per
branch**, squash-merge. Disjoint worktrees merge cleanly in any order. If two branches touched one
file, resolve it *at merge* (rebase the second on the first) — not on disk mid-run, which is the exact
race Mode B avoids. Clean up with `git worktree remove <path>` and periodic `git worktree prune`.

**Anti-hype.** Worktrees for parallel coding are real and shipped. Multi-agent *fleets* for coding are
not — Anthropic explicitly scopes multi-agent work *away* from coding, toward research
([multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system),
official). The ceiling is always your review throughput, not the agent count.

---

## 5. Read what it wrote

**Reviewing AI code is self-review turned *up*, not down.** The trap is subtlety: *AI does not write
bad code — it writes plausible code* ([Bulsing](https://rbulsing.medium.com/the-rubber-stamp-problem-how-ai-outpaces-the-oversight-it-promises-ff8372752673)).
Plausible code defeats a skim: the surface looks right, so your eye slides over it. The honest tell —
*if reviewing an agent's diff takes as long as a human's, you're rubber-stamping*
([Finster](https://bryanfinster.substack.com/p/ai-broke-your-code-review-heres-how)). The baseline
rule: **never commit a line you can't explain.**

You're really doing two things when you "read the diff", and the stack splits them cleanly: *see the
delta* (diffview / gitsigns / `git diff`) and *understand the code* (LSP — `gd`/`gr`/`K` — grep, run
it). The old "LSP doesn't work in a diff buffer" caveat is solved by diffview's `--imply-local` (on by
default here): the real working-tree file sits on the right, so `gd`/`gr`/diagnostics work **inside the
review**.

### The reading loop

**① Triage first (30 seconds).** Before reading a line, see *where* it touched:

```sh
git diff --stat        # how big, which files
git diff --name-only   # did it touch something it shouldn't have?
```

Scope creep — files edited or deleted outside the task — is the **#1 agent tell**.

**② Read the delta with LSP live.** `<leader>gv` (working tree) or `<leader>gm` (branch vs `main`):
`<Tab>`/`<S-Tab>` between files, `]c`/`[c` between hunks; stop on any line and `gd`/`gr`/`K` work right
there. For a stray hunk without leaving the file, gitsigns: `]h`/`[h` to jump, `<leader>ghp` to preview,
`<leader>gb` to blame. `<leader>gs` is the changed-files picker; `<leader>gl` the git log.

**③ Stage as the gate — `git add -p`.** This is the forcing function every practitioner names: patch
mode walks you **hunk by hunk** (`y`/`n`, `s` to split, `e` to edit), so when you finish you have
*provably* looked at every change. In lazygit (`<leader>gg` / `lg`) it's visual: `<space>` stages a
hunk, `v` then `<space>` stages selected lines. `git add -A` is a rubber stamp; `git add -p` is a
decision per hunk.

**④ What to hunt for.** Standard review isn't calibrated for AI output, because humans rarely produce
plausible-but-wrong code. Review *against* the plausibility:

| Failure mode | The tell | Catch it on the stack |
|---|---|---|
| **Hallucinated API** | a plausible method/flag that doesn't exist | verify upstream — `context7` MCP, or ask the agent to cite it |
| **Swallowed errors** | `try?` / `pcall` / `\|\| true` / bare `catch {}` hiding a failure | `rg` the diff for them; question each |
| **Escape hatches** | `@ts-ignore`, `any`, `--no-verify`, `unsafe` used to mute a warning | `rg` for them; "necessary, or suppression?" |
| **Scope creep** | files touched outside the task; oversized diff | the `--stat` / `--name-only` triage above |
| **Plausible-but-wrong** | reads right, fails quietly | slow down; *run it*; don't trust the surface |
| **Invented config key** *(this repo)* | a keybind/option with no upstream citation | the never-invent rule — [`config.md`](../.claude/rules/config.md) |

Concentrate scrutiny where agents err most — **imports, error handling, auth/security, and duplicated
implementations** ([Osmani](https://addyosmani.com/blog/code-review-ai/)). *(A calibration note: the
peer-reviewed figure for AI-introduced security defects is roughly 40% of samples containing a CWE
([NYU "Asleep at the Keyboard"](https://arxiv.org/abs/2108.09293)); vendor "80–87%" numbers are
inflated by conflict of interest — cite the direction, not the marketing number.)*

**⑤ Prove it, don't just read it.** Reading catches *some* bugs; plausible-but-wrong needs **running**.
For this config repo the proof is [`/check`](../.claude/commands/check.md) — `ghostty +show-config`,
`zellij setup --check`, `nvim --headless`, `zsh -n`: does the config actually **load**. A diff that
reads clean but fails `/check` is not reviewed — it's *unread*. Then confirm the behavior with the
actual keypress. *"If you haven't seen it run, it's not a working system"* (Willison).

### Why small batches, mechanically

Defect-finding **collapses past ~200–400 LOC (or ~500 LOC-hour)** ([SmartBear/Cisco](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/),
industry primary). A 50-line diff is a two-minute read; a 600-line one never gets a real review even
when correct. The mechanism is §7's: a big diff is high **element-interactivity** forced through a
fixed ~4-chunk working memory. Finster's corollary: if reviewing an agent's diff takes as long as a
human's, the fix is **smaller batches + incremental verification**, not a heavier end-review.

### Reviewing *with* a fresh agent

A fresh-context reviewer catches what the building agent, married to its own plan, cannot. In the same
pane: **`/code-review`** (working diff), **`/review <PR>`** (a GitHub PR), **`/security-review`** (a
security pass). Treat the output as **advisory** — it tells you *where* to look harder, not the verdict.
⚠️ **Over-reviewing hazard:** a reviewer prompted to find gaps will usually report some, even when the
work is sound; chasing every finding breeds over-engineering. Instruct it to flag only
correctness/requirement gaps ([best practices](https://code.claude.com/docs/en/best-practices), official).

### Committed work, branches & PRs

Your whole branch, LSP live: `<leader>gm` (`:DiffviewOpen origin/main...HEAD`). The **three-dot** range
compares against the merge-base — the same delta a GitHub reviewer sees. A PR: `gh pr checkout <N>`
makes it local (real files, full LSP), then `:DiffviewOpen origin/main...HEAD`; or triage without
checkout via `gh pr diff <N> | delta`. A big multi-commit PR reviews commit-by-commit with
`<leader>gV` (repo history) rather than one giant diff.

---

## 6. Understand → Analyze → Re-prompt

Verifying is not the end — the loop closes by turning what you learned into the next prompt.

**Get a high-signal summary — evidence, not assertions.** Have the agent *show* the test output, the
command and what it returned — not "it works" ([Anthropic](https://code.claude.com/docs/en/best-practices),
official). The **plan is the spec**; verify the diff *against* it. The **commit message explains WHY,
not WHAT** (Willison) — this repo's mandatory `Decision:` paragraph *is* that discipline
([`commits.md`](../.claude/rules/commits.md)). Ask the agent for a structured walkthrough as an
*understanding aid* — never as proof; every source subordinates the agent's self-summary to your
independent verification.

**Read the diff as architecture, not line-by-line.** `gr` for references, **`]]`/`[[`** to hop between
uses of the symbol under the cursor, `gy`/`gI` for type/implementation, `<leader>cs` (Outline) +
dropbar for shape. Delegate a *wide* read — "trace every caller of this function across the repo" — to
an investigation subagent, to keep your own context clean. Ask the questions you'd ask a senior
engineer.

**A fresh-context critic beats the builder.** *A fresh context improves review because Claude won't be
biased toward code it just wrote* ([Anthropic](https://code.claude.com/docs/en/best-practices), official).
Writer ≠ reviewer — the same reason you don't proofread your own prose cold.

**The return trip.** Feed the review straight back: *"Here's the review feedback: […]. Fix X and Y,
keep Z, don't touch scope."* But know when to stop iterating: **after two failed corrections, `/clear`
and re-prompt fresh.** *A clean session with a better prompt almost always outperforms a long session
with accumulated corrections* (Anthropic). `/rewind` (Esc Esc) abandons a bad turn — but ⚠️ it tracks
only Claude's *file edits*, **not** Bash or external changes ([checkpointing](https://code.claude.com/docs/en/checkpointing),
official). It is not a git replacement; commit real checkpoints in lazygit before a big session.

---

## 7. The cognitive edge

Everything above is one principle applied: **spend your ~4 chunks on judgment, offload the bookkeeping.**
Here is *why* it works — and how to train it.

**Productivity is multidimensional.** Output metrics — LOC, velocity, commit count — fail; the classic
warning is measuring a program's progress by lines is like measuring aircraft by weight. Use the
**SPACE** framework (Satisfaction, Performance, Activity, Communication, Efficiency —
[Forsgren et al., ACM Queue 2021](https://queue.acm.org/detail.cfm?id=3454124)) and **DevEx** (feedback
loops, cognitive load, flow — [ACM Queue 2023](https://queue.acm.org/detail.cfm?id=3595878)). ⚠️ These
are best-in-class *practitioner* frameworks, not open-data-validated science — weigh them as such.

**Why the loop works** (peer-reviewed unless noted):

- **Reduce extraneous cognitive load** (Sweller's Cognitive Load Theory). Bad naming, deep nesting, and
  sheer size/vocabulary measurably raise comprehension load — shown in fMRI/fNIRS studies
  ([Peitek, ICSE 2021](https://dl.acm.org/doi/10.1109/ICSE43902.2021.00056)). Size and vocabulary
  predict load better than cyclomatic complexity does. *This is the why behind small diffs, good names,
  and co-locating context* — types and comments *at point of use* (avoiding the split-attention effect).
- **Offload bookkeeping to *reliable* tools; never offload judgment to an *unreliable* generator.**
  Cognitive offloading helps ([Risko & Gilbert 2016](https://www.sciencedirect.com/science/article/abs/pii/S1364661316301024))
  — but the benefit **vanishes when the external store is unreliable** ([Storm & Stone 2015](https://journals.sagepub.com/doi/10.1177/0956797614559285)).
  AI-generated code is *precisely* unreliable. So: editor, diff, tests, types (reliable) spare your
  working memory; the *judgment* must stay in your head. This is the scientific grounding for "never
  commit what you can't explain" — cognitive mechanics, not morals.
- **Comment the WHY, not the WHAT** (expertise-reversal effect — Kalyuga). Scaffolding that helps a
  novice becomes *extraneous load* for an expert. It's the same principle behind this repo's
  [`comments.md`](../.claude/rules/comments.md).

**How to train** (bank these):

1. **Reduce extraneous load** in everything a human reads; cap diff size (<400 LOC).
2. **Build chunks by deliberately reading well-structured code** — expertise *is* the schema store; you
   grow it on purpose.
3. **Retrieval practice + spacing.** Self-quiz on APIs and patterns; re-derive from memory. Of all study
   techniques, only *practice testing* and *distributed practice* earned "high utility" ratings
   ([Dunlosky et al. 2013](https://journals.sagepub.com/doi/10.1177/1529100612453266)); rereading and
   highlighting rated "low". (Hence the retrieval drills in this guide.)
4. **Offload bookkeeping, keep judgment** (above).
5. **Protect focus.** Task-switching leaves *attention residue* ([Leroy 2009](https://www.sciencedirect.com/science/article/abs/pii/S0749597809000399)),
   and programming resumes especially slowly — only ~10% of interrupted sessions resume within a minute
   ([Parnin 2011](https://www.researchgate.net/publication/224250570)). Switch at completion points, not
   mid-task — which is *also* why you let a delegated agent run to a checkpoint instead of hovering.

> **Retire these attractive falsehoods** if they come up: the "10,000-hour rule" as a law (Ericsson,
> whose research it's drawn from, disavowed the popular version); "learning styles" (debunked —
> [Pashler et al. 2008](https://journals.sagepub.com/doi/10.1111/j.1539-6053.2009.01038.x)); and
> "7±2" as *the* working-memory number (it's ~4 — Cowan, §1).

---

## 8. The frontier

As raw code-writing saturates, the durable craft is **specifying what "correct" means and building the
harness that proves it.** Here's what you're most likely missing — tagged by maturity.

1. **Agent observability** `[established — the biggest blind spot]`. Turn on
   `CLAUDE_CODE_ENABLE_TELEMETRY=1` + OpenTelemetry ([monitoring](https://code.claude.com/docs/en/monitoring-usage),
   official). You can't improve cost or tool-decisions you can't see.
2. **An eval harness, distinct from `/check`** `[established for teams · emerging for solo]`. A task
   suite grading agent *output quality* (fixtures + an LLM-as-judge), run "as routinely as unit tests"
   ([Anthropic](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents), official).
   `/check` proves configs *load*; it does not prove agent output is *good*.
3. **A Stop hook wiring `/check` as a hard gate** `[established]`. A turn can't end until it passes
   ([hooks](https://code.claude.com/docs/en/hooks), official) — deterministic, not a reminder. (This
   repo's [`tooling.md`](../.claude/rules/tooling.md) notes "no commit hook yet" — this is how you'd add
   one.)
4. **Tests-as-contract, committed first** `[established rec · emerging adoption]` — even in a config
   repo, via golden-file fixtures.

**Where NOT to chase hype:** multi-agent *fleets* for coding (scoped away from coding by every vendor);
"sandboxing solves prompt injection" (it only contains blast radius); unsupervised merge (all vendors
keep a human on draft PRs); CEO timelines and headline benchmark numbers (a SWE-bench ceiling ≠ field
reliability; the "89% of Devin PRs" figure failed independent verification).

> **In one line:** verification, not generation, is the 2026–2027 edge.

---

## 9. Anti-patterns

Recognizing the wrong move is half the skill. Each row: the trap → the fix.

| ❌ Don't | ✅ Do |
|---|---|
| Generate a big blob, then refactor for a week | Slice small; pull the architecture *left* into the spec (§2) |
| `git add -A` and rubber-stamp | `git add -p` — a decision per hunk (§5) |
| Trust the agent's "done" | Demand evidence — the check *ran*, with output (§6) |
| One long session, correction after correction | After two failed fixes, `/clear` + a better prompt (§6) |
| Review an agent's diff as fast as a human's | You're rubber-stamping — smaller batches instead (§5) |
| Add agents for speed | The ceiling is *your* review, not the agent count (§1, §4) |
| Pile up a giant rules file | A few load-bearing exemplars; comment the WHY (§3, §7) |
| Make the first generation production-quality | Separate the throwaway spike from the ship (§3) |
| Let two agents share one tree | A worktree per agent — isolation by physics (§4) |

---

## 10. Cheatsheet

The reference layer — the *what*, kept out of the teaching flow above. All keys verified against this
stack's config.

| Keys / command | Action | Tool |
|---|---|---|
| `git diff --stat` / `--name-only` | 30-second scope triage (do this first) | shell |
| `<leader>gv` | Review working-tree changes | Neovim · diffview |
| `<leader>gm` | Review branch vs main (`origin/main...HEAD`) | Neovim · diffview |
| `<leader>gV` / `<leader>gF` | Repo history / current-file history | Neovim · diffview |
| `<leader>gs` / `<leader>gl` | Changed-files picker / git log | Neovim |
| `]c` / `[c` · `<Tab>` / `<S-Tab>` | next/prev hunk · next/prev file | diffview |
| `]h` / `[h` · `<leader>ghp` · `<leader>gb` | jump hunks · preview · blame | gitsigns |
| `gd` / `gr` / `K` · `]]` / `[[` · `gy` / `gI` | def / refs / hover · hop symbol uses · type / impl | Neovim LSP |
| `<leader>cs` | Outline (code shape) | Neovim |
| `git add -p` · lazygit `<space>` | stage hunk-by-hunk = read every change | shell · lazygit |
| `cc-worktree <branch>` | worktree + editor │ agent session | stack |
| `claude --worktree <name>` / `-w` | native worktree session | Claude Code |
| `git worktree list` / `add` / `remove` / `prune` | manage worktrees | git |
| `git diff main..worktree-x` | one agent's contribution, no push | git |
| lazygit Worktrees: `n` · `<space>` · `o` · `d` | new · switch · open · remove | lazygit |
| `/code-review` · `/review <N>` · `/security-review` | fresh-context AI review passes | Claude Code |
| `/check` | prove the config loads (the "tests") | Claude Code |
| `/clear` · `/rewind` (Esc Esc) | fresh session · undo a bad turn (edits only) | Claude Code |
| `gh pr checkout <N>` → diffview · `gh pr diff <N> \| delta` | review a PR locally / triage fast | shell + nvim |
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | agent observability (OTEL) | Claude Code |

---

## 11. Definition of Done

The portable checklist — the loop compressed to what you verify before a change is *done*:

- [ ] **Shape in the spec** — interfaces, boundaries, and what-NOT-to-do, before generation.
- [ ] **Contract committed first** — tests/types green.
- [ ] **Diff < 400 LOC**, and **every line explainable**.
- [ ] **The runnable check passed** — `/check`, with output (evidence, not a claim).
- [ ] **A fresh-context critic ran** — `/code-review` or a new session.
- [ ] **The commit explains WHY** — the `Decision:` paragraph ([`commits.md`](../.claude/rules/commits.md)).

> **Retrieval drill — close the page and answer:**
> 1. Name the four beats of the loop.
> 2. For a new feature, what do *you* own and what do you delegate?
> 3. What is the review ceiling, and why doesn't adding agents raise it?
> 4. Which command shows exactly one agent's diff across two worktrees?

---

## References

- **Cognition:** [Cowan 2001 (working memory ≈ 4)](https://philpapers.org/rec/COWTMN) ·
  [McKeithen 1981 (code chunking)](https://www.sciencedirect.com/science/article/abs/pii/0010028581900128) ·
  [Xia 2018 (58% comprehension)](https://baolingfeng.github.io/papers/tsecomprehension.pdf) ·
  [Sweller/Peitek ICSE 2021](https://dl.acm.org/doi/10.1109/ICSE43902.2021.00056) ·
  [Storm & Stone 2015 (unreliable offload)](https://journals.sagepub.com/doi/10.1177/0956797614559285) ·
  [Dunlosky 2013 (what study works)](https://journals.sagepub.com/doi/10.1177/1529100612453266)
- **Practice & measurement:** [METR 2025 (RCT)](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) ·
  [Osmani — 70% problem](https://addyo.substack.com/p/the-70-problem-hard-truths-about) ·
  [Osmani — reviewing AI code](https://addyosmani.com/blog/code-review-ai/) ·
  [Finster](https://bryanfinster.substack.com/p/ai-broke-your-code-review-heres-how) ·
  [Beck — augmented coding](https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes) ·
  [Willison — parallel coding agents](https://simonwillison.net/2025/Oct/5/parallel-coding-agents/) ·
  [SmartBear (LOC cliff)](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/) ·
  [SPACE](https://queue.acm.org/detail.cfm?id=3454124) · [DevEx](https://queue.acm.org/detail.cfm?id=3595878)
- **Claude Code (official):** [best practices](https://code.claude.com/docs/en/best-practices) ·
  [worktrees](https://code.claude.com/docs/en/worktrees) · [checkpointing](https://code.claude.com/docs/en/checkpointing) ·
  [hooks](https://code.claude.com/docs/en/hooks) · [monitoring](https://code.claude.com/docs/en/monitoring-usage) ·
  [evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) ·
  [multi-agent](https://www.anthropic.com/engineering/multi-agent-research-system)
- **In this repo:** [`guide.md`](guide.md) · [`claude/README.md`](../claude/README.md) ·
  [`.claude/rules/config.md`](../.claude/rules/config.md) · [`commits.md`](../.claude/rules/commits.md) ·
  [`pull-requests.md`](../.claude/rules/pull-requests.md)

> Part of [terminal-stack](../README.md) · pairs with [`guide.md`](guide.md) and the agent layer,
> [`claude/README.md`](../claude/README.md).
