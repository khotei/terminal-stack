-- dropbar.nvim — IDE-style breadcrumb winbar (JetBrains "Context Info"): the
-- symbol path at the cursor, from LSP + treesitter. Passive/display-only — it
-- self-defers via its own plugin/dropbar.lua and only attaches the winbar where
-- a parser/LSP is present, so no lazy-load event and no keymap are needed.
-- Requires Neovim >= 0.11 (the stack satisfies this). https://github.com/Bekaboo/dropbar.nvim
return {
  {
    "Bekaboo/dropbar.nvim",
    opts = function()
      local configs = require("dropbar.configs")
      local default_enable = configs.opts.bar.enable
      return {
        bar = {
          -- dropbar has no option to add text after its own, so this sets the winbar itself
          -- where dropbar would attach, with the cursor's line:col/total flush right.
          enable = function(buf, win, info)
            if configs.eval(default_enable, buf, win, info) then
              vim.wo[win][0].winbar = "%{%v:lua.dropbar()%}%=%l:%v/%L "
            end
            return false
          end,
        },
      }
    end,
  },
}
