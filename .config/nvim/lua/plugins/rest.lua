return {
	{
		"mistweaverco/kulala.nvim",
		event = "VeryLazy",
		ft = { "http", "rest" },
		config = function()
			local k = require("kulala")
			-- Setup is required, even if you don't pass any options
			k.setup({})

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
		end,
	},
}
