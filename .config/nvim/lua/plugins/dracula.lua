return {
	"maxmx03/dracula.nvim",
	name = "dracula",
	lazy = false,
	priority = 1000,
	config = function()
		local dracula = require("dracula")
		-- return	{
		--   base0 = '#F8F8F2',
		--   base01 = '#6272A4',
		--   base02 = '#44475A',
		--   base03 = '#282A36',
		--   base04 = '#21222C',
		--   cyan = '#8BE9FD',
		--   diag_error = '#FF5555',
		--   diag_hint = '#8BE9FD',
		--   diag_info = '#8BE9FD',
		--   diag_ok = '#50FA7B',
		--   diag_warning = '#FFB86C',
		--   git_added = '#50FA7B',
		--   git_modified = '#FFB86C',
		--   git_removed = '#FF5555',
		--   green = '#50FA7A',
		--   inlay_hint = '#538C98',
		--   orange = '#FFB86C',
		--   pink = '#FF79C6',
		--   purple = '#BD93F9',
		--   red = '#FF5555',
		--   shade_add = '#2E4940',
		--   shade_change = '#483F3E',
		--   shade_cyan = '#374754',
		--   shade_error = '#48303B',
		--   shade_green = '#2E4940',
		--   shade_hint = '#374754',
		--   shade_info = '#374754',
		--   shade_ok = '#2E4940',
		--   shade_orange = '#483F3E',
		--   shade_pink = '#5E3E5A',
		--   shade_purple = '#3E3A53',
		--   shade_red = '#48303B',
		--   shade_warning = '#483F3E',
		--   shade_yellow = '#464943',
		--   yellow = '#F1FA8C',
		-- }
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
					CodewindowBorder = { fg = colors.base02 },
					SatelliteCursor = { fg = colors.base0 },
					SatelliteSearch = { fg = colors.orange },
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
			},
		})

		vim.cmd.colorscheme("dracula")
	end,
}
