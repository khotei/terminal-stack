-- dropbar.nvim — IDE-style breadcrumb winbar (JetBrains "Context Info"): the
-- symbol path at the cursor, from LSP + treesitter. It only attaches the winbar
-- where a parser/LSP is present; <leader>; opens a crumb's menu from the keyboard.
-- Requires Neovim >= 0.11 (the stack satisfies this). https://github.com/Bekaboo/dropbar.nvim
return {
  {
    "Bekaboo/dropbar.nvim",
    -- `keys` alone makes lazy.nvim defer the plugin, and the winbar would stay empty until the key.
    lazy = false,
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick Breadcrumb",
      },
    },
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
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>;", icon = { icon = "󰙅 ", color = "azure" } },
      },
    },
  },
}
