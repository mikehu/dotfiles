return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	config = function()
		require("tiny-inline-diagnostic").setup({
			signs = {
				arrow = "    ",
				up_arrow = "    ",
				vertical = " │",
				vertical_end = " ╰",
			},
			options = {
				break_line = {
					enabled = true,
				},
			},
		})
	end,
}
