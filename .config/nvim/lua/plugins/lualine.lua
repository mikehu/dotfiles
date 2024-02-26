return {
	"nvim-lualine/lualine.nvim",
	event = { "UIEnter" },
	dependencies = {
		"maxmx03/dracula.nvim",
		"nvim-tree/nvim-web-devicons",
		"meuter/lualine-so-fancy.nvim",
		"cbochs/grapple.nvim",
	},
	config = function()
		local grapple = require("grapple")
		local lazy_status = require("lazy.status")
		local dracula_theme = require("lualine.themes.dracula")
		local dracula_colors = require("dracula.palette")

		local normal_color = dracula_theme.normal.a

		dracula_theme.terminal = {
			a = { fg = normal_color.fg, bg = dracula_colors.cyan, gui = "bold" },
		}

		require("lualine").setup({
			options = {
				theme = dracula_theme,
				component_separators = "|",
				section_separators = "",
				refresh = {
					statusline = 1000,
				},
			},
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
						icon = "",
					},
					{
						function()
							local key = grapple.key()
							return "[" .. key .. "]"
						end,
						cond = grapple.exists,
						icon = { "", align = "right" },
					},
				},
				lualine_x = {
					{ "fancy_macro", icon = { "", color = { fg = "red" } } },
					"filetype",
				},
				lualine_y = {
					{ "searchcount", icon = "" },
					"progress",
				},
				lualine_z = {
					"location",
				},
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
						icons_enabled = false,
						draw_empty = false,
						mode = 2,
						use_mode_colors = true,
					},
				},
				lualine_x = {
					{
						function()
							local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
							return "[" .. cwd .. "]"
						end,
						icon = "",
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "orange" },
					},
				},
				lualine_y = {
					"diagnostics",
				},
				lualine_z = {
					{
						"tabs",
						icon = "󰓩",
						use_mode_colors = true,
					},
				},
			},
		})
	end,
}
