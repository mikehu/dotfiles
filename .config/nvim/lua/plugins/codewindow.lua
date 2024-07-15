return {
	"gorbit99/codewindow.nvim",
	event = { "VeryLazy" },
	config = function()
		local codewindow = require("codewindow")
		codewindow.setup({
			exclude_filetypes = { "help", "oil", "noice" },
			minimap_width = 10,
			screen_bounds = "background",
			window_border = "rounded",
		})

		vim.keymap.set("n", "<leader>um", codewindow.toggle_minimap, { desc = "Minimap" })
	end,
}
