-- No colorscheme of our own: Neovim's built-in `default` scheme drawn in the terminal's
-- 16 ANSI slots (notermguicolors, config/options.lua), so Ghostty's light/dark flip
-- repaints the editor. Neovim reads the terminal background only at startup, hence
-- auto-dark-mode — with no callbacks it just flips 'background' to match macOS.
--
-- In 16 colours `default` leaves much in the text colour, and plugins that only define
-- 24-bit colours lose theirs, so the groups below get slot numbers — never hex, so
-- Ghostty still picks the shade. Slots in GitHub HC: 1 red · 2 green · 3 yellow ·
-- 4 blue · 5 purple · 6 cyan · 8 grey (grey in both palettes; 7 and 15 are not).

local dim = { ctermfg = 8 }
local hint = { ctermfg = 8, italic = true }
-- A fill is a slot reversed: no slot is the background in both palettes (slot 0 is
-- grey in dark, not black), so the text takes the terminal's own background instead.
local function fill(slot, extra)
  return vim.tbl_extend("force", { ctermfg = slot, reverse = true }, extra or {})
end

local groups = {
  -- syntax that `default` leaves in the text colour
  Comment = dim,
  Statement = { ctermfg = 1 },
  PreProc = { ctermfg = 1 },
  String = { ctermfg = 4 },
  Constant = { ctermfg = 4 },
  Function = { ctermfg = 5 },
  Type = { ctermfg = 3 },
  Title = { ctermfg = 4, bold = true },
  ["@markup.heading"] = { ctermfg = 4, bold = true },
  Todo = { ctermfg = 5, bold = true },
  ["@comment.todo"] = { ctermfg = 5, bold = true },

  -- text that is not source: grey, so a hint never reads as code
  NonText = dim,
  Whitespace = dim,
  EndOfBuffer = dim,
  LineNr = dim,
  LineNrAbove = dim,
  LineNrBelow = dim,
  FoldColumn = dim,
  Folded = hint,
  Conceal = dim,
  WinSeparator = dim,
  FloatBorder = dim,
  FloatTitle = { ctermfg = 4, bold = true },
  LspInlayHint = hint,
  LspCodeLens = hint,
  LspCodeLensSeparator = dim,
  ComplHint = hint,
  GitSignsCurrentLineBlame = hint,

  -- fills `default` paints with slot 0/15 as black/white
  Visual = fill(8),
  VisualNOS = fill(8),
  CursorLine = fill(8), -- list selection (pickers, explorer); the editor runs nocursorline
  SnacksPickerListCursorLine = fill(8),
  Pmenu = fill(8),
  PmenuKind = fill(8),
  PmenuExtra = fill(8),
  PmenuSbar = fill(8),
  PmenuSel = fill(4, { bold = true }),
  PmenuThumb = fill(4),
  Search = fill(3),
  Substitute = fill(3),
  IncSearch = fill(5, { bold = true }),
  CurSearch = fill(5, { bold = true }),
  Error = fill(1),
  DiffAdd = { ctermfg = 2 },
  DiffChange = { ctermfg = 3 },
  DiffDelete = { ctermfg = 1 },
  DiffText = fill(3),
  LspReferenceText = { underline = true },
  LspReferenceRead = { underline = true },
  LspReferenceWrite = { underline = true },
  LspReferenceTarget = { underline = true },
  LspSignatureActiveParameter = { ctermfg = 4, bold = true, underline = true },
  SnippetTabstop = { underline = true },
  SnippetTabstopActive = { underline = true },

  -- plugins that only define 24-bit colours
  DropBarIconKindArray = { ctermfg = 6 },
  DropBarIconKindList = { ctermfg = 6 },
  DropBarIconKindOperator = { ctermfg = 6 },
  DropBarIconKindSection = { ctermfg = 6 },
  DropBarMenuNormalFloat = { link = "NormalFloat" },
  DropBarMenuFloatBorder = { link = "FloatBorder" },
  DropBarMenuSbar = { link = "PmenuSbar" },
  DropBarMenuThumb = { link = "PmenuThumb" },
  GlanceListCursorLine = fill(8),
  GlancePreviewMatch = fill(3),
  GlanceListFilepath = dim,
  GlanceWinBarFilepath = dim,
  GlanceWinBarFilename = { bold = true },
  GlanceWinBarTitle = { ctermfg = 4, bold = true },
  GlanceIndent = dim,
  GlanceFoldIcon = dim,
  GlancePreviewLineNr = dim,
  GlanceBorderTop = dim,
  GlanceListBorderBottom = dim,
  GlancePreviewBorderBottom = dim,
  DiffviewCursorLine = fill(8),
  DiffviewFilePanelTitle = { ctermfg = 4, bold = true },
  DiffviewFilePanelRootPath = { ctermfg = 5, bold = true },
  DiffviewFilePanelCounter = { ctermfg = 3 },
  DiffviewPrimary = { ctermfg = 4 },
  DiffviewSecondary = { ctermfg = 6 },
  DiffviewDim1 = dim,
  DiffviewNonText = dim,
  DiffviewEndOfBuffer = dim,
  DiffviewWinSeparator = dim,
  DiffviewDiffAddAsDelete = { ctermfg = 1 },
  DiffviewDiffChange = { ctermfg = 3 },
  RenderMarkdownBullet = dim,
  RenderMarkdownDash = dim,
  RenderMarkdownIndent = dim,
  RenderMarkdownSign = dim,
  RenderMarkdownCodeBorder = dim,
  RenderMarkdownTableRow = dim,
  RenderMarkdownTableHead = { ctermfg = 4, bold = true },
  NeotestExpandMarker = dim,
  NeotestIndent = dim,
  NeotestMarked = { ctermfg = 3, bold = true },
  GrugFarResultsLineNr = dim,
  GrugFarResultsColumnNr = dim,
  GrugFarResultsNumbersSeparator = dim,
  GrugFarInputLabel = { ctermfg = 4 },
  GrugFarHelpWinHeader = { ctermfg = 4, bold = true },
  GrugFarHelpWinActionPrefix = { ctermfg = 3 },
  GrugFarResultsAddIndicator = { ctermfg = 2 },
  GrugFarResultsChangeIndicator = { ctermfg = 3 },
  GrugFarResultsRemoveIndicator = { ctermfg = 1 },
  GrugFarResultsDiffSeparatorIndicator = dim,
  GitSignsDiffStaged = dim,
  BlinkCmpDocBorder = dim,
  BlinkCmpDocSeparator = dim,
  BlinkCmpSignatureHelpBorder = dim,
  SnacksPickerDelim = dim,
  SnacksPickerIconArray = { ctermfg = 6 },
  SnacksPickerIconField = { ctermfg = 6 },
  SnacksPickerIconOperator = { ctermfg = 6 },
  SnacksPickerIconVariable = { ctermfg = 6 },
}

-- todo-comments: one colour per keyword, as its defaults pair them with diagnostics.
local todo = { FIX = 1, TODO = 4, HACK = 3, WARN = 3, PERF = 5, NOTE = 6, TEST = 5 }

-- Families a plugin derives per kind; matched by name so a new kind is covered too.
local families = {
  { "^GitSignsStaged", dim }, -- staged hunks: a dimmed copy of the unstaged signs
  { "^DropBarIconKind.*NC$", dim }, -- the winbar of an unfocused window
  { "^Trouble.*Pos$", dim },
  { "^TroubleIndent", dim },
  { "^TroubleIcon", { ctermfg = 6 } },
}
for keyword, slot in pairs(todo) do
  table.insert(families, { "^TodoFg" .. keyword .. "$", { ctermfg = slot, bold = true } })
  table.insert(families, { "^TodoBg" .. keyword .. "$", fill(slot, { bold = true }) })
  table.insert(families, { "^TodoSign" .. keyword .. "$", { ctermfg = slot } })
end

local function apply()
  for name in pairs(vim.api.nvim_get_hl(0, {})) do
    for _, family in ipairs(families) do
      if name:match(family[1]) then
        vim.api.nvim_set_hl(0, name, family[2])
      end
    end
  end
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

-- Scheduled, so it lands after the plugins' own ColorScheme handlers; re-run as each
-- plugin lazy-loads, since a plugin defines its groups only when it loads.
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "default", callback = vim.schedule_wrap(apply) })
vim.api.nvim_create_autocmd("User", { pattern = "LazyLoad", callback = vim.schedule_wrap(apply) })

return {
  { "LazyVim/LazyVim", opts = { colorscheme = "default" } },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
  { "f-person/auto-dark-mode.nvim", lazy = false, priority = 1000, opts = {} },
}
