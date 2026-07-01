vim.opt.rtp:append("/opt/homebrew/opt/fzf")

-- Native UI (Neovim 0.12+ ui2) — replaces noice.nvim.
-- cmdheight=0 hides the cmdline until you type : or / (lualine becomes the bottom row);
-- transient messages float in the bottom-right msg window instead of a cmdline row.
vim.o.cmdheight = 0
local ok, ui2 = pcall(require, "vim._core.ui2")
if ok then
	ui2.enable({
		msg = { targets = "msg" },
	})
end

-- Default border for all floats (LSP hover, signature, diagnostics). New in 0.12.
vim.opt.winborder = "rounded"

-- Show pending command/operator keys in the statusline (lualine renders %S).
vim.o.showcmdloc = "statusline"

vim.o.foldenable = false
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""

vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
		linehl = {
			[vim.diagnostic.severity.ERROR] = "Error",
			[vim.diagnostic.severity.WARN] = "Warn",
			[vim.diagnostic.severity.INFO] = "Info",
			[vim.diagnostic.severity.HINT] = "Hint",
		},
	},
})

vim.filetype.add({
	extension = {
		["http"] = "http",
		["plist"] = "xml",
	},
})
