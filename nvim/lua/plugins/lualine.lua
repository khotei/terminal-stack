-- Two letters where the first alone would merge modes (V-LINE and V-BLOCK into VISUAL's V).
local short = {
  ["O-PENDING"] = "O",
  ["V-LINE"] = "VL",
  ["V-BLOCK"] = "VB",
  ["S-LINE"] = "SL",
  ["S-BLOCK"] = "SB",
  ["V-REPLACE"] = "VR",
}

-- Slot numbers, not hex: lualine passes a number through as a cterm colour, so the bar
-- follows Ghostty's palette (plugins/colorscheme.lua). `auto` would read the scheme's
-- 24-bit colours and round them to fixed 256-colour cells that never flip.
-- The mode block is the slot reversed — the text takes the terminal background.
local function mode(slot)
  return { a = { fg = slot, gui = "reverse,bold" }, b = { fg = slot }, c = {} }
end
local dim = { fg = 8 }
local theme = {
  normal = mode(4),
  insert = mode(2),
  visual = mode(5),
  replace = mode(1),
  command = mode(3),
  terminal = mode(6),
  inactive = { a = dim, b = dim, c = dim },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local icons = LazyVim.config.icons
      opts.options.theme = theme
      -- Section arrows are drawn from the neighbours' backgrounds, and here there are none.
      opts.options.section_separators = ""
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
        LazyVim.lualine.root_dir({ color = { fg = 6 } }),
        {
          "diagnostics",
          diagnostics_color = {
            error = { fg = 1 },
            warn = { fg = 3 },
            info = { fg = 6 },
            hint = { fg = 4 },
          },
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
      }
      for _, component in ipairs(opts.sections.lualine_x) do
        if component[1] == "diff" then
          component.diff_color = { added = { fg = 2 }, modified = { fg = 3 }, removed = { fg = 1 } }
        end
      end
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
