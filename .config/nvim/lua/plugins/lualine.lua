return {
	"nvim-lualine/lualine.nvim",
	event = { "UIEnter" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"meuter/lualine-so-fancy.nvim",
		"cbochs/grapple.nvim",
		"folke/trouble.nvim",
		"folke/noice.nvim",
	},
	config = function()
		local grapple = require("grapple")
		local noice = require("noice")
		local trouble = require("trouble")
		local lazy_status = require("lazy.status")

		local codecompanion_statusline = require("plugins.extensions.codecompanion-statusline")

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

		local copilot_status = {
			get = function()
				return " "
			end,
			has = function()
				return (vim.fn.exists(":Copilot") == 2)
			end,
		}

		require("lualine").setup({
			options = {
				theme = vim.g.colors_name,
				component_separators = "⏐",
				section_separators = "",
				refresh = {
					statusline = 1000,
				},
			},
			extensions = { "quickfix", "oil", "trouble", "lazy", "mason" },
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					},
				},
				lualine_c = {
					{
						"filetype",
						icon_only = true,
						separator = "⟩",
					},
					{
						"filename",
						path = 1,
						symbols = {
							unnamed = "[??]",
							newfile = "[N]",
						},
						separator = "⟩",
					},
					-- {
					-- 	"aerial",
					-- },
					{
						symbols.get,
						cond = symbols.has,
					},
				},
				lualine_x = {
					{
						function()
							local key = grapple.name_or_index()
							return "[" .. key .. "]"
						end,
						cond = grapple.exists,
						icon = { "󰛢", color = "DiagnosticInfo" },
					},
					{ "fancy_macro", icon = { "", color = "DiagnosticError" } },
					{ "searchcount", icon = { "", color = "DiagnosticWarn" } },
				},
				lualine_y = {
					{
						noice.api.status.command.get,
						cond = noice.api.status.command.has,
						icon = { "" },
						color = "DiagnosticHint",
					},
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
						color = "DiagnosticWarn",
					},
				},
				lualine_y = {
					"diagnostics",
					codecompanion_statusline,
					{
						copilot_status.get,
						cond = copilot_status.has,
					},
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
