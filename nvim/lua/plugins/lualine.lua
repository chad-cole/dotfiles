local git_blame = require("gitblame")

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "f-person/git-blame.nvim" },
		event = "VeryLazy",
		opts = {
			sections = {
				lualine_x = {
					{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
				},
			},
			settings = {},
		},
	},
}
