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

		local function is_copilot_available()
			return (vim.fn.exists(":Copilot") == 2)
		end
		local copilot_status = {
			get = function()
				if not is_copilot_available() then
					return ""
				end
				local status_icon = " "
				local result = vim.api.nvim_exec2("Copilot status", { output = true })
				if result.output:find("Ready") then
					-- Command succeeded and output is Copilot Ready
					return string.format("%%#DiagnosticOk#%s", status_icon)
				else
					-- Command succeeded but output is not as expected
					return string.format("%%#DiagnosticWarn#%s", status_icon)
				end
			end,
			has = function()
				return is_copilot_available()
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
