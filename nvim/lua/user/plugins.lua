-- Lazy.nvim is a modern plugin manager for Neovim.


-- Auto-install lazy.nvim:
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

-- The plugins:
local plugins = {
 -- Popular color schemes:
 { "martinsione/darkplus.nvim", lazy = true },
 { "EdenEast/nightfox.nvim", lazy = true},
 { "folke/tokyonight.nvim",
   priority = 1000,
   lazy = false,
   config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
   },
}

local opts = {
  ui = {
     border = "rounded"
  },
}
-- Perform the setup:
require("lazy").setup(plugins, opts)
