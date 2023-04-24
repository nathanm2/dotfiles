
-- Source our common vim/nvim config:
local vimrc = vim.fn.stdpath("config") .. "/vimrc-common.vim"
vim.cmd.source(vimrc)

require "user.keymaps"
require "user.plugins"
