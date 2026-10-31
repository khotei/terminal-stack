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
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(str)
            return short[str] or str:sub(1, 1)
          end,
        },
      }
    end,
  },
}
