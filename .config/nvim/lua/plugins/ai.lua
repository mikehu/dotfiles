return {
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = function()
			vim.g.copilot_filetypes = {
				["*"] = false,
				["javascript"] = true,
				["typescript"] = true,
				["lua"] = false,
				["rust"] = true,
				["c"] = true,
				["c#"] = true,
				["c++"] = true,
				["html"] = false,
				["htmx"] = true,
				["go"] = true,
				["python"] = true,
				["vue"] = true,
			}
			vim.g.copilot_workspace_folders = {
				"~/Code/neurox",
				"~/Code/illustrious-industries",
			}
		end,
	},
	{
		"augmentcode/augment.vim",
		event = "VeryLazy",
		config = function()
			vim.g.augment_workspace_folders = {
				"~/Code/neurox",
				"~/Code/illustrious-industries",
			}
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"j-hui/fidget.nvim",
		},
		init = function()
			require("plugins.extensions.codecompanion-fidget"):init()
		end,
		config = function()
			require("codecompanion").setup({
				display = {
					action_palette = {
						provider = "default",
					},
					chat = {
						start_in_insert_mode = true,
						window = {
							width = 0.4,
						},
					},
				},
				strategies = {
					chat = {
						adapter = "copilot_sonnet",
						roles = {
							user = "  " .. vim.env.USER:gsub("^%l", string.upper),
							llm = function(adapter)
								return string.format(
									"  %s (%s)",
									adapter.formatted_name,
									adapter.schema.model.default
								)
							end,
						},
						slash_commands = {
							["file"] = {
								-- Location to the slash command in CodeCompanion
								callback = "strategies.chat.slash_commands.file",
								description = "Select a file using Telescope",
								opts = {
									provider = "snacks", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
									contains_code = true,
								},
							},
						},
					},
					inline = {
						adapter = "copilot_sonnet",
					},
				},
				adapters = {
					copilot_sonnet = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "claude-3.7-sonnet",
								},
							},
						})
					end,
					copilot_o3 = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "o3-mini",
								},
							},
						})
					end,
					openai = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = 'cmd:op item get "OpenAI - Homelab" --vault "Private" --account MXFJNCXIPZC2ZNSNS35K6CT334 --fields credential --reveal',
							},
						})
					end,
				},
			})

			local wk = require("which-key")
			wk.add({
				{ "<leader>c", group = "Chat / AI", icon = "🤖" },
				{
					mode = { "n" },
					nowait = true,
					remap = false,
					{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat" },
					{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Chat" },
					{ "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
				},
				{
					mode = { "v" },
					nowait = true,
					remap = false,
					{ "<leader>cc", ":'<,'>CodeCompanion<cr>", desc = "Inline assist" },
				},
			})
		end,
	},
}
