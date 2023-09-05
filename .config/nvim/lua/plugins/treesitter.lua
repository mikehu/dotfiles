return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"RRethy/nvim-treesitter-textsubjects",
		"windwp/nvim-ts-autotag",
	},
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"css",
				"go",
				"html",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"rust",
				"javascript",
				"json",
				"tsx",
				"typescript",
				"vim",
				"vue",
				"yaml",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
			-- incremental_selection = {
			-- 	enable = true,
			-- 	keymaps = {
			-- 		init_selection = "<c-space>",
			-- 		scope_incremental = "<c-s>",
			-- 		node_incremental = "<tab>",
			-- 		node_decremental = "<s-tab>",
			-- 	},
			-- },
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
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]C"] = "@class.outer",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_previous_end = {
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
						["<leader>Df"] = "@function.outer",
						["<leader>Dc"] = "@class.outer",
					},
				},
			},
		})
	end,
}
