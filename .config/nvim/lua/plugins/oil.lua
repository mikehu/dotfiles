return {
	{
		"stevearc/oil.nvim",
		opts = {},
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local oil = require("oil")
			oil.setup({
				skip_confirm_for_simple_edits = true,
			})

			vim.keymap.set("n", "-", [[<cmd>Oil<cr>]], { desc = " Open parent directory" })
			vim.keymap.set("n", "<leader>E", [[<cmd>Oil --float<cr>]], { desc = " File explorer" })
			vim.keymap.set("n", "cd", function()
				local oil_dir = oil.get_current_dir()
				if oil_dir then
					vim.cmd("lcd " .. oil_dir)
				else
					vim.cmd("lcd %:p:h")
				end
			end, { desc = " Change workdir" })
		end,
	},
}
