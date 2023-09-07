return {
	"shellRaining/hlchunk.nvim",
	event = { "UIEnter" },
	config = function()
		require("hlchunk").setup({
			chunk = {
				style = {
					vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Structure")), "fg", "gui"),
					vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Error")), "fg", "gui"),
				},
			},
			indent = {
				enable = false,
			},
			line_num = {
				use_treesitter = true,
				style = {
					vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("CursorLineNr")), "fg", "gui"),
				},
			},
			blank = {
				enable = false,
			},
		})
	end,
}
