return {
	{ "tpope/vim-fugitive" },
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
					next_hunk,
					"Next hunk",
				},
				["[h"] = {
					prev_hunk,
					"Prev hunk",
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
