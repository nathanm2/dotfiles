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

-- carbonfox tweaks
local carbonfox_opts = {
  groups = {
    carbonfox = {
      Comment = { fg = "#6A9955" },
      String = { fg = "#CE9178" },
      StatusLine = { fg = "#E0E0E0", bg = "#37373D" },
      StatusLineNC = { bg = "#252526" },
    }
  },
}
  
-- The plugins:
local plugins = {

  -- Popular color schemes:
  { "EdenEast/nightfox.nvim", -- carbonfox
    priority = 1000,
    lazy = false,
    opts = carbonfox_opts,
    config = function(plugin, opts)
      require("nightfox").setup(opts)
      -- load the colorscheme here
      vim.cmd([[colorscheme carbonfox]])
      end,
  },
  { "rebelot/kanagawa.nvim", lazy = true}, -- kanagawa-lotus
  { "folke/tokyonight.nvim", lazy = true},
  { "catppuccin/nvim", lazy = true}, -- catppuccin
  { "morhetz/gruvbox"},
  
  -- LSP Plugins:

  -- Installs and manages LSP servers, debuggers, linters, etc.
  --[[{ "williamboman/mason.nvim",
    build = ":MasonUpdate" -- :MasonUpdate updates registry contents
  },
  --]]

  -- Bridges the `mason.nvim` with the `lspconfig` plugin.
  -- { "williamboman/mason-lspconfig.nvim" },

  -- Configs for the LSP client.
  { "neovim/nvim-lspconfig" },
}

-- Options to Lazy:
local opts = {
  ui = {
     border = "rounded"
  },
}
-- Setup the "Lazy" plugin manager:
require("lazy").setup(plugins, opts)

-- Returns the palette of the specified colorscheme
-- local palette = require('nightfox.spec').load("carbonfox")
-- print(vim.inspect(palette))
