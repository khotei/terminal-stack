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

-- Reload buffers from disk after an agent rewrote files — a safe/force pair,
-- lowercase vs capital per LazyVim's bd/bD convention. Both surface in which-key
-- under <leader>b via their desc (no separate which-key spec needed).
--   bu — :checktime: re-read outside-changed buffers but SPARE any holding your
--     unsaved edits (W12 warns instead of clobbering). Also auto-runs on
--     FocusGained (nvim/README §13); the key is for refreshing without a focus
--     switch.
--   bU — :bufdo e!: force every buffer to re-read from disk, DISCARDING unsaved
--     edits — the deliberate nuke for when the filesystem should win. Restores
--     the current buffer afterwards (bufdo leaves you on the last one).
map("n", "<leader>bu", "<Cmd>checktime<CR>", { desc = "Refresh buffers from disk (keep edits)" })
map("n", "<leader>bU", function()
  local cur = vim.api.nvim_get_current_buf()
  vim.cmd("bufdo silent! edit!")
  pcall(vim.api.nvim_set_current_buf, cur)
end, { desc = "Reload ALL buffers from disk (discard edits)" })
