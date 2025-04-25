return {
	"DestopLine/scratch-runner.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "folke/snacks.nvim" },
	},
	opts = {
		sources = {
			javascript = {
				{ "bun" },
				extension = "js",
			},
		},
	},
}
