return {
	{
		"mistweaverco/kulala.nvim",
		event = "VeryLazy",
		config = function()
			local k = require("kulala")
			-- Setup is required, even if you don't pass any options
			k.setup({
				debug = false,
			})

			local wk = require("which-key")
			wk.add({
				{ "<leader>R", group = "REST Http", icon = "󰘯 " },
				{
					"<leader>Rr",
					function()
						k.run()
					end,
					desc = "Run",
				},
				{
					"<leader>Ri",
					function()
						k.inspect()
					end,
					desc = "Inspect",
				},
				{
					"<leader>Rt",
					function()
						k.toggle_view()
					end,
					desc = "Toggle body/headers",
				},
				{
					"<leader>Re",
					function()
						k.set_selected_env()
					end,
					desc = "Set selected env",
				},
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "http", -- Match only .http files
				callback = function()
					vim.api.nvim_buf_set_keymap(
						0,
						"n",
						"<c-p>",
						"<cmd>lua require('kulala').jump_prev()<cr>",
						{ noremap = true, silent = true }
					)
					vim.api.nvim_buf_set_keymap(
						0,
						"n",
						"<c-n>",
						"<cmd>lua require('kulala').jump_next()<cr>",
						{ noremap = true, silent = true }
					)
				end,
			})
		end,
	},
	-- {
	-- 	"rest-nvim/rest.nvim",
	-- 	config = function()
	-- 		vim.g.rest_nvim = {}
	--
	-- 		local wk = require("which-key")
	-- 		wk.add({
	-- 			{ "<leader>R", group = "REST Http", icon = "󰘯 " },
	-- 			{
	-- 				"<leader>Ro",
	-- 				[[<cmd>Rest open<cr>]],
	-- 				desc = "Open pane",
	-- 			},
	-- 			{
	-- 				"<leader>Rr",
	-- 				[[<cmd>Rest run<cr>]],
	-- 				desc = "Run",
	-- 			},
	-- 			{
	-- 				"<leader>Rl",
	-- 				[[<cmd>Rest logs<cr>]],
	-- 				desc = "Show logs",
	-- 			},
	-- 			{
	-- 				"<leader>Rc",
	-- 				[[<cmd>Rest logs<cr>]],
	-- 				desc = "Edit cookies",
	-- 			},
	-- 			{
	-- 				"<leader>Re",
	-- 				[[<cmd>Rest env select]],
	-- 				desc = "Select env",
	-- 			},
	-- 		})
	-- 	end,
	-- },
}
