return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local telescope = require("telescope")
			telescope.load_extension("yank_history")

			local actions = require("telescope.actions")
			telescope.setup({
				defaults = {
					prompt_prefix = "   ",
					selection_caret = " ❯ ",
					entry_prefix = "   ",
					winblend = 15,
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
						},
						n = {
							["q"] = actions.close,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--trim",
						"--hidden",
						"--glob",
						"!**/.git/*", -- don't show inside of .git/ as it's not .gitignore'd
					},
				},
			})
		end,
	},
}
