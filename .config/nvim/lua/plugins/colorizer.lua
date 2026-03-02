return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			parsers = {
				rgb = { enable = true },
				tailwind = { enable = true, lsp = true, update_names = true },
			},
		},
	},
}
