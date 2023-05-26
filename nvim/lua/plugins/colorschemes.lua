-- Carbonfox (color scheme) tweaks:
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

return {
  -- Color schemes --
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
  { "catppuccin/nvim", lazy = true}, -- catppuccin-mocha
  { "morhetz/gruvbox"},
  { "Mofiqul/vscode.nvim", lazy = false },
}
