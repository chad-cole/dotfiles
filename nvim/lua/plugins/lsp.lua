return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        bashls = {},
        lua_ls = {},
        marksman = {},
        pyright = {},
        ruby_lsp = {},
        rust_analyzer = {},
        sorbet = {},
        tsserver = {},
        yamlls = {},
      },
      autoformat = false,
    },
  },
}
