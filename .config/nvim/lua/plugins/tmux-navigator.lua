return {
	"alexghergh/nvim-tmux-navigation",
	config = function()
		local nvim_tmux_nav = require("nvim-tmux-navigation")

		nvim_tmux_nav.setup({
			disable_when_zoomed = true, -- defaults to false
		})

		vim.keymap.set({ "n", "i", "t" }, "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
		vim.keymap.set({ "n", "i" }, "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
		vim.keymap.set({ "n", "i" }, "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
		vim.keymap.set({ "n", "i", "t" }, "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
	end,
}
