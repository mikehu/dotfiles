local dracula_status, dracula = pcall(require, "dracula")
if not dracula_status then
	return
end

local function custom(c)
	return {
		CursorLine = { bg = c.bgdark },
		CursorLineNr = { fg = c.fg },
		IndentBlanklineSpaceChar = { fg = c.comment },
	}
end

dracula.setup({
	override = custom,
})

vim.cmd.colorscheme("dracula")
