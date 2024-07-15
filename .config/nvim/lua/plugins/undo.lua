return {
	"debugloop/telescope-undo.nvim",
	lazy = true,
	dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	keys = {
		{ -- lazy style key map
			"<leader>fu",
			"<cmd>Telescope undo<cr>",
			desc = "Undo history",
		},
	},
	config = function()
		require("telescope").setup({
			extensions = {
				undo = {
					use_delta = false,
					layout_strategy = "vertical",
					layout_config = {
						preview_height = 0.8,
					},
					mappings = {
						i = {
							["<cr>"] = require("telescope-undo.actions").restore,
							["<C-y>"] = function(bufnr)
								return require("telescope-undo.actions").yank_larger(bufnr)
							end,
							["<S-cr>"] = false,
							["<C-cr>"] = false,
							["<C-r>"] = false,
						},
					},
				},
			},
		})
		require("telescope").load_extension("undo")
	end,
}
