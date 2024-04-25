return {
	"maxmx03/dracula.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local dracula = require("dracula")

		dracula.setup({
			transparent = false,
			-- on_colors = function(colors, color)
			-- 	return {
			-- 		-- override or create new colors
			-- 		mycolor = "#ffffff",
			-- 	}
			-- end,
			on_highlights = function(colors, color)
				return {
					CursorLine = { bg = colors.bgdark },
					CursorLineNr = { fg = colors.fg },
					lualine_a_terminal = { fg = colors.base04, bg = colors.cyan, bold = true },
				}
			end,
			plugins = {
				["nvim-treesitter"] = true,
				["nvim-lspconfig"] = true,
				["nvim-cmp"] = true,
				["indent-blankline.nvim"] = true,
				["which-key.nvim"] = true,
				["dashboard-nvim"] = true,
				["gitsigns.nvim"] = true,
				["todo-comments.nvim"] = true,
				["lazy.nvim"] = true,
				["telescope.nvim"] = true,
				["noice.nvim"] = true,
				["hop.nvim"] = true,
			},
		})

		vim.cmd.colorscheme("dracula")
	end,
}
