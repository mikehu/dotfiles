return {
	{
		"ramilito/kubectl.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local k = require("kubectl")
			k.setup({})
			local wk = require("which-key")
			wk.add({
				{
					"<leader>uk",
					function()
						k.open()
					end,
					desc = "Kubectl",
					icon = "🚢",
				},
			})
		end,
	},
}
