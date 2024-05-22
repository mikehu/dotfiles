return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	config = function()
		local satellite = require("satellite")
		satellite.setup({
			handlers = {
				diagnostic = {
					enable = false,
				},
			},
		})
	end,
}
