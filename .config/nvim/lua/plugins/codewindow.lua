return {
	"gorbit99/codewindow.nvim",
	config = function()
		local codewindow = require("codewindow")
		codewindow.setup({
			exclude_filetypes = { "help", "oil", "noice" },
			minimap_width = 10,
			screen_bounds = "background",
			window_border = "rounded",
		})

		vim.keymap.set("n", "<leader>M", codewindow.toggle_minimap, { desc = "Minimap" })
	end,
}
