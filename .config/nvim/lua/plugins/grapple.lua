return {
	"cbochs/grapple.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local grapple = require("grapple")
		grapple.setup({
			popup_options = {
				border = "rounded",
			},
		})

		local wk = require("which-key")

		wk.register({
			["<leader>g"] = {
				name = "Grapple",
				g = {
					grapple.cycle_forward,
					"Cycle forward",
				},
				G = {
					grapple.cycle_backward,
					"Cycle backward",
				},
				t = {
					[[<cmd>Telescope grapple tags theme=dropdown<cr>]],
					"Tags menu",
				},
				s = {
					grapple.toggle_scopes,
					"Scopes menu",
				},
				R = {
					grapple.reset,
					"Reset",
				},
			},
			["<c-g>"] = {
				grapple.toggle,
				"Grapple toggle",
			},
		})
	end,
}
