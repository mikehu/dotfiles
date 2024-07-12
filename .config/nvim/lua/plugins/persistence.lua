return {
	"folke/persistence.nvim",
	config = function()
		local persist = require("persistence")
		persist.setup({})

		local wk = require("which-key")
		wk.add({
			"<leader>pL",
			function()
				persist.load()
			end,
			{ desc = "Load last session" },
		})

		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				if vim.fn.argc(-1) == 0 then
					persist.load()
				end
			end,
		})
	end,
}
