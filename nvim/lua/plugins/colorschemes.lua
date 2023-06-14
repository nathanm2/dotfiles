-- Carbonfox (color scheme) tweaks:
local carbonfox_opts = {
  groups = {
    carbonfox = {
      Comment = { fg = "#6A9955" },
      String = { fg = "#CE9178" },
      StatusLine = { fg = "#E0E0E0", bg = "#37373D" },
      StatusLineNC = { bg = "#252526" },
      VertSplit = { fg = "#7B7C7E", bg = "#252526" },
    }
  },
}

function carbonfox_config(plugin, opts)
  require("nightfox").setup(opts)
  -- load the colorscheme here
  vim.cmd([[colorscheme carbonfox]])
end

function gruvbox_config(plugin, opts)
  require("gruvbox").setup(opts)
  -- load the colorscheme here
  vim.cmd([[colorscheme gruvbox]])
end

return {
  -- Color schemes --
  { "EdenEast/nightfox.nvim", -- carbonfox
    lazy = true,
    opts = carbonfox_opts,
    -- config = carbonfox_config
  },
  { "rebelot/kanagawa.nvim", lazy = true}, -- kanagawa-lotus
  { "folke/tokyonight.nvim", lazy = true},
  { "catppuccin/nvim", lazy = true}, -- catppuccin-mocha
  { "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = gruvbox_config,
  },
  { "Mofiqul/vscode.nvim", lazy = false },
}
