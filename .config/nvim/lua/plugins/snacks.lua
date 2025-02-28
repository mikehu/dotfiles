-- Find files from project root with fallback
local function find_files_from_project_git_root()
	local function is_git_repo()
		vim.fn.system("git rev-parse --is-inside-work-tree")
		return vim.v.shell_error == 0
	end
	local function get_git_root()
		local dot_git_path = vim.fn.finddir(".git", ".;")
		return vim.fn.fnamemodify(dot_git_path, ":h")
	end
	local opts = { layout_strategy = "vertical" }
	if is_git_repo() then
		table.insert(opts, { cwd = get_git_root() })
	end
	builtin.find_files(opts)
end

return {
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
		picker = {},
		quickfile = { enabled = true },
		scratch = {
			icon = " ",
			filekey = {
				count = false,
			},
			-- win_by_ft = {
			-- 	javascript = {
			-- 		keys = {
			-- 			["run"] = {
			-- 				"<cr>",
			-- 				function(self)
			--
			-- 				end,
			-- 				desc = "Run with node",
			-- 				mode = {"n", "x" }
			-- 			}
			-- 		}
			-- 	}
			-- }
		},
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = {
			notification = {
				wo = { wrap = true },
			},
			scratch = {
				zindex = 90,
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
				Snacks.picker.smart()
			end,
			desc = "Open file",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
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
			desc = "Toggle Scratch Buffer",
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
				Snacks.picker.command_history()
			end,
			desc = "Prev commands",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
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
			"<leader>fq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix list",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.lsp_references()
			end,
			desc = "References",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "Symbols",
		},
		{
			"<leader>fS",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "Workspace symbols",
		},
	},
}
