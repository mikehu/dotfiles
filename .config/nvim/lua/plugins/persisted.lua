return {
	"olimorris/persisted.nvim",
	config = function()
		require("persisted").setup({
			autosave = true,
			autoload = true,
			allowed_dirs = {
				"~/.dotfiles",
				"~/Code",
				"/Volumes/Pebble",
			},
			ignored_dirs = {
				"~/.config",
				"~/.local/nvim",
			},
		})

		vim.keymap.set("n", "<leader>ps", [[<cmd>SessionSave<cr>]], { desc = "Persist session" })
		vim.keymap.set(
			"n",
			"<leader>fp",
			[[<cmd>Telescope persisted theme=dropdown winblend=20<cr>]],
			{ desc = "Sessions" }
		)
	end,
}
