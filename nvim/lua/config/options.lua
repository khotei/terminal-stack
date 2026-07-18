-- Options are automatically loaded before lazy.nvim startup
-- Default LazyVim options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here.

local opt = vim.opt

opt.number = false -- off by default; toggle on demand with <leader>ul / uL
opt.relativenumber = false -- both number columns off; LazyVim turns both on by default
opt.wrap = true -- soft-wrap long lines by default; LazyVim ships it off
opt.showtabline = 0 -- hide the bufferline tab-bar; toggle on demand with <leader>uA
opt.scrolloff = 8 -- keep cursor 8 lines from the screen edge
opt.confirm = true -- ask to save instead of failing on :q with unsaved changes
