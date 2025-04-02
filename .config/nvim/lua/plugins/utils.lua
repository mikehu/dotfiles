return {
	"tpope/vim-sleuth",
	"tpope/vim-dotenv",
	"sitiom/nvim-numbertoggle",
	{
		"m4xshen/smartcolumn.nvim",
		event = "VeryLazy",
		opts = {},
	},
	"tpope/vim-repeat",
	{
		"willothy/flatten.nvim",
		config = true,
		-- or pass configuration with
		-- opts = {  }
		-- Ensure that it runs first to minimize delay when opening file from terminal
		lazy = false,
		priority = 1001,
	},
}
