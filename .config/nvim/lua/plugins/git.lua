return {
	{ "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
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
		opt = {
			change_directory_command = "tcd",
		},
	},
}
