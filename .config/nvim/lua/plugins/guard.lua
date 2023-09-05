return {
	"nvimdev/guard.nvim",
	config = function()
		local ft = require("guard.filetype")

		ft("lua"):fmt("stylua")

		ft("javascript"):fmt("prettier")

		require("guard").setup({
			fmt_on_save = true,
		})
	end,
}
