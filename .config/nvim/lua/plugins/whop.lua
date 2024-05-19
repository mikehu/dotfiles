return {
	"biozz/whop.nvim",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("whop").setup({})
	end,
}
