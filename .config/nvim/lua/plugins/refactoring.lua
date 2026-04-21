return {
	"ThePrimeagen/refactoring.nvim",
	event = "VeryLazy",
	dependencies = {
		"lewis6991/async.nvim",
	},
	config = function()
		require("refactoring").setup()
	end,
}
