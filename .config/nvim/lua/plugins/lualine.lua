return {
	"nvim-lualine/lualine.nvim",
	event = { "UIEnter" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"meuter/lualine-so-fancy.nvim",
		"cbochs/grapple.nvim",
		"folke/trouble.nvim",
	},
	config = function()
		local grapple = require("grapple")
		local trouble = require("trouble")
		local lazy_status = require("lazy.status")

		local symbols = trouble.statusline({
			mode = "lsp_document_symbols",
			groups = {},
			title = false,
			filter = { range = true },
			sep = "›",
			format = "{kind_icon}{symbol.name:Normal}",
			-- The following line is needed to fix the background color
			-- Set it to the lualine section you want to use
			hl_group = "lualine_c_normal",
		})

		require("lualine").setup({
			options = {
				theme = vim.g.colors_name,
				component_separators = "|",
				section_separators = "",
				refresh = {
					statusline = 1000,
				},
			},
			extensions = { "quickfix", "oil", "trouble", "lazy" },
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
						icon = "",
					},
					{
						symbols.get,
						cond = symbols.has,
					},
					{
						function()
							local key = grapple.name_or_index()
							return "[" .. key .. "]"
						end,
						cond = grapple.exists,
						icon = { "󰛢" },
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
