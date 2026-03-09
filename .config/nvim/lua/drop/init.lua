local config = require("drop.config")

local M = {}

--- Check if a path falls under any allowed root.
local function is_allowed(path)
	for _, root in ipairs(config.values.allowed_roots) do
		if path:sub(1, #root) == root then
			return true
		end
	end
	-- Also allow /tmp for scratch files
	if path:sub(1, 4) == "/tmp" then
		return true
	end
	return false
end

--- Try to resolve pasted text as a droppable path.
--- Returns (resolved_path, "file"|"directory") or nil.
local function resolve_drop_path(text)
	-- Strip surrounding whitespace and quotes (terminals sometimes quote paths with spaces)
	local cleaned = vim.trim(text)
	cleaned = cleaned:match("^[\"'](.+)[\"']$") or cleaned
	-- Unescape shell-escaped characters (e.g. "\ " -> " ")
	cleaned = cleaned:gsub("\\(.)", "%1")
	if not cleaned or cleaned == "" then
		return nil
	end

	-- Expand ~ to home dir
	if cleaned:sub(1, 1) == "~" then
		cleaned = vim.fn.expand("~") .. cleaned:sub(2)
	end

	-- Must look like an absolute path
	if cleaned:sub(1, 1) ~= "/" then
		return nil
	end

	-- Resolve to canonical path
	local resolved = vim.fn.resolve(cleaned)
	if resolved == "" then
		return nil
	end

	if not is_allowed(resolved) then
		return nil
	end

	if vim.fn.filereadable(resolved) == 1 then
		return resolved, "file"
	end

	if vim.fn.isdirectory(resolved) == 1 then
		return resolved, "directory"
	end

	return nil
end

function M.setup(opts)
	config.setup(opts)

	local default_paste = vim.paste
	local intercepted = false

	---@diagnostic disable-next-line: duplicate-set-field
	vim.paste = function(lines, phase)
		-- If we already intercepted a drop, swallow remaining phases
		if intercepted then
			if phase == -1 or phase == 1 or phase == 3 then
				intercepted = false
			end
			return true
		end

		-- Only intercept in normal mode
		local mode = vim.api.nvim_get_mode().mode
		if mode ~= "n" then
			return default_paste(lines, phase)
		end

		-- Check every phase for a file path (tmux can reorder phases)
		local text = table.concat(lines, "")

		local path, kind = resolve_drop_path(text)

		if path then
			intercepted = true
			vim.schedule(function()
				if kind == "directory" then
					vim.cmd("Oil " .. vim.fn.fnameescape(path))
				else
					vim.cmd("drop " .. vim.fn.fnameescape(path))
				end
				vim.notify("Dropped: " .. vim.fn.fnamemodify(path, ":~:."), vim.log.levels.INFO)
			end)
			return true
		end

		return default_paste(lines, phase)
	end
end

return M
