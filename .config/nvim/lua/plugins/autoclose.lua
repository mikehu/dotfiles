return {
	"m4xshen/autoclose.nvim",
	event = "InsertEnter",
	config = function()
		require("autoclose").setup({
			options = {
				disable_when_touch = true,
				disable_command_mode = true,
			},
		})
	end,
}
