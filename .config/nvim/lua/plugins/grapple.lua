return {
	"cbochs/grapple.nvim",
	event = "VeryLazy",
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
			{ "<leader>gg", grapple.cycle_forward, desc = "Cycle forward", icon = "🪝" },
			{ "<leader>gG", grapple.cycle_backward, desc = "Cycle backward", icon = "🪝" },
			{
				"<leader>gt",
				[[<cmd>Telescope grapple tags theme=dropdown<cr>]],
				desc = "Tags menu",
				icon = "🔭",
			},
			{ "<leader>gS", grapple.toggle_scopes, desc = "Scopes menu", icon = "🪝" },
			{ "<leader>gR", grapple.reset, desc = "Reset", icon = "🪝" },
			{ "<C-g>g", grapple.toggle, desc = "Grapple toggle", icon = "🪝" },
		})
	end,
}
