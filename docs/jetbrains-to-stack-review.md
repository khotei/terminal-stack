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
| File history | `<leader>gh` / `<leader>gH` | diffview: cwd / current-file history | 🧩 diffview |

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

## Known gaps (⛔)

- **Type Hierarchy** and a **Recent-Locations picker** have no out-of-box equivalent. The jumplist
  (`<C-o>`/`<C-i>`) covers most of Recent Locations in practice.
- **Step debugging** (`nvim-dap`) and **test running** (`neotest`) are now wired in (F-EDIT-004) —
  debug under `<leader>d*`, tests under `<leader>t*`. Editing still defaults to Claude; these are for
  when you want the interactive IDE loop.

## See also

- The narrative migration rationale (with upstream citations) lives in the Notion Research page for
  feature `F-EDIT-002`.
- The stack's general cheat sheets: [guide.md](guide.md). Editor specifics: [nvim/README.md](../nvim/README.md).
