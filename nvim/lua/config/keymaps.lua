-- Keymaps are automatically loaded on the VeryLazy event
-- Default LazyVim keymaps:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here.
--
-- The leader is <Space> (LazyVim default). Discover everything with which-key:
-- press <Space> and wait. This file is the ONE place to port IdeaVim habits to
-- — keep editor maps here so collisions with the Zellij prefix (ctrl+a) and
-- Ghostty stay easy to audit (see ../../.claude/rules/config.md).

local map = vim.keymap.set

-- `jk` to leave insert mode — a near-universal Vim comfort bind, no collision.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- `<leader>E` focuses the neo-tree sidebar from any split (and a second press
-- hops back via `<C-w>p`) — stock `<leader>e` only toggles it closed, never
-- focuses. Overrides LazyVim's `<leader>E` (cwd explorer → stays on `<leader>fE`).
map("n", "<leader>E", function()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd.wincmd("p")
  else
    vim.cmd("Neotree focus")
  end
end, { desc = "Explorer (focus ⇄ back)" })

-- Force-reload every buffer from disk after an agent rewrote files (`:bufdo e!`).
-- It DISCARDS unsaved edits — the deliberate nuke for when the filesystem should
-- win. The safe path that keeps your edits is `:checktime` (auto-runs on
-- FocusGained; see nvim/README §13), so it earns no key. Capital R mirrors
-- LazyVim's bd/bD convention (capital = more forceful). Lands in which-key under
-- <leader>b via its desc — no separate which-key spec needed.
map("n", "<leader>bR", function()
  local cur = vim.api.nvim_get_current_buf()
  vim.cmd("bufdo silent! edit!")
  pcall(vim.api.nvim_set_current_buf, cur)
end, { desc = "Reload ALL buffers from disk (discard edits)" })
