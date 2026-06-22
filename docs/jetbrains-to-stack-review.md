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
| 🔵 | **needs TS-extra** — lit up by `lang.typescript` (F-EDIT-002) |
| 🧩 | **needs plugin** — added by F-EDIT-002 (diffview / glance / dropbar / mini.surround) |
| 🤖 | **→ Claude** — delegate to the agent in a Zellij pane |
| ⛔ | **no direct equivalent** — known gap |

---

## Inspection — read the code

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| Quick Documentation ⌥⇧D | `K` | Hover: docs + type + signature | 🔵 |
| Parameter Info ⌘P | `gK` | Signature help | 🔵 |
| Quick Definition ⌥D | `gpd` | Peek definition (popup) | 🧩 glance |
| Quick Type Definition ⌥T | `gy` / `gpt` | Goto / peek type definition | 🔵 / 🧩 |

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
| Find / Show Usages ⌥⇧S | `gr` / `gpr` | References (list / peek) | 🔵 / 🧩 |
| Next / Prev Highlighted Usage ⌃⌥↕ | `]]` / `[[` | Jump between references | 🔵 |
| Go to Implementation | `gI` / `gpi` | Implementations (goto / peek) | 🔵 / 🧩 |
| Goto Source Definition | `gD` | Past type aliases to the source | 🔵 |
| File References | `gR` | References within the file | 🔵 |

## Structure — see the shape

| JetBrains | Keys | Action | Status |
|---|---|---|---|
| File Structure ⌘F12 | `<leader>ss` | Document symbols picker | 🔵 |
| Structure + diagnostics | `<leader>cs` / `<leader>xx` | Symbols / Trouble panel | ✅ |
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
| Rename ⇧F6 | `<leader>cr` | LSP rename | 🔵 |
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
| Step debugger | — | `nvim-dap` (not installed — out of scope) | ⛔ |
| Test runner | — | `neotest` (not installed — out of scope) | ⛔ |

---

## Known gaps (⛔)

- **Type Hierarchy** and a **Recent-Locations picker** have no out-of-box equivalent. The jumplist
  (`<C-o>`/`<C-i>`) covers most of Recent Locations in practice.
- **Step debugging** (`nvim-dap`) and **test running** (`neotest`) are deliberately out of scope —
  editing/running is delegated to Claude. Candidate future features.

## See also

- The narrative migration rationale (with upstream citations) lives in the Notion Research page for
  feature `F-EDIT-002`.
- The stack's general cheat sheets: [guide.md](guide.md). Editor specifics: [nvim/README.md](../nvim/README.md).
