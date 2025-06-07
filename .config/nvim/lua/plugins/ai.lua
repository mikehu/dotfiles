local workspace_folders = {
	"~/Code/neurox",
	"~/Code/illustrious-industries",
	"~/Code/personal",
}

local plan_prompts = require("plugins.prompts.plan")

local prompt_library = {
	["Project Plan"] = {
		strategy = "workflow",
		description = "Draft a project plan in the form of a PRD to be referenced by AI",
		opts = {
			index = 3,
			short_name = "plan",
			is_default = true,
			is_slash_cmd = true,
			ignore_system_prompt = true,
		},
		prompts = {
			{
				{
					role = "system",
					content = plan_prompts.system_prompt,
					opts = {
						visible = false,
					},
				},
				{
					role = "user",
					opts = {
						auto_submit = false,
					},
					content = function()
						vim.g.codecompanion_auto_tool_mode = true
						return [[
Create a product requirements document as `PRD.md` using the @files tool based on the following:

This project is ... ]]
					end,
				},
			},
		},
	},
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
		"coder/claudecode.nvim",
		config = true,
		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		},
	},
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
			require("plugins.extensions.codecompanion-extmarks").setup()
		end,
		config = function()
			local codecompanion = require("codecompanion")
			codecompanion.setup({
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
							continue_last_chat = false,
							-- When chat is cleared with `gx` delete the chat from history
							delete_on_clearing_chat = true,
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
				prompt_library = prompt_library,
				strategies = {
					chat = {
						adapter = "copilot",
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
						adapter = "openai",
					},
				},
				adapters = {
					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "claude-sonnet-4",
								},
							},
						})
					end,
					openai = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = 'cmd:pass show "API/OpenAI API Key"',
							},
							schema = {
								model = {
									default = "gpt-4o-mini",
								},
							},
						})
					end,
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							env = {
								api_key = 'cmd:pass show "API/Claude API Key"',
							},
						})
					end,
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							env = {
								api_key = 'cmd:pass show "API/Gemini API Key"',
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
					{ "<leader>ct", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat" },
					{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Chat" },
					{ "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
				},
				{
					mode = { "v" },
					nowait = true,
					{ "<leader>ci", "<cmd>CodeCompanion<cr>", desc = "Inline assist" },
					{ "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "New Chat" },
				},
			})
		end,
	},
}
