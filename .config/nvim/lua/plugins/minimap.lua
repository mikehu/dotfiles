return {
	"Isrothy/neominimap.nvim",
	version = "v3.*.*",
	enabled = true,
	lazy = false,
	keys = {
		{ "<leader>um", "<cmd>Neominimap toggle<cr>", desc = "Minimap" },
	},
	init = function()
		vim.opt.wrap = false
		vim.opt.sidescrolloff = 36

		vim.g.neominimap = {
			auto_enable = false,
			exclude_filetypes = { "help", "oil", "noice", "kulala", "codecompanion" },
			float = {
				minimap_width = 12,
				window_border = "rounded",
			},
		}
	end,
}
