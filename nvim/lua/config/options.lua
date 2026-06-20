-- Options are automatically loaded before lazy.nvim startup
-- Default LazyVim options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here.

local opt = vim.opt

opt.relativenumber = true -- relative line numbers for fast j/k motions
opt.scrolloff = 8 -- keep cursor 8 lines from the screen edge
opt.confirm = true -- ask to save instead of failing on :q with unsaved changes
