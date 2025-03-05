local function cmd_on_selection_or_line(cmd)
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then
		cmd = "'<,'>" .. cmd
	end
	return cmd
end

local function safe_vim_cmd(cmd)
	local success, err = pcall(function()
		vim.cmd(cmd)
	end)

	-- Suppress E486 (Pattern not found) but allow other errors to be printed
	if not success and err:match("E486") then
		return false -- Indicate that nothing was replaced
	elseif not success then
		vim.api.nvim_err_writeln("Error: " .. err)
	end

	return success
end

return {
	"DanWlker/toolbox.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>x",
			function()
				require("toolbox").show_picker()
			end,
			desc = "Toolbox",
		},
	},
	opts = {
		commands = {
			{
				name = "Unescape slashes",
				execute = function()
					safe_vim_cmd(cmd_on_selection_or_line("s/\\\\\\//\\//g"))
				end,
			},
		},
	},
}
