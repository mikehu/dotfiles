return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	config = function()
		local catppuccin = require("catppuccin")
		catppuccin.setup({
			flavour = "latte", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "macchiato",
			},
			transparent_background = false, -- disables setting the background color.
		})
		-- vim.cmd.colorscheme("catppuccin")
	end,
}
