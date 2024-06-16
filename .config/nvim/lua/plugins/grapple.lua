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
					"🔭 Tags menu",
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
