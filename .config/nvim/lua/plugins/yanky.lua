return {
	"gbprod/yanky.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "kkharji/sqlite.lua" },
	},
	keys = {
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
		{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
		{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
		{ "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
		{ "<c-n>", "<Plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
	},
	config = function()
		local mapping = require("yanky.telescope.mapping")

		require("yanky").setup({
			ring = { storage = "sqlite" },
			picker = {
				telescope = {
					use_default_mappings = false,
					mappings = {
						default = mapping.put("p"),
						i = {
							["<c-i>"] = mapping.put("P"),
							["<c-d>"] = mapping.delete(),
						},
						n = {
							d = mapping.delete(),
						},
					},
				},
			},
		})

		local wk = require("which-key")
		wk.add({
			mode = { "n", "x" },
			{
				"<leader>p",
				"<cmd>Telescope yank_history theme=dropdown<cr>",
				desc = "Yank history",
				icon = "📋",
			},
		})
	end,
}
