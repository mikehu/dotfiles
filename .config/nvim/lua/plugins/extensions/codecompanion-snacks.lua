local M = {}

function M:init()
	local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local group = vim.api.nvim_create_augroup("CodeCompanionStatusHooks", { clear = true })

	local watch_events = { "Started", "Finished", "Streaming" }

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanion*",
		group = group,
		callback = function(request)
			local should_notify = vim.iter(watch_events):any(function(event_suffix)
				return vim.endswith(request.match, event_suffix)
			end)

			if not should_notify then
				return
			end

			local msg = "[CodeCompanion] " .. request.match:gsub("CodeCompanion", "") .. "..."

			local is_in_progress = vim.endswith(request.match, "Started") or vim.endswith(request.match, "Streaming")

			vim.notify(msg, vim.log.levels.INFO, {
				timeout = 1000,
				id = "code_companion_status",
				title = "Code Companion Status",
				keep = function()
					return is_in_progress
				end,
				opts = function(notif)
					notif.icon = ""
					if is_in_progress then
						notif.icon = spinner[math.floor(vim.loop.hrtime() / (1e6 * 80)) % #spinner + 1]
					elseif vim.endswith(request.match, "Finished") then
						notif.icon = " "
					end
				end,
			})
		end,
	})
end

M.handles = {}

return M
