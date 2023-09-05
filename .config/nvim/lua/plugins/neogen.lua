return {
	"danymat/neogen",
	event = "VeryLazy",
	dependencies = "nvim-treesitter/nvim-treesitter",
	version = "*",
	config = function()
		require("neogen").setup({
			enabled = true,
			input_after_comment = true,
			snippet_engine = "luasnip",
		})

		vim.keymap.set("n", "gcn", [[<cmd>Neogen<cr>]], { desc = "Neogen" })
	end,
}
