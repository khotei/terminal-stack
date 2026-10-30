---
name: ticket-implement
description: "SDD 4/5: implement one plan.md step, review it, and commit only after approval"
argument-hint: "<ticket folder> [step id, default: next todo]"
disable-model-invocation: true
---

Take one step of the ticket at `$ARGUMENTS` from `todo` to an approved commit. Gates:
`.claude/rules/sdd.md`.

## Steps

1. **Pick the step:** the one named, else the first `todo` step whose `Blocked by` steps are all
   `done`. Check that the branch is the ticket branch (`<type>/<slug>`) and that `git status`
   shows no uncommitted change to tracked files; otherwise stop and ask.
2. **Implement.** Spawn the `implementer` agent with pointers only: the ticket folder and the
   step id, on the `model` and `effort` the step's **Model** line names. Its `Stop` hook keeps it
   working until `scripts/check.sh` is green. A report that starts with `BLOCKED:` goes straight
   to the user.
3. **Review.** Call the Skill tool with `mattpocock-skills:code-review`, overriding:

   | code-review asks for | Use |
   |---|---|
   | the fixed point and diff | `HEAD`; the diff is `git diff HEAD` plus every untracked file in `git status --short`, so the uncommitted step is reviewed |
   | the spec | the step in `plan.md`, and the `R…` it cites from `feature.md`; the Spec axis also reports whether the diff changes what a quoted `R…` asks, which then requires the `feature.md` edit in the same diff |
   | the standards | `.claude/rules/*.md` and `.claude/CLAUDE.md` |
   | the sub-agents | the `reviewer` agent, once per axis, in parallel; the Standards axis on `model: sonnet`, the Spec axis on the agent's own |

   The review does not report `plan.md` Status or findings as missing: the main session writes
   them at approval.
4. **Present** the implementer's report, its keypresses for the user to try, then the
   `## Standards` and `## Spec` reports as code-review aggregates them, then the fixes you
   recommend.
5. **Approval gate.** Wait for the user's explicit word:
   - **approve:** set the step's `Status: done` in the step and in its row of the plan's
     **Status** table, add its findings to `plan.md` and any new decision to `architecture.md`,
     stage the step's files, and commit with the proposed message as a command of its own. An
     amendment also rewrites the decision's body, Contract, Seam or Risks entry it makes wrong;
   - **feedback:** first offer to commit the tree as it stands as the current round (`S3.1`,
     config only, no `plan.md` edit), then send the feedback to the same implementer
     (`SendMessage`) as the next round, and return to 3;
   - **stop:** leave the working tree as it is.

   A word that is stale (given before the latest report) or unclear is not an approval: ask.
6. Name the next unblocked step.

One step, or one round of it, per approval. Pushing or opening a PR needs its own OK.

## Parallel steps

On the user's word, steps whose `Blocked by` are all `done` run at once, one worktree each, when
their overlap is mechanical only: separate tool folders, separate sections of one README. Never
when both change one config file's same block or one keymap.

- Name each worktree `<slug>-<step>-<topic>`. Spawn each `implementer` with
  `isolation: "worktree"`; its prompt carries the name, the order to leave `plan.md` and
  `architecture.md` alone, the order to write every path through `.claude/worktrees/<name>` and
  never through the `agent-<id>` folder, and this block, with the name filled in, to run first:

  ```sh
  (
    cd "$(git rev-parse --show-toplevel)" || exit 1
    NAME=<slug>-<step>-<topic>
    main=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
    [ "$(git rev-parse --path-format=absolute --git-dir)" != "$main/.git" ] ||
      { echo 'refused: this is the main tree' >&2; exit 1; }
    ln -sfn "$(basename "$PWD")" "$(dirname "$PWD")/$NAME" || exit 1
    git branch -m "wt/$NAME"
  )
  ```

- Check the symlink and the branch with `git worktree list` once the agent has started. Never
  move a folder an agent works in. Every status names each worktree by its full path.
- Reviews and approvals stay one step at a time. On approve, cherry-pick the step's rounds onto
  the ticket branch, the last with `--no-commit` so the `plan.md` and `architecture.md` edits
  join it, and run `bash scripts/check.sh` after each pick.
- Remove a worktree, its symlink and its branch only once the step is approved and picked, or
  dropped; in a command of their own, never chained after a commit, and only when `git log` shows
  the rounds on the ticket branch and the worktree's `git status --short` is empty.
