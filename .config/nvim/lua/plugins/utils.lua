return {
	"tpope/vim-sleuth",
	"sitiom/nvim-numbertoggle",
	{
		"m4xshen/smartcolumn.nvim",
		event = "VeryLazy",
		opts = {},
	},
	"tpope/vim-repeat",
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		-- See `:help indent_blankline.txt`
		opts = {
			char = "┊",
			show_trailing_blankline_indent = false,
		},
	},
}
