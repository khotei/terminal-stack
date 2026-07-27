-- diffview.nvim — side-by-side diff + per-file history, for reviewing changes
-- (especially Claude Code's). `--imply-local` (default arg) puts the working-tree
-- file on the diff's RIGHT side, so LSP (gd/gr/diagnostics) works INSIDE the review,
-- not only after jumping to the real file. Ships no global keymaps, so we supply the
-- entry keys under the <leader>g git namespace. See ../../docs/working-with-agents.md.
-- https://github.com/sindrets/diffview.nvim

-- <leader>gm opens Snacks' git_log (commits) picker; two ctrl keys open the highlighted
-- commit in diffview, sitting alongside the picker's own <c-d> (git diff) / <c-y> (copy)
-- hints (press `?` in any picker for the full key list):
--   <c-o> = the commit's OWN change (sha^! = commit vs its parent) — what lazygit shows.
--   <c-x> = working tree vs the commit (sha).  --imply-local comes from default_args below.
-- Enter is left as the picker default; these keys never check the commit out.
local function open_commit_diff(rev)
  return function(picker, item)
    picker:close()
    if item and item.commit then
      vim.schedule(function()
        vim.cmd("DiffviewOpen " .. rev(item.commit))
      end)
    end
  end
end

local function pick_commit_diff()
  Snacks.picker.git_log({
    win = {
      input = {
        keys = {
          ["<c-o>"] = { "diffview_change", mode = { "n", "i" }, desc = "diffview: commit's change" },
          ["<c-x>"] = { "diffview_current", mode = { "n", "i" }, desc = "diffview: vs current" },
        },
      },
    },
    actions = {
      diffview_change = open_commit_diff(function(sha)
        return sha .. "^!"
      end),
      diffview_current = open_commit_diff(function(sha)
        return sha
      end),
    },
  })
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff: working tree (review)" },
      -- gM = the quick direct review vs main; gm = the richer commit picker (lowercase =
      -- the more-used entry). See open_commit_diff above for the picker's <c-o>/<c-x> keys.
      { "<leader>gM", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff: branch vs main (review)" },
      { "<leader>gm", pick_commit_diff, desc = "Diff: commits picker (<c-o>/<c-x> → diffview)" },
      -- History on gV/gF, NOT gh/gH: <leader>gh is gitsigns' hunks-group prefix, so a
      -- standalone <leader>gh binding shadows it (which-key stalls on timeout). gf is taken
      -- by LazyVim (git_log_file), so the current-file view uses gF.
      { "<leader>gV", "<cmd>DiffviewFileHistory<cr>", desc = "Diff: repo history" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: current file history" },
    },
    opts = { default_args = { DiffviewOpen = { "--imply-local" } } },
  },
}
