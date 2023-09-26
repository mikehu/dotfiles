return {
	"yorickpeterse/nvim-window",
	event = "VeryLazy",
	config = function()
		local nvim_window = require("nvim-window")
		nvim_window.setup({})

		vim.keymap.set("n", "<leader>w", nvim_window.pick, { desc = "Window picker" })
	end,
}
