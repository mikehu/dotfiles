return {
	"mistweaverco/kulala.nvim",
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
				"<leader>Rt",
				function()
					k.toggle_view()
				end,
				desc = "Toggle body/headers",
			},
			{
				"<leader>RE",
				function()
					k.set_selected_env()
				end,
				desc = "Set selected env",
			},
		})
	end,
}
