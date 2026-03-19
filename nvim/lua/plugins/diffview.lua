return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{ "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
		{ "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff file history" },
		{ "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diff view close" },
		{ "<leader>dl", "<cmd>DiffviewOpen HEAD~1..HEAD<cr>", desc = "Diff last commit" },
	},
	opts = {
		keymaps = {
			disable_defaults = false,
			view = {
				{ "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_panel = {
				{ "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_history_panel = {
				{ "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
		},
		hooks = {
			view_opened = function()
				vim.api.nvim_create_autocmd("BufEnter", {
					pattern = "diffview://*",
					callback = function(ev)
						pcall(vim.api.nvim_buf_create_user_command, ev.buf, "q", "DiffviewClose", {})
					end,
				})
			end,
		},
	},
}
