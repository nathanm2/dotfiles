function config(plugin, opts)
  -- Force the "signcolumn" to stay open.
  --
  -- Otherwise it causes the buffer to shift to the right when we're editing.
  vim.opt.signcolumn = "yes"

  local lspconfig = require("lspconfig")
  lspconfig.rust_analyzer.setup {}
  lspconfig.pylsp.setup{}
  lspconfig.clangd.setup{}
end

return {
  { "neovim/nvim-lspconfig",
    lazy=false,
    config = config,
  }
}
