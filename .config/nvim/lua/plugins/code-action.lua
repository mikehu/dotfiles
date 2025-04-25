return {
	"rachartier/tiny-code-action.nvim",
	event = "LspAttach",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "folke/snacks.nvim" },
	},
	config = function()
		local code_action = require("tiny-code-action")

		code_action.setup({
			backend = "difftastic",
			picker = {
				"snacks",
				opts = {
					layout = {
						preset = "dropdown",
					},
				},
			},
		})

		local wk = require("which-key")
		wk.add({
			mode = { "n", "x" },
			"<leader>a",
			function()
				code_action.code_action()
			end,
			desc = "code action",
			icon = "🛠️",
		})
	end,
}
