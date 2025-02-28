return {
	"folke/persistence.nvim",
	config = function()
		local persist = require("persistence")
		persist.setup({ need = 2 })

		local group = vim.api.nvim_create_augroup("PersistEvents", { clear = true })
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			callback = function()
				if vim.fn.argc(-1) == 0 then
					vim.api.nvim_exec_autocmds("User", { pattern = "PersistEnter" })
				else
					persist.stop()
				end
			end,
			once = true,
		})
	end,
}
