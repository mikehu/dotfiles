return {
	{
		"robitx/gp.nvim",
		event = "VeryLazy",
		config = function()
			require("gp").setup({
				providers = {
					copilot = {
						endpoint = "https://api.githubcopilot.com/chat/completions",
						secret = {
							"bash",
							"-c",
							"cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
						},
					},
				},
				chat_template = require("gp.defaults").short_chat_template,
				chat_confirm_delete = false,
				chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>r" },
				chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
				chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
				chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
			})

			local wk = require("which-key")
			wk.add({
				{ "<leader>c", group = "Chat / AI", icon = "🤖" },
				{
					mode = { "n" },
					nowait = true,
					remap = false,
					{ "<leader>cc", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
					{ "<leader>cn", "<cmd>GpChatNew<cr>", desc = "New Chat" },
					{ "<leader>cf", "<cmd>GpChatFinder<cr>", desc = "Find Chat" },
					{ "<leader>cx", "<cmd>GpContext<cr>", desc = "Toggle context" },
					{ "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append response" },
					{ "<C-g>p", "<cmd>GpPrepend<cr>", desc = "Prepend response" },
					{ "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Rewrite line" },
				},
				{
					mode = { "v" },
					nowait = true,
					remap = false,
					{ "<leader>cc", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
					{ "<leader>cf", "<cmd>GpChatFinder<cr>", desc = "Find Chat" },
					{ "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Append response" },
					{ "<C-g>p", ":<C-u>'<,'>GpPrepend<cr>", desc = "Prepend response" },
					{ "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Rewrite selection" },
					{ "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
				},
			})
		end,
	},
}
