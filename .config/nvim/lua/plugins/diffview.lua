return {
	"sindrets/diffview.nvim",
	events = "VeryLazy",
	config = function()
		local diffview = require("diffview")
		diffview.setup({
			hooks = {
				diff_buf_read = function()
					-- Change local options in diff buffers
					vim.opt_local.wrap = false
					vim.opt_local.list = false
					vim.opt_local.colorcolumn = { 80 }
				end,
			},
		})

		vim.opt.fillchars:append({ diff = "╱" })
	end,
}
