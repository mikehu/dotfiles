return {
	"gbprod/yanky.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "folke/snacks.nvim" },
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
		require("yanky").setup({
			ring = { storage = "sqlite" },
		})

		local wk = require("which-key")
		wk.add({
			mode = { "n", "x" },
			{
				"<leader>p",
				function()
					Snacks.picker.yanky({
						layout = { preset = "ivy" },
					})
				end,
				desc = "Yank history",
				icon = "📋",
			},
		})
	end,
}
