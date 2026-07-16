# 🤖 Claude Code — the agent layer

The coding agent that lives in a **Zellij pane** next to Neovim, driven by voice or keyboard. Claude
Code is a **TUI**, not an IDE plugin — so it shares the terminal, the multiplexer, and the shell with
the rest of the stack.

**This file is the single source for Claude Code in this stack** — the mental model, every keybinding
and slash command, the fast recipes, the parallel-agent workflow, and this repo's config rationale
(status line, worktree helper, settings). Nothing to hunt across other files.

> **Two `claude` directories, deliberately separate.** This [`claude/`](.) folder is the *user-facing*
> Claude Code config — it installs to `~/.claude/`. It is **not** the repo's own [`.claude/`](../.claude/),
> the SDD toolkit that *builds* this repo. This README is about **using** Claude Code and about the
> config in `claude/`.

- **Files:** [`settings.json`](./settings.json) → `~/.claude/settings.json`,
  [`statusline.sh`](./statusline.sh) → `~/.claude/statusline.sh`,
  [`keybindings.json`](./keybindings.json) → `~/.claude/keybindings.json`,
  [`rules/*.md`](./rules/) → `~/.claude/rules/`, [`cc-worktree.sh`](./cc-worktree.sh) → a `$PATH` dir,
  [`mcp-setup.sh`](./mcp-setup.sh) → run once
- **Validate:** `bash -n` (shell syntax) + valid JSON (`jq`) + a mock-input status-line render — run by `/check` + CI
- **Feature:** `F-AGENT-001` … `F-AGENT-004` · **Upstream:** <https://code.claude.com/docs/en>

### Contents

1. [The mental model](#1-the-mental-model) — modes, sigils, and the one reflex the pane demands
2. [Quick start: the moves that pay rent](#2-quick-start--the-moves-that-pay-rent)
3. [Complete reference](#3-complete-reference) — keyboard shortcuts · sigils · slash commands · CLI flags
4. [Recipes — "I want to… → do this"](#4-recipes--i-want-to--do-this)
5. [Parallel agents — git worktrees](#5-parallel-agents--git-worktrees)
6. [Advanced craft](#6-advanced-craft) — plan mode · rewind · memory · vim input
7. [Anti-patterns](#7-anti-patterns)
8. [Living in a Zellij pane](#8-living-in-a-zellij-pane) — the manual lock · `Ctrl+G` · `Alt+d` · voice
9. [The status line](#9-the-status-line) · [Settings, plugins & MCP](#10-settings-plugins--mcp) · [Global rules](#11-global-rules--rules)
10. [Verify](#12-verify) · [Install](#13-install) · [Go deeper](#go-deeper)

---

## 1. The mental model

Claude Code is a **modal TUI driven by three things**: a **mode** you toggle, a handful of **sigils**
you type at the start of the prompt, and **`/` commands**. Learn those and you are productive — the
rest is craft.

**The mode toggle.** `Shift+Tab` cycles the **permission mode**, and the footer shows which one you're
in ([interactive-mode](https://code.claude.com/docs/en/interactive-mode) ·
[permission-modes](https://code.claude.com/docs/en/permission-modes)):

```
default (Manual) ──[ Shift+Tab ]──▶ acceptEdits ──▶ plan ──▶ (any others you enable) ──▶ default …
```

- **default** — Claude asks before each edit/command. The safe baseline.
- **acceptEdits** — file edits auto-apply; you stop babysitting the diff, still gated on shell.
- **plan** — read-only: Claude investigates and proposes a plan but **touches nothing** until you approve.

**The sigils** — the first character of your prompt changes what it *is*
([interactive-mode](https://code.claude.com/docs/en/interactive-mode)):

| Sigil | Means |
|---|---|
| `/` | a **command** or skill (`/model`, `/clear`, …) |
| `@` | a **file/dir reference** — triggers path autocomplete, hands the file to Claude |
| `!` | **shell mode** — run the command yourself; its output enters context and Claude responds to it |

**The one reflex the pane demands.** Claude Code runs *inside* a Zellij pane, and by default Zellij's
own modal keys (`Ctrl+p`/`t`/`n`/`s`/`o`) win — so a Claude `Ctrl`-shortcut can be eaten. Press
**`Alt+d`** to drop the pane into **Locked** mode: now every keystroke reaches Claude
([§8](#8-living-in-a-zellij-pane)). The cost: while locked, Zellij's own hotkeys are dormant. So two
mirror-image reflexes: **a Claude `Ctrl`-key "didn't work"? You're not locked — press `Alt+d`.** And:
**a Zellij key "didn't work"? You're still locked — `Alt+d` back.**

---

## 2. Quick start — the moves that pay rent

Ten moves that cover ~90% of real use. (Exhaustive tables in [§3](#3-complete-reference).)

| Reflex | Keys / input |
|---|---|
| Cycle mode (→ auto-accept → plan) | `Shift+Tab` |
| Stop Claude mid-turn (keeps work so far) | `Esc` |
| Clear the input / rewind to an earlier point | `Esc` `Esc` (double) |
| Reference a file in your prompt | type `@` then the path |
| Run a shell command into context, get a reply | type `!` then the command |
| Edit a long prompt in your `$EDITOR` | `Ctrl+G` |
| Speak your prompt (hold to talk, release to send) | `Ctrl+F` ([§8](#8-living-in-a-zellij-pane)) |
| Free context without losing the thread | `/compact` |
| Fresh conversation, empty context | `/clear` |
| Toggle the pane's Zellij lock (hand keys to Claude ⇄ back) | `Alt+d` |

> `Esc` `Esc` is overloaded by design: with text in the box it **clears the draft** (recall with `Up`);
> with the box **empty** it opens the **rewind menu** to restore code/conversation from earlier
> ([interactive-mode](https://code.claude.com/docs/en/interactive-mode) · [checkpointing](https://code.claude.com/docs/en/checkpointing)).

---

## 3. Complete reference

Shortcuts vary by terminal; inside a session `/` lists every command and the transcript viewer's `?`
lists its keys. The tables below are the offline copy
([interactive-mode](https://code.claude.com/docs/en/interactive-mode) ·
[commands](https://code.claude.com/docs/en/commands)).

### Keyboard shortcuts — session control

| Keys | Action |
|---|---|
| `Esc` | Interrupt Claude / close a dialog (work so far is kept) |
| `Esc` `Esc` | Clear the input draft, or (empty box) open the **rewind** menu |
| `Ctrl+C` | Interrupt a running op; if idle, first press clears input, second exits |
| `Ctrl+D` | Exit the session (EOF) |
| `Ctrl+L` | Redraw the screen (recover a garbled display; input kept) |
| `Ctrl+O` | Toggle the **transcript viewer** (full tool I/O; expands MCP calls) |
| `Ctrl+R` | Reverse-search command history (`Ctrl+S` cycles scope; `Tab`/`Enter` accept) |
| `Ctrl+G` *(or `Ctrl+X Ctrl+E`)* | Open the prompt in your default `$EDITOR` |
| `Ctrl+T` | Toggle Claude's to-do checklist (not the background-task view — that's `/tasks`) |
| `Ctrl+B` | Background the running Bash command / agent (**tmux: press twice**) |
| `Ctrl+V` | Paste an image from the clipboard — screenshot / mockup, inserts an `[Image #N]` chip |
| `Ctrl+X Ctrl+K` | Stop **all** background subagents in the session (press twice to confirm) |
| `Option+T` / `Option+P` | Toggle extended thinking / switch model without clearing the draft |
| `?` *(empty input)* | Toggle the keyboard-shortcut help panel |
| `Up`/`Down` | Move the cursor in multiline input; at the edge, step through history |
| `Shift+Tab` | Cycle permission mode (**default → acceptEdits → plan → …**) |

> macOS: `Option+…` shortcuts may need **Option as Meta** set in the terminal (Ghostty / iTerm2) —
> see [terminal-config](https://code.claude.com/docs/en/terminal-config).

### Keyboard shortcuts — editing the prompt

Readline-style editing, plus multiline. `Ctrl+A/E` line start/end · `Ctrl+K` kill to end · `Ctrl+U`
kill to start · `Ctrl+W` delete word · `Ctrl+Y` paste killed text.

**Multiline input** — `\` + `Enter` (any terminal) · `Ctrl+J` (any terminal, no config) · `Shift+Enter`
(native in **Ghostty**, iTerm2, WezTerm, Kitty, Warp, Apple Terminal, Windows Terminal). For editors that
need it, run `/terminal-setup` to install the `Shift+Enter` binding.

### Sigils — the first character of the prompt

| Type at start | Effect |
|---|---|
| `/` | Command / skill picker — type to filter |
| `@` | File-path mention with autocomplete; the file is handed to Claude |
| `!` | Shell mode — runs the command, adds output to context, Claude responds to it |

### Slash commands (the ones you'll actually reach for)

| Command | Does |
|---|---|
| `/clear` | Start a new conversation with empty context |
| `/compact [hint]` | Summarize the conversation to free context (thread continues) |
| `/context` | Visualize context-window usage as a colored grid |
| `/btw <q>` | Side question — ephemeral, no context pollution; works even while Claude is busy (`f` forks it) |
| `/recap` | One-line recap of the session so far (also auto-appears when you return) |
| `/model [name]` | Switch the model and save it as default |
| `/config` | Open the settings UI (or `/config <key> <value>` to set one directly) |
| `/agents` | Manage subagent configurations |
| `/mcp` | Manage / authenticate MCP servers |
| `/memory` | Browse & edit `CLAUDE.md` / rules / auto-memory files |
| `/init` | Generate a starting `CLAUDE.md` for the project |
| `/review [PR]` | Fast read-only review of a GitHub PR |
| `/rewind` | Restore code and/or conversation to an earlier checkpoint |
| `/resume [name]` | Resume a past conversation by id or name |
| `/voice [hold\|tap\|off]` | Toggle voice dictation / set its mode |
| `/keybindings` | Open `~/.claude/keybindings.json` |
| `/statusline` | Configure the status line |
| `/hooks` | View hook configuration |
| `/permissions` | Manage allow / ask / deny tool rules |
| `/doctor` | Diagnose setup issues |
| `/cost` · `/usage` | Session / plan usage |
| `/export` | Export the conversation as text |
| `/help` | List all commands |

Plugins and MCP servers add more; `/code-review`, `/commit`, `/security-review`, `/schedule` etc. come
from the plugins this repo enables ([§10](#10-settings-plugins--mcp)).

### CLI flags — starting Claude

| Invocation | Does |
|---|---|
| `claude` | Start an interactive session |
| `claude "prompt"` | Start with an initial prompt |
| `claude -c` / `--continue` | Continue the most recent conversation here |
| `claude -r "<name>"` / `--resume` | Resume a session by id or name |
| `claude -p "prompt"` / `--print` | One-shot headless (pipe-friendly: `cat f \| claude -p "…"`) |
| `claude --model <alias>` | `opus` · `sonnet` · `haiku` · `fable`, or a full model id |
| `claude --permission-mode plan` | Start in a mode (`default`/`acceptEdits`/`plan`/`bypassPermissions`) |
| `claude --add-dir <path>` | Grant read/edit access to extra directories |
| `claude -w <name>` / `--worktree` | Start in an isolated git worktree ([§5](#5-parallel-agents--git-worktrees)) |
| `claude mcp add …` | Register an MCP server ([§10](#10-settings-plugins--mcp)) |
| `claude update` | Update to the latest version |

Full list: [cli-reference](https://code.claude.com/docs/en/cli-reference).

---

## 4. Recipes — "I want to… → do this"

**Have Claude plan before it touches anything.** `Shift+Tab` to **plan mode** (or `claude
--permission-mode plan`): Claude reads the code, proposes a plan, and edits **nothing** until you
accept ([permission-modes](https://code.claude.com/docs/en/permission-modes)). The right default for a
change you don't fully understand yet.

**Stop babysitting each diff.** `Shift+Tab` once to **acceptEdits** — file edits auto-apply, shell
commands still ask. Flip back with `Shift+Tab` when you want the brakes on.

**Feed a file or a command output into the prompt.** Type `@src/api/handlers.ts` to attach a file
(autocomplete kicks in), or `!npm test` to run the tests — the output lands in context and Claude
explains the failures without a second prompt
([interactive-mode](https://code.claude.com/docs/en/interactive-mode)).

**Compose a long, structured prompt.** `Ctrl+G` opens the prompt in `$EDITOR` — write it with real
editor motions, save, and it returns to the box. Pairs with vim input mode
([§6](#6-advanced-craft)).

**Undo Claude's last few edits.** `Esc` `Esc` on an empty box (or `/rewind`) opens the checkpoint menu
— restore the code, the conversation, or both, to an earlier point
([checkpointing](https://code.claude.com/docs/en/checkpointing)).

**Keep a long session alive without drowning in tokens.** Watch the status line's `ctx %`
([§9](#9-the-status-line)); when it climbs, `/compact` summarizes and frees room, or `/clear` starts
fresh. `/context` shows exactly what's eating the window.

**Teach Claude something durable.** Ask it to remember ("always use `pnpm`, not `npm`") and it writes
to auto-memory; `/memory` lists and edits every `CLAUDE.md`, rule, and memory file loaded this session
([memory](https://code.claude.com/docs/en/memory)). Project facts belong in `./CLAUDE.md`; personal,
cross-project ones in `~/.claude/CLAUDE.md` or `~/.claude/rules/` ([§11](#11-global-rules--rules)).

**Run two agents on one repo at once.** A worktree per agent — see [§5](#5-parallel-agents--git-worktrees).

---

## 5. Parallel agents — git worktrees

Two agents in one working tree **fight** — they overwrite each other's edits and stage stale
snapshots. The fix is a **git worktree per agent**: its own directory + branch, one shared `.git`, so
file races are impossible.

**This repo's helper** — [`cc-worktree.sh`](./cc-worktree.sh) makes the worktree **and** opens a
Zellij `dev` session (editor │ agent) in it:

```sh
cc-worktree.sh feat/new-thing          # → ../<repo>-feat-new-thing/ + a Zellij dev session
cc-worktree.sh fix/bug origin/main     # branch from a specific base instead of HEAD
```

It creates a **sibling** `../<repo>-<branch>/` (outside the repo — never shows as untracked), checks
out the branch there, and (if Zellij is installed) opens a `dev`-layout session named after the branch.
Install by symlinking onto your `$PATH`:

```sh
ln -sf "$PWD/claude/cc-worktree.sh" ~/.local/bin/cc-worktree
```

**Claude Code's built-in worktrees** — `claude --worktree <name>` (`-w`) starts a *lone* agent session
in an isolated git worktree, no editor pane
([cli-reference](https://code.claude.com/docs/en/cli-reference)); subagents can isolate with
`isolation: worktree`. This repo's [`settings.json`](./settings.json) sets **`worktree.baseRef:
"head"`** so a native worktree branches from your *current* work, not the remote default — matching what
`cc-worktree.sh` does with `HEAD`.

> **When to use which:** `cc-worktree.sh` when you want the **editor │ agent split** to code alongside
> the agent; `claude -w` when you just need an isolated agent and no Neovim pane. The full model — why
> they collide and how to **merge the parallel branches back** — is
> [`docs/parallel-agents.md`](../docs/parallel-agents.md). Read it before running two agents on real
> code at once.

---

## 6. Advanced craft

- **Plan mode as the default gear** — for anything non-trivial, start in plan mode and read the plan
  before a single edit lands. Cheaper than reverting.
- **Rewind / checkpointing** — Claude snapshots as it works; `Esc` `Esc` (empty box) or `/rewind`
  restores code, conversation, or both to an earlier turn
  ([checkpointing](https://code.claude.com/docs/en/checkpointing)). Your safety net for a bad edit.
- **Auto-memory + `CLAUDE.md`** — two layers: **you** write `CLAUDE.md` (rules, always loaded); **Claude**
  writes auto-memory (learnings, per-repo). Both load every session; `/memory` audits them
  ([memory](https://code.claude.com/docs/en/memory)).
- **Vim input mode** — this stack sets `"editorMode": "vim"` in [`settings.json`](./settings.json), so
  the prompt box has vim NORMAL/INSERT/VISUAL modes, motions, and text objects
  ([interactive-mode](https://code.claude.com/docs/en/interactive-mode#vim-editor-mode)). `Esc` in
  INSERT drops to NORMAL — it does **not** interrupt Claude (that's `Esc` at the app level). This stack
  also sets `"vimInsertModeRemaps": { "jk": "<Esc>" }`, so **`jk`** in INSERT drops to NORMAL without
  reaching for `Esc` (Claude Code ≥ 2.1.208; read from user settings only). Matches Neovim muscle
  memory across the stack.
- **Transcript viewer** (`Ctrl+O`) — the full tool-by-tool record; expands MCP calls that otherwise
  collapse to one line. `?` lists its own keys; inside it `v` opens the whole conversation in your
  `$EDITOR` (nvim), `[` dumps it to terminal scrollback for `Cmd+F` search, and `{`/`}` jump between
  your prompts ([interactive-mode](https://code.claude.com/docs/en/interactive-mode#transcript-viewer)).
- **Background work** — `Ctrl+B` pushes a long Bash command or agent to the background and hands you the
  prompt back; `/tasks` shows what's still running.
- **Side questions** (`/btw`) — ask a quick question without touching the conversation history; it sees
  the full session but has **no tools**, runs even while Claude is busy, and `f` forks it into a real
  session. The inverse of a subagent
  ([interactive-mode](https://code.claude.com/docs/en/interactive-mode#side-questions-with-btw)).
- **Paste an image** — `Ctrl+V` drops a screenshot / mockup / diagram straight into the prompt as an
  `[Image #N]` chip, so Claude can read an error shot or match a design
  ([common-workflows](https://code.claude.com/docs/en/common-workflows#work-with-images)).

---

## 7. Anti-patterns

| Don't | Do instead |
|---|---|
| Let Claude edit blind on a change you don't understand | `Shift+Tab` to **plan mode** first |
| Confirm every trivial edit by hand | `Shift+Tab` to **acceptEdits** |
| Paste a file's contents into the prompt | `@path` — it references the file directly |
| Copy a command's output back in by hand | `!command` — output enters context automatically |
| Let context creep to 100% then lose the thread | Watch `ctx %`, `/compact` early |
| Run two agents in the same working tree | A worktree each — `cc-worktree.sh` / `claude -w` |
| Fight a dead Claude `Ctrl`-key, or a dead Zellij hotkey | `Alt+d` toggles which layer gets the keys |
| Wire in the GitHub MCP because it exists | `gh` + the plugins already cover it ([§10](#10-settings-plugins--mcp)) |

---

## 8. Living in a Zellij pane

Claude Code is a TUI, so it runs in a **Zellij pane** next to Neovim — the [`dev`
layout](../zellij/layouts/dev.kdl): `zellij --layout dev` (left: editor · right, 40%: agent). Two
couplings make that cohabitation work — the exact behavior lives in the
[Zellij README §8](../zellij/README.md#8-living-with-claude-code--neovim--manual-lock):

- **`Alt+d` is the manual lock.** There's **no autolock** — you hand the pane its keys by choice. `Alt+d`
  drops Zellij into **Locked** mode so **every keystroke reaches Claude** (`Ctrl+o`/`t`/`r` and the rest);
  `Alt+d` again takes the multiplexer back. The trade-off is [§1](#1-the-mental-model)'s reflex: enter
  `claude` and its `Ctrl`-keys are eaten by Zellij until you press `Alt+d`.
- **`Ctrl+G` is freed in Zellij** — it's normally Locked mode's default unlock, which would shadow
  Claude's `Ctrl+G` (*edit prompt in `$EDITOR`*). The Zellij config unbinds it so the keystroke reaches
  Claude; leave Locked with `Alt+d` instead.

**Voice — why `Ctrl+F`, and hold-to-talk.** Voice dictation's push-to-talk key
([`voice:pushToTalk`](https://code.claude.com/docs/en/voice-dictation#rebind-the-dictation-key))
defaults to **`Space`**, and its default mode is **hold** (push-to-talk: record while held, send on
release). On a bare key like `Space`, hold detection leans on terminal key-repeat — a brief warmup,
and the first repeat chars type into the prompt before recording takes over. So this stack rebinds it in
[`keybindings.json`](./keybindings.json):

```json
{ "context": "Chat", "bindings": { "space": null, "ctrl+f": "voice:pushToTalk" } }
```

**`Ctrl+F`** — a modifier combo — starts recording on the *first* keypress, no warmup
([voice-dictation](https://code.claude.com/docs/en/voice-dictation#hold-to-record)). Binding it already
**replaces** the default `Space` trigger (`voice:pushToTalk` takes one key at a time), so `"space":
null` is kept only for clarity — omitting it changes nothing. The stack keeps the upstream **hold** mode
(`mode: "hold"` in [`settings.json`](./settings.json)): hold `Ctrl+F`, speak, release to insert. Voice
is on by default; the first `/voice` run asks for microphone permission. Rebinding is live — no restart
([keybindings](https://code.claude.com/docs/en/keybindings)).

---

## 9. The status line

[`statusline.sh`](./statusline.sh) reads Claude Code's session JSON on stdin and prints one line
([schema](https://code.claude.com/docs/en/statusline)):

```
Opus 4.8   terminal-stack   feat/x*   23% ctx   $0.04
   model        dir          git¹     context²    cost
```
¹ branch, `*` = uncommitted changes · ² context-window usage. Colours are the terminal's 16 ANSI slots
(no hardcoded palette), so the line follows the active theme — like the Starship prompt. The glyphs need
a Nerd Font (the stack assumes one). Falls back from `jq` to `grep` if `jq` is absent. Fields consumed: `.model.display_name`, `.workspace.current_dir`,
`.context_window.used_percentage`, `.cost.total_cost_usd`.

**Already enabled** — [`settings.json`](./settings.json) carries the `statusLine` block, so a fresh
install shows the line with no hand-editing. Test it:

```sh
echo '{"model":{"display_name":"Opus"},"workspace":{"current_dir":"'"$PWD"'"},"context_window":{"used_percentage":25},"cost":{"total_cost_usd":0.04}}' \
  | ./statusline.sh
```

---

## 10. Settings, plugins & MCP

[`settings.json`](./settings.json) is the whole user-facing config, linked to `~/.claude/settings.json`.
The *why* behind each key — the file states the *what*
([settings](https://code.claude.com/docs/en/settings)):

| Key | Value | Why |
|---|---|---|
| `statusLine` | `command` → `~/.claude/statusline.sh` | The model · dir · git · ctx% · cost line ([§9](#9-the-status-line)). |
| `editorMode` | `vim` | Vim motions in the prompt box — matches Neovim across the stack ([§6](#6-advanced-craft)). |
| `vimInsertModeRemaps` | `{ "jk": "<Esc>" }` | `jk` in INSERT → NORMAL, no reach for `Esc` (Claude Code ≥ 2.1.208; user-settings only) ([§6](#6-advanced-craft)). |
| `theme` | `auto` | Follows the OS light/dark appearance, like the rest of the stack. |
| `language` | `Русский` | Response **and voice-dictation** language ([voice-dictation](https://code.claude.com/docs/en/voice-dictation#change-the-dictation-language)). |
| `voice` | `enabled: true, mode: hold` | Push-to-talk voice, on by default — `hold` is upstream's default mode ([§8](#8-living-in-a-zellij-pane)). |
| `worktree.baseRef` | `head` | Native worktrees branch from *current* work, not the remote default ([§5](#5-parallel-agents--git-worktrees)). |
| `permissions.defaultMode` | `default` | Start with the brakes on — ask before edits ([permission-modes](https://code.claude.com/docs/en/permission-modes)). |
| `permissions.allow` | `WebFetch`, `WebSearch` | Pre-allow the two read-only web tools; everything else still prompts. |
| `enabledPlugins` | see below | Reinstall the stack's plugins on a fresh machine. |

**Plugins** — a trusted fresh machine reinstalls these from the **preloaded**
`claude-plugins-official` marketplace ([plugins](https://code.claude.com/docs/en/plugins)):

| Plugin | What it adds |
|---|---|
| `typescript-lsp` | TS/JS go-to-definition, find-references, post-edit diagnostics — a **plugin**, not an MCP, so it costs no MCP slot |
| `commit-commands` | `/commit`, `/push`, create-PR commands |
| `pr-review-toolkit` | PR-review agents / `/code-review` |
| `frontend-design` | Design-first skill for UI work — sets an aesthetic direction (typography, palette, motion) before generating React/Vue/Svelte/HTML, dodging generic "AI-slop" output |

**Why no GitHub MCP.** `gh` is already installed and authed ([`Brewfile`](../Brewfile)); for a fluent
`gh` user the GitHub MCP is heavier (more tokens, PR flakiness) for no gain. Git + GitHub run through
`gh` via the shell; the plugins above add the ergonomic slash-commands on top. Add the GitHub MCP only
if you later want typed cross-repo tooling.

**MCP servers.** [`mcp-setup.sh`](./mcp-setup.sh) registers two **user-scope** servers idempotently —
`install.sh` runs it best-effort (skipped if `claude` is absent), or run it yourself any time
([mcp](https://code.claude.com/docs/en/mcp)):

| Server | Auth | For |
|---|---|---|
| `notion` (`https://mcp.notion.com/mcp`) | **OAuth** — `/mcp → notion → Authenticate` once; token in the OS keychain | the SDD knowledge base |
| `context7` (`https://mcp.context7.com/mcp`) | **keyless** | up-to-date library docs in context |

Neither server puts a secret in the repo (this repo is **public**). For any *future* token-based server,
reference it as `${VAR}` in the MCP config and keep the real value in the git-ignored `~/.zshrc.local` —
never a committed file ([`config.md`](../.claude/rules/config.md) §Secrets). Don't also enable a
`notion` *plugin* — it would double the hosted MCP's tools.

---

## 11. Global rules — `rules/`

Each file in [`rules/`](./rules/) installs to `~/.claude/rules/<file>`, Claude Code's **user-level
rules** — loaded into every session, in every project ([memory](https://code.claude.com/docs/en/memory)).
A rule with **no `paths:` frontmatter loads always** (same priority as `~/.claude/CLAUDE.md`); add a
`paths:` glob list and it loads only when Claude touches matching files. Versioning rules here means a
fresh machine gets the same Claude behavior as the rest of the stack.

The first rule shipped is [`communication-style.md`](./rules/communication-style.md) — the persona's
**"dials"** (language, register, tone, lexicon).

- **Switch the style:** edit one dial line — e.g. `Тон → дружелюбно, на «ты»`, `Язык → English`,
  `Эмодзи → отключить`. The framework survives; only the value changes.
- **Add a rule:** drop a new `.md` in [`rules/`](./rules/) and re-run `./install.sh` — it links each
  file on its own (like `zsh/*.zsh`), so machine-local rules you keep directly in `~/.claude/rules/`
  coexist, and `./install.sh --prune` only ever removes *our* stale links. Keep each rule focused;
  prefer a new file over growing one past ~200 lines (the upstream size guidance).

---

## 12. Verify

- `bash -n claude/*.sh` — shell syntax clean (run by `/check` + CI).
- `jq . claude/settings.json` · `jq . claude/keybindings.json` — valid JSON.
- Status line renders from mock JSON (model · dir · git · ctx% · cost).
- Try the layout live in the sandbox: `make zellij`.

## 13. Install

`./install.sh` (or `make install`) symlinks `claude/` into `~/.claude/` and best-effort runs
`mcp-setup.sh`. Symlink `cc-worktree.sh` onto your `$PATH` separately ([§5](#5-parallel-agents--git-worktrees)).
Run `claude` once and log in ([overview](https://code.claude.com/docs/en/overview)).

### Go deeper

*(On demand — not front to back.)*

- Every keyboard shortcut, input mode, vim keys → [interactive-mode](https://code.claude.com/docs/en/interactive-mode)
- Full command list → [commands](https://code.claude.com/docs/en/commands) · CLI flags → [cli-reference](https://code.claude.com/docs/en/cli-reference)
- Permission modes & plan mode → [permission-modes](https://code.claude.com/docs/en/permission-modes)
- Rewind / checkpoints → [checkpointing](https://code.claude.com/docs/en/checkpointing)
- Memory & `CLAUDE.md` → [memory](https://code.claude.com/docs/en/memory) · Rebind keys → [keybindings](https://code.claude.com/docs/en/keybindings)
- Voice dictation → [voice-dictation](https://code.claude.com/docs/en/voice-dictation) · MCP → [mcp](https://code.claude.com/docs/en/mcp)

---

> Part of [terminal-stack](../README.md) · usage [guide](../docs/guide.md) · setup [install](../docs/install.md).

<!--
This README is the per-tool doc pattern: ONE file per tool, at <tool>/README.md (GitHub renders it, the
root README links it). To enrich another tool's README to this shape, follow the section order:
  1 mental model (the one load-bearing concept) · 2 quick-start "moves that pay rent" · 3 complete
  reference · 4 task-first recipes · 5 a domain multiplier (here: parallel-agent worktrees) · 6 advanced
  craft · 7 anti-patterns · 8+ integration/gotchas (here: the Zellij pane) · settings rationale ·
  verify/install · "go deeper" pointers.
Rules honored: cite every key/command upstream (config.md · never invent — code.claude.com is the
source); config says what, prose says why (claude-md.md); public repo → assume world-readable.
-->
