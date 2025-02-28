return {
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
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
	{
		"ThePrimeagen/git-worktree.nvim",
		config = function()
			local worktree = require("git-worktree")
			worktree.setup({})

			local function is_git_repo()
				vim.fn.system("git rev-parse --is-inside-work-tree")
				return vim.v.shell_error == 0
			end

			local function relative_path_to_worktree_root(path)
				if is_git_repo() then
					local bare_root = vim.fn.finddir(".bare", ".;")
					if bare_root ~= "" then
						local git_root = vim.fn.fnamemodify(vim.fn.fnamemodify(bare_root, ":h"), ":p")
						local path_with_slash = path .. "/"
						if path_with_slash == git_root then
							return "/"
						end
						return path:gsub(git_root, "")
					end
				end
				return path
			end

			worktree.on_tree_change(function(op, metadata)
				if op == worktree.Operations.Switch then
					vim.notify(
						string.format(
							"Switched from '%s' to '%s'",
							relative_path_to_worktree_root(metadata.prev_path),
							relative_path_to_worktree_root(metadata.path)
						),
						nil,
						{ title = "Git Worktree", id = "git-worktree" }
					)
				end
			end)

			vim.api.nvim_create_autocmd("User", {
				pattern = "PersistEnter",
				callback = function()
					local persist = require("persistence")
					local rel_path = relative_path_to_worktree_root(vim.fn.getcwd())
					if rel_path == "/" then
						local success, worktrees = pcall(worktree.get_worktrees)

						vim.notify("success: " .. success .. " > " .. #worktrees)
						if success and #worktrees > 0 then
							vim.notify("Switching to worktree: " .. worktrees[1].name)
							worktree.switch_worktree(worktrees[1])

							vim.defer_fn(function()
								persist.load()
							end, 100)
						end
					else
						persist.load()
					end
				end,
				once = true,
			})
		end,
	},
}
