return {
	"j-hui/fidget.nvim",
	opts = {
		notification = {
			window = { relative = "win" },
		},
		progress = {
			display = {
				overrides = {
					chisel = { name = "⛏️", annote_style = "DiagnosticHint", info_style = "DiagnosticInfo" },
				},
			},
		},
	},
}
