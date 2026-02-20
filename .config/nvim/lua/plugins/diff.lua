return {
	"ahkohd/difft.nvim",
	events = "VeryLazy",
	keys = {
		{
			"<leader>ud",
			function()
				if Difft.is_visible() then
					Difft.hide()
				else
					local file = vim.fn.expand("%:p")
					local escaped = vim.fn.shellescape(file)
					-- Check if file is tracked by git
					local is_tracked = vim.fn.system("git ls-files -- " .. escaped):gsub("%s+$", "") ~= ""
					local cmd
					if is_tracked then
						cmd = "GIT_EXTERNAL_DIFF='difft --color=always' git diff -- " .. escaped
					else
						cmd = "difft --color=always /dev/null " .. escaped
					end
					Difft.diff({ cmd = cmd })
				end
			end,
			desc = "Difft (current file)",
		},
		{
			"<leader>uD",
			function()
				if Difft.is_visible() then
					Difft.hide()
				else
					Difft.diff()
				end
			end,
			desc = "Difft (all changes)",
		},
	},
	config = function()
		local difft = require("difft")
		difft.setup({
			command = "GIT_EXTERNAL_DIFF='difft --color=always' git diff",
			layout = "ivy_taller",
		})

		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				vim.schedule(function()
					if vim.bo.filetype == "difft" then
						vim.wo.cursorline = true
					end
				end)
			end,
		})
	end,
}
