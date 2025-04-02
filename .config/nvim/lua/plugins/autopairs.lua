return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = true,
	opts = {
		disable_filetype = { "TelescopePrompt", "snacks_picker_input" },
		check_ts = true,
		ts_config = {
			lua = { "string" },
			javascript = { "template_string" },
		},
	},
}
