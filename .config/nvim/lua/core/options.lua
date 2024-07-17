local opt = vim.opt

opt.rtp:append("/opt/homebrew/opt/fzf")

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false

-- Diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- vim.diagnostic.config({
-- 	virtual_text = {
-- 		prefix = "●", -- Could be '●', '▎', 'x'
-- 	},
-- })

vim.diagnostic.config({
	virtual_text = false,
})

vim.filetype.add({
	extension = {
		["http"] = "http",
	},
})
