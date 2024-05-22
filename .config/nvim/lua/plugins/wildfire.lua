return {
	"sustech-data/wildfire.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("wildfire").setup({
			keymaps = {
				init_selection = "<leader>v",
				node_incremental = "<tab>",
				node_decremental = "<s-tab>",
			},
			filetype_exclude = { "qf", "netrw", "lazy", "mason", "oil", "term" },
		})
	end,
}
