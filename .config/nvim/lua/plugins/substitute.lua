return {
	"chrisgrieser/nvim-rip-substitute",
	event = "VeryLazy",
	cmd = "RipSubstitue",
	opts = {
		popupWin = {
			title = "  rip-substitute",
			border = "rounded",
			hideKeymapHints = true,
		},
		keymaps = {
			insertModeConfirmAndSubstituteInBuffer = "<C-r>",
		},
		notification = {
			icon = " ",
		},
	},
	keys = {
		{
			mode = { "n", "x" },
			"<leader>%",
			function()
				require("rip-substitute").sub()
			end,
			desc = "  Rip substitute",
		},
	},
}
