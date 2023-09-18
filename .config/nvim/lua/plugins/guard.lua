return {
	"nvimdev/guard.nvim",
	dependencies = {
		"nvimdev/guard-collection",
	},
	config = function()
		local ft = require("guard.filetype")

		ft("lua"):fmt("stylua")

		ft("javascript"):fmt("prettier")

		require("guard").setup({
			fmt_on_save = true,
		})
	end,
}
