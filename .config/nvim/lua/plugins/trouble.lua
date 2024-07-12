return {
	"folke/trouble.nvim",
	config = function()
		require("trouble").setup({
			auto_close = true,
		})

		local wk = require("which-key")
		wk.add({
			{ "<leader>t", group = "Trouble", icon = "🚦" },
			{ "<leader>tt", [[<cmd>Trouble diagnostics toggle<cr>]], desc = "Diagnostics" },
			{
				"<leader>tb",
				[[<cmd>Trouble diagnostics toggle filter.buf=0<cr>]],
				desc = "Buffer diagnostics",
			},
			{ "<leader>tq", [[<cmd>Trouble qflist toggle<cr>]], desc = "Quickfix list" },
			{ "<leader>tl", [[<cmd>Trouble loclist toggle<cr>]], desc = "Location list" },
		})
	end,
}
