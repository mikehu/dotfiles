local TextType = {
	BUFFER = "%",
	LINE = ".",
}

local function is_selecting()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local line_start, col_start = start_pos[2], start_pos[3]
	local line_end, col_end = end_pos[2], end_pos[3]

	return line_start ~= line_end or col_start ~= col_end
end

local function cmd_on_text(cmd, external, type)
	type = type or TextType.LINE
	if external == nil then
		external = false
	end
	if external then
		cmd = "!" .. cmd
	end
	if is_selecting() then
		return "'<,'>" .. cmd
	else
		return type .. cmd
	end
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
			mode = { "n", "x" },
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
					safe_vim_cmd(cmd_on_text("s/\\\\\\//\\//g"))
				end,
			},
			{
				name = "Base64 encode",
				execute = function()
					safe_vim_cmd(cmd_on_text("base64", true))
				end,
			},
			{
				name = "Base64 decode",
				execute = function()
					safe_vim_cmd(cmd_on_text("base64 --decode", true))
				end,
			},
			{
				name = "URL encode",
				execute = function()
					safe_vim_cmd(cmd_on_text("perl -MURI::Escape -ne 'print uri_escape($_)'", true))
				end,
			},
			{
				name = "URL decode",
				execute = function()
					safe_vim_cmd(cmd_on_text("perl -MURI::Escape -ne 'print uri_unescape($_)' | tr -d '\\n'", true))
				end,
			},
		},
	},
}
