_G.dd = function(...)
	Snacks.debug.inspect(...)
end
_G.bt = function()
	Snacks.debug.backtrace()
end
vim.print = _G.dd

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = {},
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
		image = {
			enabled = false,
		},
		input = {},
		notifier = {
			style = "compact",
		},
		picker = {
			sources = {
				files = {
					cmd = "fd",
					hidden = true,
					exclude = { ".git", "node_modules" },
					args = { "--color=never" },
					filter = { cwd = true },
					matcher = { frecency = true },
				},
				grep = {
					cmd = "rg",
					hidden = true,
					glob = "!**/.git/*",
					args = {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--trim",
					},
					matcher = { frecency = true },
				},
			},
			win = {
				preview = {
					wo = {
						number = false,
						relativenumber = false,
					},
				},
			},
		},
		quickfile = {},
		scratch = {
			filekey = {
				count = false,
			},
		},
		statuscolumn = {},
		words = {},
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
			"<leader>o",
			function()
				Snacks.picker.smart({ filter = { cwd = true } })
			end,
			desc = "Open file",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep({ buffers = true })
			end,
			desc = "Find in buffers",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep({ buffers = false })
			end,
			desc = "Grep",
		},
		{
			"<leader>L",
			function()
				Snacks.lazygit()
			end,
			desc = "Open Lazygit",
		},
		{
			"<leader>bb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Goto buffers",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
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
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle scratch buffer",
		},
		{
			"<leader>ls",
			function()
				Snacks.scratch.select()
			end,
			desc = "List scratch buffer",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next reference",
			mode = { "n", "t" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev reference",
			mode = { "n", "t" },
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.pickers()
			end,
			desc = "Pickers",
		},
		{
			"<leader>fc",
			function()
				Snacks.picker.command_history({
					layout = {
						preset = "ivy",
						preview = false,
					},
				})
			end,
			desc = "Prev commands",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help({ layout = { preset = "ivy" } })
			end,
			desc = "Help",
		},
		{
			"<leader>fj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "Jump list",
		},
		{
			"<leader>fm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>fq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix list",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.lsp_references({ layout = { preset = "ivy" } })
			end,
			desc = "References",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.lsp_symbols({ layout = { preset = "ivy" } })
			end,
			desc = "Symbols",
		},
		{
			"<leader>fS",
			function()
				Snacks.picker.lsp_workspace_symbols({ layout = { preset = "ivy" } })
			end,
			desc = "Workspace symbols",
		},
	},
}
