-- Neovim Configuration

-- Source our common vim/nvim config.
--
-- For config options that you'd like to keep common between vim/nvim:
local config_dir = vim.fn.stdpath("config")
local vimrc = config_dir .. "/vimrc-common.vim"
vim.cmd.source(vimrc)

----- Key Maps ----- 

-- Make it easier to edit the keymappings:
local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap
keymap("n", "<Leader>on", ":edit $MYVIMRC<CR>", term_opts)
keymap("n", "<Leader>ov", string.format(":edit %s<CR>", vimrc), term_opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Neovide --

-- Set the GUI font:
vim.opt.guifont = "DejaVuSansMono Nerd Font Mono:h11"
-- vim.opt.guifont = "DroidSansM Nerd Font Mono:h11"

-- Plugins --
require("user.lazy")
