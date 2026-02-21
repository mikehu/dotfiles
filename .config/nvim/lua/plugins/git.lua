return {
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.add({
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

			local wk = require("which-key")
			wk.add({
				{ "<leader>gb", gitsigns.toggle_current_line_blame, desc = "Toggle blame" },
			})
		end,
	},
	{
		"isakbm/gitgraph.nvim",
		event = "VeryLazy",
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
				on_select_commit = function(commit)
					vim.fn.setreg("+", commit.hash)
					vim.notify("Copied " .. commit.hash:sub(1, 7))
					vim.cmd("quit")
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
