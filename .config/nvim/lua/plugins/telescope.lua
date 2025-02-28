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
				pickers = {
					buffers = {
						theme = "dropdown",
						previewer = false,
						mappings = {
							i = {
								["<C-d>"] = actions.delete_buffer + actions.move_to_top,
							},
							n = {
								["d"] = actions.delete_buffer,
							},
						},
					},
					find_files = {
						find_command = { "rg", "--color=never", "--files", "--hidden", "--glob", "!**/.git/*" },
					},
				},
			})

			local wk = require("which-key")
			local themes = require("telescope.themes")
			local with_ivy = themes.get_ivy()
			local yank_history = telescope.extensions.yank_history

			wk.add({
				{
					"<leader>fp",
					function()
						yank_history.yank_history(with_ivy)
					end,
					desc = "Yank history",
					icon = "🔭",
				},
			})
		end,
	},
}
