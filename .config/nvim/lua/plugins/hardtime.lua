return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {
		enabled = false,
		max_count = 5,
		notification = false,
		disable_mouse = false,
		disabled_filetypes = { "qf", "netrw", "lazy", "mason", "oil", "term" },
	},
}
