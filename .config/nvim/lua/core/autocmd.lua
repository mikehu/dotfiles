-- local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Terminal
autocmd("TermOpen", {
	command = "setlocal listchars= nonumber norelativenumber nocursorline",
})
autocmd("TermOpen", {
	pattern = "",
	command = "startinsert",
})
autocmd("BufLeave", {
	pattern = "term://*",
	command = "stopinsert",
})
autocmd("BufWinEnter", {
	pattern = "term://*",
	command = "setlocal listchars= nonumber norelativenumber nocursorline",
})
