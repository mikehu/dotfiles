return {
	"vim-test/vim-test",
	event = "VeryLazy",
	config = function()
		vim.cmd('let test#strategy = "neovim_sticky"')
	end,
}
