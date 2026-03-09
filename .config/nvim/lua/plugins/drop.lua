return {
	{
		name = "drop",
		dir = vim.fn.stdpath("config") .. "/lua/drop",
		event = "VeryLazy",
		config = function()
			require("drop").setup({
				allowed_roots = { "~/Code", "~/Downloads", "/Volumes/Pebble" },
			})
		end,
	},
}
