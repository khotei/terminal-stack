# Maintaining `CLAUDE.md` and rules (context, not a config dump)

**Always-loaded rule.** A `CLAUDE.md` (or a rule file) is a cache of what the **config cannot say**.
The config files are the source of truth for *what* the setup is — the keys, the keybinds, the
plugin specs, the values. These docs exist only for *why* it is that way, and for constraints that
aren't local to one file. Optimize for the next reader (usually a future Claude session) and for low
drift.

## The test, before writing any line

1. **"Could I derive this by reading the config itself?"** If yes → don't write it. Restating a
   keybind, a value, or an idiom that's visible in `ghostty/config` / a KDL node / a Lua spec is
   **drift bait**: it duplicates the config, and the next rebind silently turns it into a lie.
2. **"Would a reader get this wrong, or waste real time, without it?"** If yes → write it.

Sharp signal: **if a rebind/refactor forces a `CLAUDE.md` edit, the doc was holding *what*, not
*why*.** Move that knowledge back to being implied by the config, and delete the line.

## Belongs (keep)

- **Decisions + the rejected alternative** — the *why*, and the option not taken (this prefix over
  that one; this plugin over its rival). Unrecoverable from config, which only shows the survivor.
- **Invariants the config can't express**, and cross-tool coupling (e.g. "this Ghostty key must
  stay unbound — `ctrl+a` is Zellij's prefix"; "nvim's leader must not collide with the multiplexer
  prefix").
- **Non-obvious gotchas** — reload requirements, version quirks, a key that only works on macOS.
- **Boundaries** — which file owns which concern, "this is the single source of the keymap".
- **Pointers** — to the spec (Notion), `.claude/agent-patterns/*`, the upstream doc, or the file
  where the surface lives.

## Does NOT belong (cut)

- A line-by-line listing of keybinds or values — the config file *is* the contract; link to it.
- Restating an idiom the config already shows (Ghostty's `key = value`, KDL nesting, a lazy.nvim
  spec shape) or anything an agent already knows about the tool.
- A narration of the cheatsheet — keep at most a pointer to it.
- Anything already stated in another doc — **link by name, don't restate** (the de-dup rule).

## Shape & timing

- **Short.** A repo `CLAUDE.md` is responsibilities + load-bearing decisions + gotchas + boundaries +
  pointers — not a manual. When in doubt, cut: a missing line costs one `Read`; a wrong line costs a
  silent mistake made with confidence.
- **Refresh only when a real change is about to land** (as part of preparing the commit), not on
  every exploratory edit. Then run `/check` so the doc and the config it describes ship together.
