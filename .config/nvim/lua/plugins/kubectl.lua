return {
	{
		"ramilito/kubectl.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>k",
				function()
					require("kubectl").open()
				end,
				desc = "🚢 Kubectl",
			},
		},
		config = function()
			require("kubectl").setup({})
		end,
	},
}
