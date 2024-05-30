return {
	"folke/trouble.nvim",
	config = function()
		require("trouble").setup({
			auto_close = true,
		})

		local wk = require("which-key")
		wk.register({
			["<leader>t"] = {
				name = "Trouble",
				t = {
					[[<cmd>Trouble diagnostics toggle<cr>]],
					"Diagnostics",
				},
				b = {
					[[<cmd>Trouble diagnostics toggle filter.buf=0<cr>]],
					"Buffer diagnostics",
				},
				q = {
					[[<cmd>Trouble qflist toggle<cr>]],
					"Quickfix list",
				},
				l = {
					[[<cmd>Trouble loclist toggle<cr>]],
					"Location list",
				},
			},
		})
	end,
}
