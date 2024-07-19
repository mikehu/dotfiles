return {
	"stevearc/aerial.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("aerial").setup({})

		local wk = require("which-key")
		wk.add({
			{
				"<leader>ua",
				[[<cmd>AerialToggle!<cr>]],
				desc = "Aerial",
				icon = "󰐷 ",
			},
		})
	end,
}
