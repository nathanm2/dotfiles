-- Neovim Configuration

-- Source our common vim/nvim config.
--
-- Stuff that is common between vim/nvim should go into this file.
local config_dir = vim.fn.stdpath("config")
local vimrc = config_dir .. "/vimrc-common.vim"
vim.cmd.source(vimrc)

----- Key Maps ----- 

local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

-- Make it easier to edit the vim config files:
keymap("n", "<Leader>en", ":edit $MYVIMRC<CR>", term_opts)
keymap("n", "<Leader>ev", string.format(":edit %s<CR>", vimrc), term_opts)
keymap("n", "<Leader>ep", string.format(":edit %s<CR>",
       config_dir .. "/lua/user/plugins.lua"), term_opts)
-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)


----- Neovide -----

-- Set the GUI font:
vim.opt.guifont = "DejaVuSansMono Nerd Font Mono:h11"

----- Plugins -----

require "user.plugins"

-- Force the "signcolumn" to stay open.
--
-- Otherwise it causes the buffer to shift to the right when we're editing.
vim.opt.signcolumn = "yes"

local lspconfig = require("lspconfig")
lspconfig.rust_analyzer.setup {}
lspconfig.pylsp.setup{}
