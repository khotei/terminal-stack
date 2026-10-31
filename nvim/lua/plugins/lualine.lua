-- Two letters where the first alone would merge modes (V-LINE and V-BLOCK into VISUAL's V).
local short = {
  ["O-PENDING"] = "O",
  ["V-LINE"] = "VL",
  ["V-BLOCK"] = "VB",
  ["S-LINE"] = "SL",
  ["S-BLOCK"] = "SB",
  ["V-REPLACE"] = "VR",
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local icons = LazyVim.config.icons
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(str)
            return short[str] or str:sub(1, 1)
          end,
        },
      }
      -- No file path or symbol here: the dropbar winbar shows both (lua/plugins/dropbar.lua).
      opts.sections.lualine_c = {
        LazyVim.lualine.root_dir(),
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
      }
      -- vim-wakatime adds today's coding time itself; the marker stops that copy, so this
      -- one carries the hourglass icon (nf-md-timer_sand).
      table.insert(opts.sections.lualine_x, 1, {
        function()
          return "\u{f051f}  " .. require("wakatime").statusline()
        end,
        cond = function()
          return package.loaded["wakatime"] ~= nil and require("wakatime").statusline() ~= ""
        end,
        __wakatime_statusline = true,
      })
      -- The cursor position moved to the winbar (lua/plugins/dropbar.lua).
      opts.sections.lualine_y = {}
      opts.sections.lualine_z = {
        function()
          -- Two spaces: Ghostty draws an icon followed by a space over two cells, so the
          -- first space goes to the icon and the second stays a gap.
          return "\u{f43a}  " .. os.date("%R")
        end,
      }
    end,
  },
}
