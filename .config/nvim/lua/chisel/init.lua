local config = require("chisel.config")
local context = require("chisel.context")
local session = require("chisel.session")

local M = {}

--- @type ChiselSession|nil
local active_session = nil

--- Prompt for instruction and start a session with the given context.
--- @param ctx table
local function prompt_and_start(ctx)
	-- Place cursor at the context line so the input anchors there
	vim.api.nvim_win_set_cursor(0, { ctx.start_line, 0 })

	Snacks.input({
		prompt = "chisel> ",
		win = { relative = "cursor", row = -1, col = 0 },
	}, function(instruction)
		if not instruction or instruction == "" then
			return
		end

		-- Abort any existing session before starting a new one
		if active_session and not active_session.done then
			session.abort(active_session)
		end

		active_session = session.start(ctx, instruction)
	end)
end

--- Start a chisel session from a visual selection.
--- @param line1 number 1-indexed start line (from command range)
--- @param line2 number 1-indexed end line (from command range)
function M.start(line1, line2)
	local ctx = context.capture(line1, line2)
	if #ctx.lines == 0 then
		vim.notify("chisel: no selection", vim.log.levels.WARN)
		return
	end
	prompt_and_start(ctx)
end

--- Start a chisel session for whole-file editing (normal mode).
function M.start_file()
	local ctx = context.capture_file()
	prompt_and_start(ctx)
end

--- Abort the current active session.
function M.abort()
	if active_session and not active_session.done then
		session.abort(active_session)
		vim.notify("chisel: aborted", vim.log.levels.INFO)
	end
end

--- Setup chisel with optional config overrides and register commands.
--- @param opts? table
function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("Chisel", function(cmd_opts)
		M.start(cmd_opts.line1, cmd_opts.line2)
	end, { range = true, desc = "Chisel inline edit" })

	vim.api.nvim_create_user_command("ChiselFile", function()
		M.start_file()
	end, { desc = "Chisel file edit" })

	vim.api.nvim_create_user_command("ChiselAbort", function()
		M.abort()
	end, { desc = "Abort chisel session" })
end

return M
