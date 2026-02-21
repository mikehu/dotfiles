return {
	{
		"nvim-mini/mini.diff",
		event = "VeryLazy",
		keys = {
			{ "<leader>gd", function() MiniDiff.toggle_overlay() end, desc = "Toggle diff overlay" },
			{
				"<leader>gD",
				function()
					local presets = { "HEAD", "HEAD~1", "HEAD~3", "main", "origin/main" }
					vim.ui.select(presets, { prompt = "Diff base (or Esc to enter manually)" }, function(choice)
						if choice then
							MiniDiff.set_ref_text(0, vim.fn.system({ "git", "show", choice .. ":" .. vim.fn.expand("%:.") }))
							vim.notify("Diff base: " .. choice)
							return
						end
						Snacks.input({ prompt = "Diff base (ref/hash, empty to reset): " }, function(input)
							if not input then
								return
							end
							if input == "" then
								-- Reset to git index by re-attaching the source
								MiniDiff.toggle()
								MiniDiff.toggle()
								vim.notify("Diff base: reset to index")
								return
							end
							local text = vim.fn.system({ "git", "show", input .. ":" .. vim.fn.expand("%:.") })
							if vim.v.shell_error ~= 0 then
								vim.notify("Invalid ref: " .. input, vim.log.levels.ERROR)
								return
							end
							MiniDiff.set_ref_text(0, text)
							vim.notify("Diff base: " .. input)
						end)
					end)
				end,
				desc = "Set diff base",
			},
		},
		opts = {
			view = {
				style = "number",
			},
		},
	},
	{
		"ahkohd/difft.nvim",
		events = "VeryLazy",
		keys = {
			{
				"<leader>ud",
				function()
					if Difft.is_visible() then
						Difft.hide()
					else
						local file = vim.fn.expand("%:p")
						local escaped = vim.fn.shellescape(file)
						-- Check if file is tracked by git
						local is_tracked = vim.fn.system("git ls-files -- " .. escaped):gsub("%s+$", "") ~= ""
						local cmd
						if is_tracked then
							cmd = "GIT_EXTERNAL_DIFF='difft --color=always' git diff -- " .. escaped
						else
							cmd = "difft --color=always /dev/null " .. escaped
						end
						Difft.diff({ cmd = cmd })
					end
				end,
				desc = "Difft (current file)",
			},
			{
				"<leader>uD",
				function()
					if Difft.is_visible() then
						Difft.hide()
					else
						Difft.diff()
					end
				end,
				desc = "Difft (all changes)",
			},
		},
		config = function()
			local difft = require("difft")
			difft.setup({
				command = "GIT_EXTERNAL_DIFF='difft --color=always' git diff",
				layout = "ivy_taller",
			})

			vim.api.nvim_create_autocmd("WinEnter", {
				callback = function()
					vim.schedule(function()
						if vim.bo.filetype == "difft" then
							vim.wo.cursorline = true
						end
					end)
				end,
			})
		end,
	},
}
