return {
	"DanWlker/toolbox.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-telescope/telescope.nvim" },
	keys = {
		{
			"<leader>fx",
			function()
				require("toolbox").show_picker()
			end,
			desc = "Scripts toolbox",
		},
	},
	opts = {
		commands = {},
	},
}
