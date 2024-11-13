return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	enabled = true,
	dependencies = {
		"ozthemagician/alpha-cowsays-nvim",
	},
	config = function()
		local alpha = require("alpha")
		local startify = require("alpha.themes.startify")
		local cow = require("alpha-cowsays-nvim")

		startify.section.header.val = cow.cowsays()

		alpha.setup(startify.config)
	end,
}
