return {
	"vim-test/vim-test",
	config = function()
		vim.cmd('let test#strategy = "neovim_sticky"')
	end,
}
