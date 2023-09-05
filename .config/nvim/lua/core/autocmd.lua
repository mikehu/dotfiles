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

-- SyncTabWorkingDir

-- augroup("SyncTabWorkingDir", { clear = true })
-- autocmd("TabNewEntered", {
--   group = "SyncTabWorkingDir",
--   callback = function()
--     print(vim.fn.expand("t:%:p:h"))
--   end,
-- })
-- function! OnTabEnter(path)
--   if isdirectory(a:path)
--     let dirname = a:path
--   else
--     let dirname = fnamemodify(a:path, ":h")
--   endif
--   execute "tcd ". dirname
-- endfunction()
--
-- autocmd TabNewEntered * call OnTabEnter(expand("<amatch>"))
