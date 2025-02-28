return {
	"folke/persistence.nvim",
	config = function()
		local persist = require("persistence")
		persist.setup({ need = 2 })

		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
			callback = function()
				if vim.fn.argc(-1) == 0 then
					persist.load()
				else
					persist.stop()
				end
			end,
			nested = true,
		})
	end,
}
