-- Setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Get plugin files
local function get_plugins()
	local plugins = {}
	local plugin_path = vim.fn.stdpath("config") .. "/lua/plugins"
	local files = vim.fn.glob(plugin_path .. "/*.lua", false, true)

	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t:r")
		if not filename:match("^_") then
			table.insert(plugins, require("plugins." .. filename))
		end
	end

	return plugins
end

require("lazy").setup(get_plugins(), {
	install = {
		missing = true,
	},
	checker = {
		enabled = true,
		notify = false,
	},
})
