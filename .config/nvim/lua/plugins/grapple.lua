return {
	"cbochs/grapple.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local grapple = require("grapple")
		grapple.setup({
			scope = "git",
			popup_options = {
				border = "rounded",
			},
		})

		local telescope = require("telescope")
		telescope.load_extension("grapple")

		local wk = require("which-key")
		wk.add({
			{ "<leader>g", group = "Grapple", icon = "🪝" },
			{ "<leader>gg", grapple.cycle_forward, desc = "Cycle forward" },
			{ "<leader>gG", grapple.cycle_backward, desc = "Cycle backward" },
			{
				"<leader>gt",
				[[<cmd>Telescope grapple tags theme=dropdown<cr>]],
				desc = "Tags menu",
				icon = "🔭",
			},
			{ "<leader>gs", grapple.toggle_scopes, desc = "Scopes menu" },
			{ "<leader>gR", grapple.reset, desc = "Reset" },
			{ "<c-g>", grapple.toggle, desc = "Grapple toggle" },
		})
	end,
}
