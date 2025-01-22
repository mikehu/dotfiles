return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		user_default_options = {
			rgb_fn = true,
			tailwind = "both",
			tailwind_opts = {
				update_names = true,
			},
		},
	},
}
