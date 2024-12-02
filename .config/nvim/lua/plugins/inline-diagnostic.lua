return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	config = function()
		require("tiny-inline-diagnostic").setup({
			preset = "classic",
			signs = {
				arrow = "    ",
				up_arrow = "    ",
				vertical = " │",
				vertical_end = " ╰",
			},
		})
	end,
}
