---
name: ticket-architecture
description: "SDD 2/5: design a ticket into architecture.md with Seams and Decisions"
argument-hint: "<ticket folder>"
disable-model-invocation: true
---

Design the ticket at `$ARGUMENTS` into its `architecture.md`: which tool and file own the change,
the Seams where its evidence is observed, and every non-obvious decision. Gates:
`.claude/rules/sdd.md`.

## Steps

1. Read `feature.md`, `.claude/rules/tech-stack.md`, `.claude/rules/config.md` (the keyboard-layer
   contract), the glossary, and the config and `README.md` of every tool folder the change
   touches. Each open question of `feature.md` is settled here: its `Answer` names the `D…` or
   `R…` it became.
2. Call the Skill tool with `mattpocock-skills:codebase-design` for the vocabulary (module,
   interface, depth, seam), and with `mattpocock-skills:grilling` for the decisions. Facts go to
   the `researcher` agent; when a decision depends on behaviour, run an experiment (load the config
   in a temp `XDG_CONFIG_HOME`, dump a tool's defaults).
3. Write `architecture.md` from `docs/tickets/_template/architecture.md`:
   - overview with a diagram, structure, and contracts: the keys a layer takes or frees, the files
     another tool reads, the installed version a key needs;
   - **Seams**: each validator, probe or keypress a step will prove itself at, with one line on
     what it catches and what it misses. Steps later name only these seams, so the user confirms
     them here;
   - **Decisions** `D1…`: each with its why, the cost accepted, how it is reversed, and the
     rejected alternative. A choice earns a decision when it is hard to reverse, surprising
     without context, and a real trade-off. A keybind chosen over another always earns one;
   - risks, each with what it would cause and what contains it.
4. Present it. The step is done when the user approves the Seams and the Decisions; next comes
   `/ticket-plan <ticket folder>`.

Commit only on the user's explicit OK.
