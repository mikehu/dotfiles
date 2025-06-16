return {
	"folke/todo-comments.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
	opts = {},
	keys = {
		{
			"<leader>fT",
			function()
				Snacks.picker.todo_comments()
			end,
			desc = "Todo comments",
		},
	},
}
