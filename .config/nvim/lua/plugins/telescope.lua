return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		tag = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				lazy = true,
				build = "make",
			},
			{
				"nvim-telescope/telescope-media-files.nvim",
				lazy = true,
			},
		},
		config = function()
			local telescope = require("telescope")
			local nonicons = require("nvim-nonicons")
			telescope.load_extension("fzf")
			telescope.load_extension("notify")
			telescope.load_extension("noice")
			telescope.load_extension("media_files")
			telescope.load_extension("git_worktree")
			telescope.load_extension("todo-comments")
			telescope.load_extension("yank_history")
			telescope.load_extension("whop")

			local actions = require("telescope.actions")
			telescope.setup({
				defaults = {
					prompt_prefix = "  " .. nonicons.get("telescope") .. "  ",
					selection_caret = " ❯ ",
					selection_strategy = "row",
					entry_prefix = "   ",
					winblend = 20,
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
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
						"--glob", -- don't show inside of .git/ as it's not .gitignore'd
						"!**/.git/*",
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
						},
					},
					find_files = {
						find_command = { "rg", "--color=never", "--files", "--hidden", "--glob", "!**/.git/*" },
					},
					oldfiles = {
						theme = "dropdown",
					},
					current_buffer_fuzzy_find = {
						layout_strategy = "vertical",
						previewer = false,
					},
				},
				extensions = {
					fzf = {
						fuzzy = false,
					},
					media_files = {
						-- filetypes whitelist
						-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
						filetypes = { "png", "webp", "jpg", "jpeg" },
						-- find command (defaults to `fd`)
						find_cmd = "rg",
					},
				},
			})

			local wk = require("which-key")
			local builtin = require("telescope.builtin")
			local themes = require("telescope.themes")
			local with_dropdown = themes.get_dropdown()
			local media_files = telescope.extensions.media_files
			local git_worktree = telescope.extensions.git_worktree
			local todo_comments = telescope.extensions["todo-comments"]
			local yank_history = telescope.extensions.yank_history
			local whop = telescope.extensions.whop
			local notify = telescope.extensions.notify

			-- Find files from project root with fallback
			function vim.find_files_from_project_git_root()
				local function is_git_repo()
					vim.fn.system("git rev-parse --is-inside-work-tree")
					return vim.v.shell_error == 0
				end
				local function get_git_root()
					local dot_git_path = vim.fn.finddir(".git", ".;")
					return vim.fn.fnamemodify(dot_git_path, ":h")
				end
				local opts = { wrap_results = true }
				if is_git_repo() then
					table.insert(opts, { cwd = get_git_root() })
				end
				builtin.find_files(themes.get_dropdown(opts))
			end

			-- Convenience keymaps
			vim.keymap.set("n", "<leader>o", vim.find_files_from_project_git_root, { desc = "Open file" })
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find()
			end, { desc = "Search current buffer" })

			wk.add({
				{ "<leader>f", group = "Telescope", icon = "🔭" },
				{
					"<leader>ff",
					function()
						builtin.resume()
					end,
					desc = "Resume last",
				},
				{
					"<leader>fb",
					function()
						builtin.buffers()
					end,
					desc = "Open buffers",
				},
				{
					"<leader>fy",
					function()
						builtin.oldfiles()
					end,
					desc = "Recent files",
				},
				{
					"<leader>fg",
					function()
						builtin.live_grep()
					end,
					desc = "Live grep",
				},
				{
					"<leader>fm",
					function()
						media_files.media_files({ layout_strategy = "vertical" })
					end,
					desc = "Media files",
				},
				{
					"<leader>fw",
					function()
						git_worktree.git_worktrees(with_dropdown)
					end,
					desc = "Git worktree",
				},
				{
					"<leader>fp",
					function()
						yank_history.yank_history(with_dropdown)
					end,
					desc = "Yank history",
				},
				{
					"<leader>ft",
					function()
						todo_comments.todo({ layout_strategy = "vertical" })
					end,
					desc = "Todo comments",
				},
				{
					"<leader>fc",
					function()
						whop.whop(with_dropdown)
					end,
					desc = "Buffer operations",
				},
				{
					"<leader>fq",
					function()
						builtin.quickfix(with_dropdown)
					end,
					desc = "Quickfix list",
				},
				{
					"<leader>fj",
					function()
						builtin.jumplist({ layout_strategy = "vertical" })
					end,
					desc = "Jumplist",
				},
				{
					"<leader>fN",
					function()
						notify.notify({ layout_strategy = "vertical" })
					end,
					desc = "Notifications",
				},
				{
					"<leader>fh",
					function()
						builtin.help_tags()
					end,
					desc = "Help tags",
				},
				{
					"<leader>f<cr>",
					function()
						builtin.commands()
					end,
					desc = "Find commands",
				},
			})
		end,
	},
}
