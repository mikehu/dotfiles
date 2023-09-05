return {
	{
		"willothy/flatten.nvim",
		config = true,
		-- or pass configuration with
		-- opts = {  }
		-- Ensure that it runs first to minimize delay when opening file from terminal
		lazy = false,
		priority = 1001,
	},
	{
		"boltlessengineer/bufterm.nvim",
		config = function()
			require("bufterm").setup()

			-- Terminal mappings
			vim.keymap.set("n", "<m-esc>", [[<cmd>terminal<cr>]])
			vim.keymap.set("t", "<m-esc>", [[<cmd>:bd!<cr>]])
			vim.keymap.set("t", "<m-tab>", [[<cmd>:bnext<cr>]])
			vim.keymap.set("t", "<m-s-tab>", [[<cmd>:bprev<cr>]])
			vim.keymap.set("t", "<c-n>", [[<c-\><c-n>]])

			-- Lazygit Terminal
			local Terminal = require("bufterm.terminal").Terminal
			local ui = require("bufterm.ui")

			local lazygit = Terminal:new({
				cmd = "lazygit",
				buflisted = false,
				termlisted = false, -- set this option to false if you treat this terminal as single independent terminal
			})
			vim.keymap.set("n", "<leader>l", function()
				-- spawn terminal (terminal won't be spawned if self.jobid is valid)
				lazygit:spawn()
				-- open floating window
				ui.toggle_float(lazygit.bufnr)
			end, {
				desc = "Open lazygit window",
			})
		end,
	},
}
