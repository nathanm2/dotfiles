-- Lazy.nvim is a modern plugin manager for Neovim.

-- Auto installation for Lazy.nvim:
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Options to Lazy.nvim:
local opts = {
  ui = {
     border = "rounded"
  },
}
-- Setup the "Lazy" plugin manager.
--
-- Instead of supplying a large table containing all the plugins, the "plugins" string causes Lazy
-- construct the table by loading everything in 'lua/plugins/*.lua'.
--
require("lazy").setup("plugins", opts)
