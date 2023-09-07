return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true, -- enable treesitter
		ts_config = {
			lua = { "string" }, -- don't add pairs in lua string treesitter nodes
			javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
		},
		disable_filetype = { "TelescopePrompt", "spectre_panel", "vim" },
	},
}