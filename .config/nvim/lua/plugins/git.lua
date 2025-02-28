return {
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.add({
				{ "<leader>gD", [[<cmd>Gdiff<cr>]], desc = "Diff this" },
				{ "<leader>gW", [[<cmd>Gwrite<cr>]], desc = "Write" },
				{ "<leader>gf", [[<cmd>Gread<cr>]], desc = "Checkout file" },
				{ "<leader>gB", [[<cmd>GBrowse<cr>]], desc = "Browse on web" },
				{ "<leader>gc", [[<cmd>Git commit<cr>]], desc = "Commit" },
				{ "<leader>gM", [[<cmd>Git mergetool<cr>]], desc = "Mergetool" },
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "UIEnter",
		config = function()
			local gitsigns = require("gitsigns")
			gitsigns.setup({
				current_line_blame_opts = {
					virt_text_pos = "right_align",
				},
			})

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

			local next_hunk, prev_hunk =
				ts_repeat_move.make_repeatable_move_pair(gitsigns.next_hunk, gitsigns.prev_hunk)

			local wk = require("which-key")
			wk.add({
				mode = { "n", "x", "o" },
				{
					"]h",
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "]h", bang = true })
						else
							next_hunk()
						end
					end,
					desc = "Next hunk",
				},
				{
					"[h",
					function()
						if vim.wo.diff then
							vim.cmd.normal({ "[h", bang = true })
						else
							prev_hunk()
						end
					end,
					desc = "Prev hunk",
				},
				{ "<leader>gb", gitsigns.toggle_current_line_blame, desc = "Toggle blame" },
				{ "<leader>gd", gitsigns.toggle_deleted, desc = "Show/hide deleted" },
				{ "<leader>gw", gitsigns.toggle_word_diff, desc = "Show/hide word diff" },
				{ "<leader>gp", gitsigns.preview_hunk, desc = "Preview hunk" },
				{ "<leader>gs", gitsigns.stage_hunk, desc = "Stage hunk" },
				{ "<leader>gr", gitsigns.reset_hunk, desc = "Reset hunk" },
			})
		end,
	},
	{
		"isakbm/gitgraph.nvim",
		event = "VeryLazy",
		dependencies = {
			"sindrets/diffview.nvim",
		},
		opts = {
			symbols = {
				merge_commit = "",
				commit = "",
				merge_commit_end = "",
				commit_end = "",

				-- Advanced symbols
				GVER = "",
				GHOR = "",
				GCLD = "",
				GCRD = "╭",
				GCLU = "",
				GCRU = "",
				GLRU = "",
				GLRD = "",
				GLUD = "",
				GRUD = "",
				GFORKU = "",
				GFORKD = "",
				GRUDCD = "",
				GRUDCU = "",
				GLUDCD = "",
				GLUDCU = "",
				GLRDCL = "",
				GLRDCR = "",
				GLRUCL = "",
				GLRUCR = "",
			},
			hooks = {
				-- Check diff of a commit
				on_select_commit = function(commit)
					vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
				end,
				-- Check diff from commit a -> commit b
				on_select_range_commit = function(from, to)
					vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
				end,
			},
		},
		keys = {
			{
				"<leader>gL",
				function()
					require("gitgraph").draw({}, { all = true, max_count = 5000 })
				end,
				desc = "Log",
			},
		},
	},
}
