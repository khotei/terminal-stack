# Config comments

**Always-loaded rule.** The default is **no comment**. Config is read far more than written, it is
the source of truth, and every comment is read-cost the reader pays whether or not it pays off — and
an agent acts on a stale comment with full confidence, so a bad comment is worse than none. Earn each
one. Comment the **WHY**; let the config state the WHAT. (Same family as
`.claude/rules/claude-md.md`: config says *what*, prose says *why*.)

Every tool in the stack has a comment syntax — `#` in Ghostty `config`, zsh, and Starship TOML;
`//` or `/* */` in Zellij KDL; `--` in Neovim Lua. The rule is the same in all of them.

This rule has two gates: **(A)** should this comment exist at all (be strict — most shouldn't); and
**(B)** if it survives, write it as a real one-line note, not a scattered narration.

## Gate A — should it exist? (the litmus)

1. **"Could a competent user of this tool get this from the config itself?"** (the key name, the
   value, the keybind, a section header, a `CLAUDE.md`/rule). If yes → delete it.
2. **"Would they get it wrong, or trip on a hidden coupling, without it?"** If yes → it may survive.

When reviewing existing config, **delete on sight** anything that fails (1). The only reasons to keep
a comment:

- **A non-obvious DECISION + the rejected alternative** — "`ctrl+a` prefix, not `ctrl+b` — tmux
  muscle memory, and `ctrl+b` collides with the shell's backward-char." Stops an agent "fixing" it
  back.
- **A GOTCHA or cross-tool coupling**, surprising from a distance — "leave this Ghostty key unbound:
  it's Zellij's prefix"; "this nvim plugin needs `:Lazy sync` after edit"; "Ghostty hot-reloads but
  this key needs a full restart."
- **An INVARIANT the config can't express** — "all multiplexer actions live under one prefix; do not
  add a bare top-level bind."
- **A usage CONSTRAINT** — "source this file *after* the env block; it reads `$EDITOR`."

If it isn't one of these, **delete it.** (A short *section header* comment — `# ── keybinds ──` — is
fine as structure, not narration.)

## Delete-on-sight gallery (the obvious comment)

Each **restates the line it sits on** — write none of them:

```
keybind = ctrl+a>n=new_tab   # bind ctrl+a n to new tab      ← the line says it
font-size = 14               # set the font size to 14        ← reads identically
alias ll='ls -la'            # alias ll to ls -la             ← the alias IS the sentence
-- require the plugin        ← narration above a require()
```

Same offense, other forms: a provenance tag (`(T0N)`, `(Feature §14)` — traceability lives in the
commit `Refs:` footer, not each line); step narration (`# then set the theme`); anything a
rule/`CLAUDE.md`/cheatsheet already states — **link to it, don't restate.**

> **Pre-write test (do this every time):** write the comment, then delete it and re-read the config.
> If the config still tells you the same thing, keep it deleted. A comment earns its place *only* by
> saying what the config **cannot** — Gate A's four: decision, gotcha, invariant, usage-constraint.

## Gate B — write the survivor as a tight note

A comment that earns its place is a **one-line note at the exact line it warns about**, leading with
the *why*. Lead with the decision or the gotcha; reference the upstream doc with a short URL or a
`see` pointer if the reader must open it to act. One strong sentence beats a paragraph. Comment
intent (stable) and rationale (untestable), never mechanics.

## Not comments — never strip these

Directive lines are config, not prose: a shebang (`#!/usr/bin/env zsh`), a tool pragma, a
`stylua: ignore` / `shellcheck disable` directive. They stay regardless of the rules above.
