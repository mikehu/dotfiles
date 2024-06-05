return {
	"stevearc/aerial.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local aerial = require("aerial")

		aerial.setup({})

		local wk = require("which-key")
		wk.register({
			["<leader>a"] = {
				[[<cmd>AerialToggle!<cr>]],
				"Aerial",
			},
		})
	end,
}
