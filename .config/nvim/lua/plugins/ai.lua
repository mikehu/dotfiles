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
		"ravitemer/mcphub.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
		},
		build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
		config = function()
			require("mcphub").setup({
				-- Required options
				port = 3600, -- Port for MCP Hub server
				config = vim.fn.expand("~/.config/mcpservers.json"), -- Absolute path to config file
				-- Optional options
				on_ready = function(hub)
					-- Called when hub is ready
				end,
				on_error = function(err)
					-- Called on errors
				end,
				shutdown_delay = 0, -- Wait 0ms before shutting down server after last client exits
				log = {
					level = vim.log.levels.WARN,
					to_file = false,
					file_path = nil,
					prefix = "MCPHub",
				},
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
			"ravitemer/mcphub.nvim",
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
								description = "Select a file",
								opts = {
									provider = "snacks", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
									contains_code = true,
								},
							},
							["buffer"] = {
								opts = {
									provider = "snacks",
								},
							},
						},
						tools = {
							["mcp"] = {
								callback = function()
									return require("mcphub.extensions.codecompanion")
								end,
								description = "Call tools and resources from the MCP Servers",
								opts = {
									requires_approval = true,
								},
							},
						},
					},
					inline = {
						adapter = "copilot_o3",
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
					mode = { "n" },
					nowait = true,
					remap = false,
					{ "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat" },
					{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Chat" },
					{ "<leader>cx", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
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
