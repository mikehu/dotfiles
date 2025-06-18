return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			local rosepine = require("rose-pine")
			rosepine.setup({
				styles = {
					transparency = false,
				},
				highlight_groups = {
					StatusLine = { fg = "muted", bg = "base" },
					DiagnosticUnnecessary = { fg = "muted", undercurl = true, sp = "rose" },
					SatelliteSearch = { fg = "gold" },
				},
			})

			vim.cmd.colorscheme("rose-pine")
		end,
	},
}
