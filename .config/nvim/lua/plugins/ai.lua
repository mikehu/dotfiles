local workspace_folders = {
	"~/Code/neurox",
	"~/Code/illustrious-industries",
}

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
			vim.g.copilot_workspace_folders = workspace_folders
		end,
	},
	-- {
	-- 	"supermaven-inc/supermaven-nvim",
	-- 	config = function()
	-- 		require("supermaven-nvim").setup({})
	-- 	end,
	-- },
	{
		"ravitemer/codecompanion-history.nvim",
		event = "VeryLazy",
	},
	{
		"ravitemer/mcphub.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
		},
		-- build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
		build = "bundled_build.lua",
		config = function()
			require("mcphub").setup({
				config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to config file
				use_bundled_binary = true,
				auto_approve = true,
				auto_toggle_mcp_servers = true,
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"j-hui/fidget.nvim",
			"ravitemer/codecompanion-history.nvim",
			"ravitemer/mcphub.nvim",
		},
		init = function()
			require("plugins.extensions.codecompanion-fidget"):init()
		end,
		config = function()
			require("codecompanion").setup({
				display = {
					action_palette = {
						provider = "snacks",
					},
					chat = {
						start_in_insert_mode = false,
						window = {
							width = 0.4,
						},
					},
				},
				extensions = {
					history = {
						opts = {
							-- Keymap to open history from chat buffer (default: gh)
							keymap = "gh",
							-- Automatically generate titles for new chats
							auto_generate_title = true,
							-- On exiting and entering neovim, loads the last chat on opening chat
							continue_last_chat = true,
							-- When chat is cleared with `gx` delete the chat from history
							delete_on_clearing_chat = false,
							-- Picker interface ("telescope", "snacks" or "default")
							picker = "snacks",
							-- Enable detailed logging for history extension
							enable_logging = false,
							-- Directory path to save the chats
							dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
							-- Save all chats by default
							auto_save = true,
							-- Keymap to save the current chat manually
							save_chat_keymap = "gw",
							-- Number of days after which chats are automatically deleted (0 to disable)
							expiration_days = 7,
						},
					},
					mcphub = {
						callback = "mcphub.extensions.codecompanion",
						opts = {
							show_result_in_chat = false, -- Show the mcp tool result in the chat buffer
							make_vars = true, -- make chat #variables from MCP server resources
							make_slash_commands = true, -- make /slash_commands from MCP server prompts
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
								opts = {
									provider = "snacks",
								},
							},
							["buffer"] = {
								opts = {
									provider = "snacks",
								},
							},
						},
					},
					inline = {
						adapter = "copilot_gemini",
					},
				},
				adapters = {
					copilot_sonnet = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "claude-3.5-sonnet",
								},
							},
						})
					end,
					copilot_gemini = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "gemini-2.5-pro",
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
					copilot_gpt41 = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "gpt-4.1",
								},
							},
						})
					end,
					openai = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = 'cmd:pass show "API/OpenAI API Key"',
							},
						})
					end,
				},
			})

			local wk = require("which-key")
			wk.add({
				{ "<leader>c", group = "Chat / AI", icon = "🤖" },
				{
					mode = { "n", "v" },
					nowait = true,
					remap = false,
					{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat" },
				},
				{
					mode = { "n" },
					nowait = true,
					remap = false,
					{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Chat" },
					{ "<leader>cx", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
				},
				{
					mode = { "v" },
					nowait = true,
					remap = false,
					{ "<leader>ci", ":'<,'>CodeCompanion<cr>", desc = "Inline assist" },
				},
			})
		end,
	},
	-- {
	-- 	"augmentcode/augment.vim",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		vim.g.augment_disable_tab_mapping = true
	-- 		vim.g.augment_workspace_folders = workspace_folders
	--
	-- 		local wk = require("which-key")
	-- 		wk.add({
	-- 			{ "<leader>ca", group = "Augment Code", icon = "󰘦 " },
	-- 			{
	-- 				mode = { "n" },
	-- 				nowait = true,
	-- 				remap = false,
	-- 				{ "<leader>cac", "<cmd>Augment chat<cr>", desc = "Send chat" },
	-- 				{ "<leader>can", "<cmd>Augment chat-new<cr>", desc = "New conversation" },
	-- 				{ "<leader>cat", "<cmd>Augment chat-toggle<cr>", desc = "Toggle" },
	-- 			},
	-- 			{
	-- 				mode = { "i" },
	-- 				nowait = true,
	-- 				remap = false,
	-- 				{ "<c-y>", "<cmd>call augment#Accept()<cr>", desc = "Accept" },
	-- 			},
	-- 		})
	-- 	end,
	-- },
}
