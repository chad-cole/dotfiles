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
		},
	},
	-- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
	-- treesitter, mason and typescript.nvim. So instead of the above, you can use:
	{ import = "lazyvim.plugins.extras.lang.typescript" },
}
