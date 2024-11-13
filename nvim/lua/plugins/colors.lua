return {
	"savq/melange-nvim",
	as = "melange",
	config = function()
		vim.cmd.colorscheme("melange")

		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "LineNr", { bg = "#bca791", fg = "#28252c" })
		vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "#28252c", fg = "#bca791" })
		vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "#28252c", fg = "#bca791" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "#28252c" })

		vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#7e987c", fg = "#323e31" })
		vim.api.nvim_set_hl(0, "DiffChange", { bg = "#809594", fg = "#323c3c" })
		vim.api.nvim_set_hl(0, "DiffText", { bg = "#657978", fg = "#ccd5d4" })
		vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#c77b6a", fg = "#592b21" })
	end,
}
