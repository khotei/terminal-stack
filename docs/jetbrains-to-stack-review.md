# 🔍 JetBrains → terminal-stack: the code-review map

A migration map for a JetBrains/IntelliJ power user moving to this stack. It answers one question per
row: *I used to press X in the IDE — what do I do here?*

> **The mental shift.** In JetBrains you are the author and the IDE assists. Here the roles split:
> **editing** is delegated to **Claude Code** (a prompt, not a refactor hotkey), and your manual job
> is **reading, navigating, inspecting, and reviewing** code — including Claude's diffs. So invest
> muscle memory in the *navigation/inspection* rows below; the *refactor/run* rows are mostly "ask
> Claude".

> **Discover binds live.** which-key ships with LazyVim — press **`<Space>`** and wait to see every
> leader bind, or **`g`** to see the `g`-prefix motions. This sheet is the map; which-key is the GPS.

## Status legend

| Mark | Meaning |
|---|---|
| ✅ | **built-in** — works in stock LazyVim today |
| 🔵 | **needs an extra** — `lang.typescript` (F-EDIT-002) · `editor.inc-rename` (F-EDIT-003) · `editor.outline` / `dap.core` / `test.core` (F-EDIT-004) |
| 🧩 | **needs plugin** — diffview / dropbar / mini.surround (F-EDIT-002) |
| 🤖 | **→ Claude** — delegate to the agent in a Zellij pane |
| ⛔ | **no direct equivalent** — known gap |

---

## Inspection — read the code

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| Quick Documentation ⌥⇧D | `K` | Hover: docs + type + signature | 🔵 |
| Parameter Info ⌘P | `gK` | Signature help | 🔵 |
| Quick Definition ⌥D | `gd` | Goto definition (the snacks picker previews when there are several) | 🔵 |
| Quick Type Definition ⌥T | `gy` | Goto type definition | 🔵 |

## Navigation — move around

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| Recent Files ⌘E | `<leader>fr` | Recent files picker | ✅ |
| Recent Locations ⇧⌘E | `<C-o>` / `<C-i>` | Jump back / forward | ✅ |
| Search Everywhere | `<leader>ff` / `<leader>/` | Find files / grep (fd · ripgrep) | ✅ |
| Switcher | `<leader>,` | Open buffers | ✅ |
| Recent Locations (picker) | — | — | ⛔ |

## Usages — how code connects

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| Find / Show Usages ⌥⇧S | `gr` / `<leader>cS` | References (snacks list w/ preview · or the Trouble panel) | 🔵 |
| Next / Prev Highlighted Usage ⌃⌥↕ | `]]` / `[[` | Jump between references | 🔵 |
| Go to Implementation | `gI` | Implementations | 🔵 |
| Goto Source Definition | `gD` | Past type aliases to the source | 🔵 |
| File References | `gR` | References within the file | 🔵 |

## Structure — see the shape

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| File Structure ⌘F12 | `<leader>ss` | Document symbols picker (quick jump) | 🔵 |
| Structure panel ⌘7 | `<leader>cs` | outline.nvim pinned tree (follows cursor) | 🔵 |
| Problems / diagnostics | `<leader>xx` | Trouble diagnostics panel | ✅ |
| Context Info / Breadcrumbs ⌃⇧Q | — | dropbar winbar (symbol path at cursor) | 🧩 dropbar |
| Type Hierarchy ⌃H | — | — | ⛔ |

## Diff-review — review changes (incl. Claude's)

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| VCS diff | `<leader>gg` | lazygit (stage, hunks, history) | ✅ |
| Next / Prev change | `]h` / `[h` | Jump between git hunks (gitsigns) | ✅ |
| — | `<leader>ghp` | Preview hunk inline | ✅ |
| Side-by-side diff | `<leader>gv` | diffview: review all changes | 🧩 diffview |
| File history | `<leader>gV` / `<leader>gF` | diffview: repo / current-file history | 🧩 diffview |

## Refactor — mostly ask Claude

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| Rename ⇧F6 | `<leader>cr` | LSP rename with live preview (inc-rename) | 🔵 |
| Organize / Add imports | `<leader>co` / `<leader>cM` | Imports | 🔵 |
| Comment ⌘/ | `gcc` / `gc` | Toggle line / motion comment | ✅ |
| Surround With ⌃⌥T | `gsa` | Add surround (mini.surround) | 🧩 |
| Unwrap / Remove ⌃⌘T | `gsd` | Delete surround | 🧩 |
| Extract Method / Variable | — | Describe the extraction | 🤖 |
| Inline · Change Signature · Move | — | Describe the change | 🤖 |
| Extract Interface/Superclass · Pull Members Up | — | — | ⛔ |
| Safe Delete | — | — | ⛔ |

## Run / Debug — terminal-native or Claude

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| Run / Debug a script | `<C-/>` then `bun run …` | snacks terminal, or a Zellij pane | ✅ |
| Run configurations | — | A Zellij pane per long-running process | ✅ |
| Step debugger ⇧F9 | `<leader>db` · `<leader>dc` · `<leader>du` | Breakpoint · continue · dap-ui (nvim-dap; TS `js-debug` adapter auto-wired) | 🔵 |
| Test runner ⇧F10 | `<leader>tr` · `<leader>ts` · `<leader>tw` | Run nearest · summary · watch (neotest; vitest + jest) | 🔵 |

---

## Debugging your code

Debugging runs on **nvim-dap** (`<leader>d*`) with the `js-debug` adapter, wired for TS/JS by the
`lang.typescript` + `dap.core` extras. The loop: breakpoint `<leader>db` → start with `<leader>dc`
(shows a config picker) → step `<leader>di`/`dO`/`do` → inspect in the dap-ui panels (`<leader>du`).
Pick the row that matches what you're debugging:

| Debug target | How | Notes |
|---|---|---|
| **A test** (Vitest · Jest · @effect/vitest) | cursor in the test → `<leader>td` | neotest runs it under dap; @effect/vitest rides the Vitest path |
| **The current file** | `<leader>dc` → **Launch file** | from `lang.typescript`; runs `${file}` under node |
| **An npm / pnpm script** | `<leader>dc` → **Debug npm script** / **Debug pnpm script** → type the script | runs `npm`/`pnpm run <script>` under the debugger (added by this stack) |
| **A VS Code-style config** | drop `.vscode/launch.json` in the project | js-debug configs are auto-read — they show up in the `<leader>dc` picker, zero setup |
| **Anything already running** (any runtime/PM) | start it with `node --inspect-brk <entry>` in a Zellij pane → `<leader>dc` → **Attach** | the universal escape hatch when no launch config fits |

### How it works — the `--inspect` server ↔ client

Node ships its own debugger; there's **no extra utility to install**. Starting a process with
`--inspect` (or `--inspect-brk` to pause on line 1) raises an **Inspector** — a debug server on a
port (default `127.0.0.1:9229`) speaking the **Chrome DevTools Protocol (CDP)**. Any CDP client
attaches to it: nvim-dap's `js-debug`, a browser's `chrome://inspect`, or VS Code.

```
 node --inspect-brk app.js        ◀── CDP over WebSocket ──▶   nvim-dap + js-debug
   raises the Inspector @ :9229                                 (your "interface")
```

- **Launch** — the editor starts node for you (`Launch file`, `Debug npm script`); nothing to raise by hand.
- **Attach** — you raise the process with `--inspect`, the editor connects; the universal path.
- **Dev servers** (Next, Vite, Nest, …) are node underneath — run the dev script with the flag, then Attach:
  ```sh
  NODE_OPTIONS='--inspect' npm run dev    # in a Zellij pane → <leader>dc → Attach
  ```
- `js-debug` adds source-maps (TS→JS) and child-process auto-attach on top of raw CDP — which is why
  it beats `chrome://inspect` for real work. (Exception: **Bun**'s `--inspect` speaks the WebKit
  protocol, not CDP — see the Bun row below.)

### Reliability & prerequisites

- **Node must be on `PATH`.** The debugger launches `node`; the stack puts it there via fnm
  (`zsh/tools.zsh`), so a normal shell is fine. If Neovim was started without the shell env, run
  `fnm use default` first.
- **"Green" ≠ "works".** `/check` and a headless load only prove the dap config *parses and
  registers* — a debug session is proven **only when a breakpoint is actually hit**. Verify
  interactively, not from validators.
- **If `<leader>dc` fails with `ECONNREFUSED 127.0.0.1:<port>`** — that's a known `js-debug` handshake
  flake ([LazyVim #5913](https://github.com/LazyVim/LazyVim/issues/5913)), not your config.
  Terminate (`<leader>dt`) and start again (`<leader>dc`); it usually connects on the retry.

### Known gaps & workarounds

- **Node's built-in runner (`node:test` / `node --test`)** — no mature neotest adapter, so no
  `<leader>td`. Run it in a Zellij pane (`node --test`), or use **Vitest** for suites you want to
  debug in-editor. To step through: `node --inspect-brk --test <file>` in a pane → **Attach**.
- **Bun (`bun test` / `bun run`)** — not debuggable from nvim today: Bun speaks the WebKit inspector
  protocol, not the V8/CDP one `js-debug` uses, and Bun isn't in this stack. Run it in a Zellij pane
  (`bun test`); for stepping, `bun --inspect` opens **Bun's own web debugger** in the browser; or run
  the code under **node** and use the rows above. (Revisit if Bun lands in the stack as a runtime.)

The in-editor debugger covers the well-supported path (node/TS, Vitest/Jest); the rest goes to a fast
terminal pane rather than a half-working plugin.

## Known gaps (⛔)

- **Type Hierarchy** and a **Recent-Locations picker** have no out-of-box equivalent. The jumplist
  (`<C-o>`/`<C-i>`) covers most of Recent Locations in practice.
- **Step debugging** (`nvim-dap`) and **test running** (`neotest`) are now wired in (F-EDIT-004) —
  debug under `<leader>d*`, tests under `<leader>t*`. Editing still defaults to Claude; these are for
  when you want the interactive IDE loop.

## See also

- The narrative migration rationale (with upstream citations) lives in the Notion Research page for
  feature `F-EDIT-002`.
- The stack's cross-tool workflow guide: [guide.md](guide.md) — it ties the layers together; the
  exhaustive keys per tool live in each layer's README. Editor specifics: [nvim/README.md](../nvim/README.md);
  lazygit & yazi keys: [zsh/README.md](../zsh/README.md#512-lazygit--git-as-a-tui).
