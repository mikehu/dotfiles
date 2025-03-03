return {
	"folke/trouble.nvim",
	event = "VeryLazy",
	config = function()
		require("trouble").setup({
			auto_close = true,
		})

		local wk = require("which-key")
		wk.add({
			{ "<leader>tt", [[<cmd>Trouble diagnostics toggle<cr>]], desc = "Diagnostics", icon = "🚦" },
			{ "<leader>tq", [[<cmd>Trouble qflist toggle<cr>]], desc = "Quickfix list", icon = "🚦" },
			{ "<leader>tl", [[<cmd>Trouble loclist toggle<cr>]], desc = "Location list", icon = "🚦" },
		})
	end,
}
