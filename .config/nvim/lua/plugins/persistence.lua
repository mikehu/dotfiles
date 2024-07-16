return {
	"folke/persistence.nvim",
	config = function()
		local persist = require("persistence")
		persist.setup({})

		-- local wk = require("which-key")
		-- wk.add({
		-- 	"<leader>PL",
		-- 	function()
		-- 		persist.load()
		-- 	end,
		-- 	desc = "Load last session",
		-- })

		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
			callback = function()
				if vim.fn.argc(-1) == 0 then
					persist.load()
				end
			end,
			nested = true,
		})
	end,
}
