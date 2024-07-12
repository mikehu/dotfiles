return {
	{
		"NeogitOrg/neogit",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = true,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			local gitsigns = require("gitsigns")
			gitsigns.setup()

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			local next_hunk, prev_hunk =
				ts_repeat_move.make_repeatable_move_pair(gitsigns.next_hunk, gitsigns.prev_hunk)

			local wk = require("which-key")
			wk.register({
				["]h"] = {
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "]h", bang = true })
						else
							next_hunk()
						end
					end,
					"Next hunk",
				},
				["[h"] = {
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "[h", bang = true })
						else
							prev_hunk()
						end
					end,
					"Prev hunk",
				},
				["<leader>Gs"] = {
					gitsigns.stage_hunk,
					"Stage hunk",
				},
				["<leader>Gr"] = {
					gitsigns.reset_hunk,
					"Reset hunk",
				},
			}, { mode = { "n", "x", "o" } })
		end,
	},
	{
		"ThePrimeagen/git-worktree.nvim",
		config = function()
			require("git-worktree").setup({
				change_directory_command = "tcd",
			})
		end,
	},
}
