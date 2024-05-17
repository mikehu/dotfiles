return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		-- your configuration comes here
	},
	config = function()
		require("trouble").setup({})
	end,
}
