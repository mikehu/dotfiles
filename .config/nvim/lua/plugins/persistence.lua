return {
	"folke/persistence.nvim",
	config = function()
		local persist = require("persistence")
		persist.setup({
			need = 2,
		})

		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("PersistenceRestoreSession", { clear = true }),
			callback = function()
				if vim.fn.argc(-1) == 0 then
					vim.defer_fn(function()
						persist.load()
					end, 0) -- 0ms delay is usually enough, just "next tick"
				else
					persist.stop()
				end
			end,
			nested = true,
		})
	end,
}
