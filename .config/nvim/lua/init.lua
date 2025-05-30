if vim.g.vscode then
	require("core.keymaps")
else
	require("core.lazy")
	require("core.options")
	require("core.autocmd")
	require("core.keymaps")
end
