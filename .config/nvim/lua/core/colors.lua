local dracula_status, dracula = pcall(require, "dracula")
if not dracula_status then
	return
end

dracula.setup({
	on_highlights = function(colors, color)
		return {
			CursorLine = { bg = colors.bgdark },
			CursorLineNr = { fg = colors.fg },
			IndentBlanklineSpaceChar = { fg = colors.comment },
		}
	end,
})

vim.cmd.colorscheme("dracula")
-- vim.cmd.colorscheme("dracula-soft")
