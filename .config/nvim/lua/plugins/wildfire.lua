return {
	"sustech-data/wildfire.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		local wf = require("wildfire")
		require("wildfire").setup({
			keymaps = {
				init_selection = "<leader>v",
				node_incremental = "<tab>",
				node_decremental = "<s-tab>",
			},
			filetype_exclude = { "qf", "netrw", "lazy", "mason", "oil", "term" },
		})

		local wk = require("which-key")
		wk.add({
			{
				"<leader>v",
				function()
					wf.init_selection()
				end,
				desc = "Select with tree-sitter",
			},
		})
	end,
}
