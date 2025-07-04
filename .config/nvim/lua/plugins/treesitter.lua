return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"css",
					"diff",
					"git_rebase",
					"gleam",
					"go",
					"html",
					"http",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"rust",
					"javascript",
					"json",
					"tsx",
					"typescript",
					"svelte",
					"vim",
					"vue",
					"yaml",
					"zig",
				},
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = false,
					-- keymaps = {
					-- 	init_selection = "<leader>v",
					-- 	scope_incremental = "<c-n>",
					-- 	node_incremental = "<tab>",
					-- 	node_decremental = "<s-tab>",
					-- },
				},
				matchup = {
					enable = true,
					include_match_words = true,
				},
				textobjects = {
					select = {
						enable = true,

						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,

						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							-- You can also use captures from other query groups like `locals.scm`
							-- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
						},

						-- selection_modes = {
						--   ["@parameter.outer"] = "v", -- charwise
						--   ["@function.outer"] = "V", -- linewise
						--   ["@class.outer"] = "V",
						--   -- ["@class.outer"] = "<c-v>", -- blockwise
						-- },
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]a"] = "@parameter.outer",
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
						},
						goto_next_end = {
							["]A"] = "@parameter.outer",
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
						},
						goto_previous_start = {
							["[a"] = "@parameter.outer",
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
						},
						goto_previous_end = {
							["[A"] = "@parameter.outer",
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["ga"] = "@parameter.inner",
						},
						swap_previous = {
							["gA"] = "@parameter.inner",
						},
					},
					autotags = {
						enable = true,
					},
					lsp_interop = {
						enable = true,
						border = "none",
						floating_preview_opts = {},
						peek_definition_code = {
							["<leader>kf"] = "@function.outer",
							["<leader>kc"] = "@class.outer",
						},
					},
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
	},
}
