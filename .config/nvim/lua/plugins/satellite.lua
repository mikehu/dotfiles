return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	config = function()
		local satellite = require("satellite")
		satellite.setup({
			current_only = true,
			excluded_filetypes = { "codecompanion", "snacks_terminal" },
			handlers = {
				cursor = {
					enable = false,
				},
				diagnostic = {
					enable = false,
				},
			},
		})
	end,
}
