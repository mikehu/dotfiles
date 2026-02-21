local backend = require("chisel.backend.claude")
local extmarks = require("chisel.ui.extmarks")
local progress = require("fidget.progress")

local M = {}

--- Last response text from a completed session (for :ChiselReview).
--- @type string|nil
M.last_response = nil

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

	-- Auto-save buffer so Claude edits match what the user sees
	if vim.api.nvim_buf_is_valid(ctx.bufnr) then
		vim.api.nvim_buf_call(ctx.bufnr, function()
			vim.cmd("silent write")
		end)
	end

	-- Start spinners on the selection (visual mode only)
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
		end,
		on_done = function(_)
			vim.schedule(function()
				session.done = true

				-- Clean up spinners
				if session.extmark_state then
					extmarks.hide(session.extmark_state, ctx.bufnr)
					session.extmark_state = nil
				end

				-- Finish fidget
				if session.fidget_handle then
					session.fidget_handle.message = "Done"
					session.fidget_handle:finish()
					session.fidget_handle = nil
				end

				-- Reload buffer from disk (Claude edited via Edit tool)
				if vim.api.nvim_buf_is_valid(ctx.bufnr) then
					vim.api.nvim_buf_call(ctx.bufnr, function()
						vim.cmd("edit")
					end)
				end

				-- Store for :ChiselReview
				local text = vim.trim(session.result_text)
				M.last_response = text ~= "" and text or nil

				-- Show commentary as notification
				if M.last_response then
					Snacks.notify.info(M.last_response, { title = "chisel", timeout = 15000 })
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
