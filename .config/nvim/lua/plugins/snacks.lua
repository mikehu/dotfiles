return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			indent = {
				indent = {
					only_current = true,
				},
				scope = {
					char = "┊",
					underline = true,
					only_current = true,
				},
				animate = {
					enabled = false,
				},
			},
			notifier = {
				enabled = true,
			},
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			styles = {
				notification = {
					wo = { wrap = true },
				},
			},
		},
		keys = {
			{
				"<leader>un",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Show notifications",
			},
			{
				"<leader>L",
				function()
					Snacks.lazygit()
				end,
				desc = "Open Lazygit",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Close buffer",
			},
			{
				"<leader>bD",
				function()
					Snacks.bufdelete({ force = true })
				end,
				desc = "Force close buffer",
			},
			{
				"<leader>gl",
				function()
					Snacks.git.blame_line()
				end,
				desc = "Blame line",
			},
			{
				"]]",
				function()
					Snacks.words.jump(vim.v.count1)
				end,
				desc = "Next Reference",
				mode = { "n", "t" },
			},
			{
				"[[",
				function()
					Snacks.words.jump(-vim.v.count1)
				end,
				desc = "Prev Reference",
				mode = { "n", "t" },
			},
		},
	},
}
