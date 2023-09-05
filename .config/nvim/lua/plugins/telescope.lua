return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local nonicons = require("nvim-nonicons")
			telescope.load_extension("fzy_native")
			telescope.load_extension("file_browser")
			telescope.load_extension("notify")
			telescope.load_extension("noice")
			telescope.load_extension("media_files")
			telescope.load_extension("persisted")

			local actions = require("telescope.actions")
			telescope.setup({
				defaults = {
					prompt_prefix = "  " .. nonicons.get("telescope") .. "  ",
					selection_caret = " ❯ ",
					entry_prefix = "   ",
					winblend = 20,
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
							-- ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
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
								["<c-d>"] = actions.delete_buffer + actions.move_to_top,
							},
						},
					},
					find_files = {
						find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
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
			local file_browser = telescope.extensions.file_browser
			local media_files = telescope.extensions.media_files

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
				local opts = with_dropdown
				if is_git_repo() then
					table.insert(opts, { cwd = get_git_root() })
				end
				builtin.find_files(opts)
			end

			-- Convenience keymaps
			vim.keymap.set("n", "<leader>o", vim.find_files_from_project_git_root, { desc = "Open file" })
			vim.keymap.set("n", "<leader>b", function()
				builtin.buffers()
			end, { desc = "Recent files" })
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find()
			end, { desc = "Search current buffer" })

			-- Telescope plugin
			wk.register({
				f = {
					name = "+Telescope",
					y = {
						function()
							builtin.oldfiles()
						end,
						"Recent files",
					},
					b = {
						function()
							file_browser.file_browser({ path = vim.fn.expand("%:p:h"), select_buffer = true })
						end,
						"File browser",
					},
					g = {
						function()
							builtin.live_grep()
						end,
						"Live grep",
					},
					m = {
						function()
							media_files.media_files({ layout_strategy = "vertical", winblend = 20 })
						end,
						"Media files",
					},
					j = {
						function()
							builtin.jumplist()
						end,
						"Jumplist",
					},
					h = {
						function()
							builtin.help_tags()
						end,
						"Help tags",
					},
					["<cr>"] = {
						function()
							builtin.commands()
						end,
						"Find commands",
					},
				},
			}, { prefix = "<leader>" })
		end,
	},
	{
		"nvim-telescope/telescope-fzy-native.nvim",
		lazy = true,
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		lazy = true,
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-media-files.nvim",
		lazy = true,
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
}
