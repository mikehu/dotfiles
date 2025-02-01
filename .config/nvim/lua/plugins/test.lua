return {
	"vim-test/vim-test",
	event = "VeryLazy",
	-- dependencies = { "folke/snacks.nvim" },
	config = function()
		-- local function RunTestWithSnacks(cmd)
		-- 	Snacks.terminal.open(cmd, {
		-- 		win = { style = "test" },
		-- 	})
		-- 	print(cmd)
		-- end
		--
		-- vim.g["test#custom_strategies"] = { snacks = RunTestWithSnacks }
		vim.g["test#strategy"] = "neovim"
	end,
}
