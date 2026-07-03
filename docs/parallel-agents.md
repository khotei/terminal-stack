# 🔀 Parallel agents — many sessions, one repo, no collisions

Running two or more Claude Code agents on the **same repository at once** — one shipping a feature
while another cleans up, or several SDD hand-offs in flight together. Done naively they *fight*: they
share one working tree on disk, so they overwrite each other's edits and stage stale snapshots. This
doc is the two ways to keep them apart, how to launch each with this stack, and how to **merge the
parallel work back** at the end.

> **New here?** The one-liner recipe lives in [`guide.md` → flow 5](guide.md#5-run-agents-in-parallel-worktrees).
> This page is the full model behind it: *why* it collides, the two isolation modes, and the merge-back.

---

## Why they collide

Every symptom traces to **one root: two agents writing into the same working directory on disk.**

- **Write race.** Agent A edits `words.api.ts`; while A's change sits unstaged, agent B (say, a
  comment cleanup running tree-wide) rewrites the same file. A's on-disk copy — and anything A already
  staged from it — is now stale, and A doesn't know.
- **Stale git index.** `git add` snapshots the file *at that moment*. If another agent rewrites it
  afterward, the commit ships the **old** snapshot and silently clobbers the other agent's work.
- **Tree-wide tools hit foreign files.** `biome check`, `tsc`, a formatter, a codemod — they walk the
  **whole tree**, not just one agent's files. One agent's `format` reformats files another is mid-edit.

None of this is about Claude being careless; it's two writers, one tree. Fix the sharing and every
symptom disappears.

---

## Two ways to isolate

| | **Mode A — split by file** | **Mode B — a worktree per agent** |
|---|---|---|
| **Isolation** | Same tree; agents agree to touch disjoint files | Separate tree + branch per agent; shared `.git` |
| **Collisions** | Prevented **by discipline** — one slip and it races | Prevented **by physics** — different dirs can't race |
| **Setup** | None | One command per agent |
| **Merge-back** | Already one branch — just commit | Branch per agent → PR → squash-merge |
| **Good for** | One main agent + a light background chore | Real parallel development — the default |
| **Verdict** | Fragile; the fallback | **Recommended** |

---

## Mode A — shared tree, split by file

No setup, but **brittle** — it holds only while every agent obeys the rules. Reserve it for *"one
main agent + one background cleanup"*, never for two agents doing real feature work.

The rules, non-negotiable:

- **Disjoint ownership.** Assign each agent a zone that does not overlap — agent 1 owns `apps/web/**`
  + docs, agent 2 owns `core/**` + `repositories/**`. Two agents on **one file** = a race. Decide
  ownership *before* they start.
- **Never `git add -A` / `git add .`.** Stage an **explicit path list** — only your own files. After
  staging, confirm nothing foreign leaked: `git diff --cached --name-only`.
- **No tree-wide tools in parallel.** `biome check`, `tsc`, formatters, codemods walk the whole tree.
  Run them **serially**, when only one agent is active — never while another is editing.
- **Commit small and often.** The less that sits unstaged, the smaller the window for another agent's
  write to overtake you.

If keeping these straight feels like work, that's the signal to switch to Mode B.

---

## Mode B — a worktree per agent (recommended)

A [git worktree](https://git-scm.com/docs/git-worktree) is a **second checkout of the same repo** —
its own directory and its own branch, sharing the one `.git`. Give each agent its own worktree and
file races are **impossible**: they're editing different directories. You reunite the work through
branches at the end (see [Merging back](#merging-the-parallel-work-back)).

There are three ways to get a worktree per agent. Pick by how much of a workspace each agent needs.

### 1. The stack way — `cc-worktree` (full editor │ agent session)

The stack ships [`cc-worktree.sh`](../claude/cc-worktree.sh): it makes the worktree **and** opens a
Zellij [`dev` layout](../zellij/layouts/dev.kdl) in it — Neovim on the left, an agent pane on the
right. Reach for this when the parallel task wants the **whole workspace** (you'll read/steer, not
just fire-and-forget an agent).

```sh
cc-worktree feat/email-validation        # → ../terminal-stack-feat-email-validation/ + a Zellij dev session
cc-worktree fix/rate-limit origin/main   # branch from a specific base instead of HEAD
```

- Creates a **sibling** directory `../<repo>-<branch-slug>/` (outside the repo, so it never shows up
  as untracked in your main checkout), checks out the branch there, and opens a `dev` session named
  after the branch. Start a `claude` in the agent pane.
- Bounce between sessions: `⌃a` `p`/`n`, or `zellij attach <name>`.
- **Base defaults to `HEAD`** — the worktree branches from your *current* local work, not a stale
  remote default. (Contrast the native flag below, which defaults to the remote default branch.)
- Install once by symlinking onto `$PATH`: `ln -sf "$PWD/claude/cc-worktree.sh" ~/.local/bin/cc-worktree`.

### 2. The native way — `claude --worktree` (a lone agent session)

Claude Code has this built in ([docs](https://code.claude.com/docs/en/worktrees)). Lighter than
`cc-worktree` — it starts a **session in a worktree**, no Neovim pane. Reach for it when you just
want a parallel agent, not a full editor workspace.

```sh
claude --worktree feature-x      # or: claude -w feature-x
claude --worktree                # name auto-generated (e.g. bright-running-fox)
claude --worktree "#1234"        # branch from GitHub PR #1234
git worktree list                # see them all
```

- Worktree lands in **`.claude/worktrees/<name>/`** (inside the repo, hence the `.gitignore` entry —
  see [Prep](#prep-one-time-setup)), on a branch named `worktree-<name>`.
- **Branches from the remote default branch by default** (`baseRef: "fresh"`). To branch from your
  local HEAD instead — the usual want when you're extending in-progress work — set `baseRef: "head"`
  (see [Prep](#prep-one-time-setup)).

**Desktop (macOS).** Same idea, no flags: **`⌘N`** opens a new session and Claude Code **auto-isolates
it in its own worktree**, so several sessions on one repo don't touch each other until you commit.
Running two sessions on the same directory is *fine* — that's the point. `⌘`-click a session in the
sidebar to view two side-by-side; **Settings → Claude Code → "Auto-archive after PR merge or close"**
cleans worktrees up for you.

### 3. Subagents — one session that fans out (`isolation: worktree`)

When a *single* session spawns helpers (the SDD agents in [`.claude/agents/`](../.claude/agents/), or
an ad-hoc "use worktrees for these agents"), each helper can run in its **own temporary worktree** so
they don't collide with each other or the parent. Add to a custom subagent's frontmatter:

```yaml
---
name: my-agent
isolation: worktree
---
```

- The temp worktree **auto-cleans if the subagent leaves no changes**; if it made edits, you're asked
  whether to keep them ([docs](https://code.claude.com/docs/en/sub-agents)).
- Branches from `baseRef` (default the remote default branch), same setting as the CLI flag.
- **Practical ceiling: ~3–5 in parallel.** Each subagent is a full context window — N agents ≈ N× the
  tokens. Parallelism buys wall-clock, not free work.

---

## Prep (one-time setup)

Three small settings make Mode B frictionless. The first is the one that fixes the classic *"my
worktree branched from an old commit"* surprise.

**1. `worktree.baseRef: "head"`** — in `~/.claude/settings.json` (this stack ships it via
[`claude/settings.json`](../claude/settings.json), so a fresh install already has it). Native
worktrees default to `"fresh"` (branch from the remote default branch); `"head"` branches from your
**local HEAD**, keeping unpushed commits and in-progress work:

```json
{ "worktree": { "baseRef": "head" } }
```

> Only two values: `"head"` or `"fresh"`. Flip to `"fresh"` if you'd rather every worktree start from
> a clean default branch. (`cc-worktree` already defaults to `HEAD`, so this only affects the native
> `--worktree`/desktop path.)

**2. `.worktreeinclude`** — *in your **application** repos, not this one.* Native worktrees start
without gitignored files, so a backend's `.env` won't be there and the app won't boot. List the
gitignored files to copy into each new worktree (`.gitignore` syntax), at the repo root:

```
.env
.env.local
```

> terminal-stack itself has no secrets to copy (it's a public config repo — [`config.md`
> §Secrets](../.claude/rules/config.md)), so it ships no `.worktreeinclude`. Add one in `lexi-ai` and
> friends where a worktree needs the git-ignored env to run.

**3. `.gitignore` → `.claude/worktrees/`** — already set here. Native worktrees live inside the repo;
ignoring the folder keeps them from showing as untracked in the main checkout. (The `cc-worktree`
sibling-dir approach sidesteps this — it puts worktrees *outside* the repo.)

---

## Merging the parallel work back

Isolation is only half the job — the other half is reuniting the branches. Each Mode B agent is on
its own branch, so this is ordinary Git, and it slots straight into the stack's
[squash-merge PR flow](../.claude/rules/pull-requests.md):

1. **Push each branch** and open a **PR per branch**. Each PR is a self-contained reference guide
   ([`pull-requests.md`](../.claude/rules/pull-requests.md)); the squash collapses it to one commit
   on `main` whose subject is the PR title.
2. **Squash-merge** them (the repo is configured for *title + body* squash). Independent worktrees on
   disjoint files merge cleanly, in any order.
3. **Two branches touched the same file?** Resolve it *at merge*, not on disk mid-run — that's exactly
   the race Mode B avoids. Rebase the second branch on the first (or on updated `main`):

   ```sh
   cd ../terminal-stack-feat-x            # (or .claude/worktrees/feat-x for a native worktree)
   git fetch origin main && git rebase origin/main   # resolve conflicts here
   git push --force-with-lease
   ```

4. **Clean up** when a branch is merged: `git worktree remove <path>`, then `git worktree prune`
   periodically. (Desktop's *Auto-archive* does this for you; `cc-worktree`'s sibling dirs you remove
   yourself.)

**Split to reduce merge pain.** The cleaner you divide work by **file ownership** up front (the same
disjoint-zone idea as Mode A), the fewer branches touch one file, and the fewer rebases at the end.
For the parallel SDD hand-off pattern — one self-contained prompt per worktree — divide tasks by the
files they own, branch each from `head`, and let the PRs reunite them.

---

## Which mode when

| You're doing… | Use |
|---|---|
| One main agent + a light background chore (comment sweep, rename) | **Mode A**, staging an explicit file list |
| Two+ agents on real feature work at once | **Mode B** — `cc-worktree` for a full editor workspace each |
| A quick parallel agent, no editor pane needed | **Mode B** — `claude --worktree` (or `⌘N` on desktop) |
| One session that needs to fan out to helpers | **Mode B** — subagents with `isolation: worktree` |

**Rule of thumb:** if two agents will both *write real code*, give them worktrees. Mode A is only for
a chore riding along behind one real agent.

---

## References

- **Claude Code worktrees** — <https://code.claude.com/docs/en/worktrees> (`--worktree`, `baseRef`,
  `.worktreeinclude`).
- **Desktop parallel sessions** — <https://code.claude.com/docs/en/desktop>.
- **Subagents** (`isolation: worktree`) — <https://code.claude.com/docs/en/sub-agents>.
- **git worktree** — <https://git-scm.com/docs/git-worktree>.
- **In this repo:** [`claude/README.md`](../claude/README.md) (the agent layer · `cc-worktree`) ·
  [`guide.md` flow 5](guide.md#5-run-agents-in-parallel-worktrees) ·
  [`pull-requests.md`](../.claude/rules/pull-requests.md) (the squash-merge PR flow).

---

> Part of [terminal-stack](../README.md) · the agent layer: [`claude/README.md`](../claude/README.md).
