local backend = require("chisel.backend.claude")
local extmarks = require("chisel.ui.extmarks")
local progress = require("fidget.progress")

local M = {}

--- Parse Claude's response: extract code from fenced block, separate out explanation text.
--- Fenced code block -> code to apply. No fence -> message only, no edit.
--- @param raw string The raw response text
--- @return { code: string|nil, message: string|nil }
local function parse_response(raw)
	-- Find opening fence: ```lang\n
	local fence_start, fence_open_end = raw:find("```%w*\n")
	if not fence_start then
		return { code = nil, message = vim.trim(raw) }
	end

	-- Find closing fence: \n``` (not anchored to end — Claude may add text after)
	local fence_close_start = raw:find("\n```", fence_open_end, true)
	if not fence_close_start then
		return { code = nil, message = vim.trim(raw) }
	end

	local code = raw:sub(fence_open_end + 1, fence_close_start - 1)
	local before = vim.trim(raw:sub(1, fence_start - 1))
	local after = vim.trim(raw:sub(fence_close_start + 4)) -- skip past \n```

	local parts = {}
	if before ~= "" then table.insert(parts, before) end
	if after ~= "" then table.insert(parts, after) end
	local explanation = table.concat(parts, "\n")

	-- Heuristic: if explanation text is longer than the code block,
	-- this is an explanatory response with illustrative snippets, not a replacement.
	if #explanation > #code then
		return { code = nil, message = vim.trim(raw) }
	end

	local message = #parts > 0 and explanation or nil
	return { code = code, message = message }
end

--- Find the narrowest range that actually changed between old and new line arrays.
--- Returns 0-indexed start, end for use with nvim_buf_set_lines.
--- @param old_lines string[]
--- @param new_lines string[]
--- @param buf_start number 0-indexed buffer offset where old_lines begin
--- @return number start 0-indexed start line in buffer
--- @return number end_ 0-indexed end line in buffer (exclusive)
--- @return string[] changed The new lines to insert
local function anchored_range(old_lines, new_lines, buf_start)
	-- Find common prefix
	local prefix = 0
	local max_prefix = math.min(#old_lines, #new_lines)
	while prefix < max_prefix and old_lines[prefix + 1] == new_lines[prefix + 1] do
		prefix = prefix + 1
	end

	-- Find common suffix (but don't overlap with prefix)
	local suffix = 0
	local max_suffix = math.min(#old_lines - prefix, #new_lines - prefix)
	while suffix < max_suffix and old_lines[#old_lines - suffix] == new_lines[#new_lines - suffix] do
		suffix = suffix + 1
	end

	-- Extract only the changed portion
	local changed = {}
	for i = prefix + 1, #new_lines - suffix do
		table.insert(changed, new_lines[i])
	end

	return buf_start + prefix, buf_start + #old_lines - suffix, changed
end

--- @class ChiselSession
--- @field ctx table Selection context
--- @field prompt string User instruction
--- @field job_id number|nil
--- @field extmark_state ChiselExtmarkState|nil
--- @field fidget_handle table|nil Fidget progress handle
--- @field result_text string Accumulated response text
--- @field done boolean

--- Create and start a new chisel session.
--- @param ctx table The selection context from context.lua
--- @param prompt string The user's instruction
--- @return ChiselSession
function M.start(ctx, prompt)
	local session = {
		ctx = ctx,
		prompt = prompt,
		job_id = nil,
		extmark_state = nil,
		fidget_handle = nil,
		result_text = "",
		done = false,
	}

	-- Auto-save buffer for file mode (Claude edits on disk)
	if ctx.mode == "file" then
		if vim.api.nvim_buf_is_valid(ctx.bufnr) then
			vim.api.nvim_buf_call(ctx.bufnr, function()
				vim.cmd("silent write")
			end)
		end
	end

	-- Start spinners on the selection (inline modes only)
	if ctx.mode ~= "file" then
		session.extmark_state = extmarks.show(ctx)
	end

	-- Start fidget progress
	session.fidget_handle = progress.handle.create({
		title = "chisel",
		message = "Starting...",
		lsp_client = { name = "chisel" },
	})

	-- Spawn claude
	session.job_id = backend.spawn(prompt, ctx, {
		on_thinking = function(text)
			vim.schedule(function()
				if session.fidget_handle then
					-- Show last line of thinking
					local last = ""
					for line in text:gmatch("[^\n]+") do
						last = line
					end
					last = vim.trim(last)
					if #last > 80 then
						last = last:sub(1, 79) .. "…"
					end
					session.fidget_handle.message = last
				end
			end)
		end,
		on_text = function(text)
			session.result_text = text
			vim.schedule(function()
				if session.fidget_handle then
					local line_count = select(2, text:gsub("\n", "\n")) + 1
					session.fidget_handle.message = "Writing... (" .. line_count .. " lines)"
				end
			end)
		end,
		on_done = function(_)
			vim.schedule(function()
				session.done = true

				-- Clean up UI
				if session.extmark_state then
					extmarks.hide(session.extmark_state, ctx.bufnr)
					session.extmark_state = nil
				end

				if ctx.mode == "file" then
					-- File mode: Claude edited on disk, reload buffer
					if session.fidget_handle then
						session.fidget_handle.message = "Done"
						session.fidget_handle:finish()
						session.fidget_handle = nil
					end

					if vim.api.nvim_buf_is_valid(ctx.bufnr) then
						vim.api.nvim_buf_call(ctx.bufnr, function()
							vim.cmd("edit")
						end)
					end

					local text = vim.trim(session.result_text)
					if text ~= "" then
						Snacks.notify.info(text, { title = "chisel", timeout = 15000 })
					end
					return
				end

				-- Inline mode: parse response and apply to buffer
				local result = parse_response(session.result_text)

				if session.fidget_handle then
					if result.code then
						session.fidget_handle.message = "Done"
					else
						session.fidget_handle.message = "No changes"
					end
					session.fidget_handle:finish()
					session.fidget_handle = nil
				end

				if result.message then
					Snacks.notify.info(result.message, { title = "chisel", timeout = 15000 })
				end

				if not result.code then
					return
				end

				local new_lines = vim.split(result.code, "\n", { plain = true })
				if #new_lines == 0 or (#new_lines == 1 and new_lines[1] == "") then
					return
				end

				if ctx.mode == "insert" then
					vim.api.nvim_buf_set_lines(ctx.bufnr, ctx.end_line, ctx.end_line, false, new_lines)
				else
					-- Anchor: only replace the lines that actually changed
					local start, end_, changed = anchored_range(ctx.lines, new_lines, ctx.start_line - 1)
					vim.api.nvim_buf_set_lines(ctx.bufnr, start, end_, false, changed)
				end
			end)
		end,
		on_error = function(msg)
			vim.schedule(function()
				session.done = true
				if session.extmark_state then
					extmarks.hide(session.extmark_state, ctx.bufnr)
					session.extmark_state = nil
				end
				if session.fidget_handle then
					session.fidget_handle.message = "Error"
					session.fidget_handle:finish()
					session.fidget_handle = nil
				end
				vim.notify("chisel: " .. msg, vim.log.levels.ERROR)
			end)
		end,
	})

	if not session.job_id then
		if session.extmark_state then
			extmarks.hide(session.extmark_state, ctx.bufnr)
		end
		if session.fidget_handle then
			session.fidget_handle.message = "Failed to start"
			session.fidget_handle:finish()
		end
		return session
	end

	return session
end

--- Abort a running session.
--- @param session ChiselSession
function M.abort(session)
	if session.done then
		return
	end
	session.done = true

	if session.job_id then
		backend.stop(session.job_id)
		session.job_id = nil
	end

	if session.extmark_state then
		extmarks.hide(session.extmark_state, session.ctx.bufnr)
		session.extmark_state = nil
	end

	if session.fidget_handle then
		session.fidget_handle.message = "Cancelled"
		session.fidget_handle:finish()
		session.fidget_handle = nil
	end
end

return M
