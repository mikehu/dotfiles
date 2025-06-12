return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local oil = require("oil")
			local detail = false
			local hidden_files = {}
			local always_hidden_files = {
				".git",
				"node_modules",
			}

			oil.setup({
				default_file_explorer = true,
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
					natural_order = true,
					is_hidden_file = function(name, _)
						return vim.startswith(name, ".") or vim.tbl_contains(hidden_files, name)
					end,
					is_always_hidden = function(name, _)
						return name == ".." or vim.tbl_contains(always_hidden_files, name)
					end,
				},
				win_options = {
					signcolumn = "yes:2",
				},
				keymaps = {
					["<C-l>"] = false,
					["<C-h>"] = false,
					["<C-r>"] = "actions.refresh",
					["gd"] = {
						desc = "Toggle file detail view",
						callback = function()
							detail = not detail
							if detail then
								oil.set_columns({ "icon", "permissions", "size", "mtime" })
							else
								oil.set_columns({ "icon" })
							end
						end,
					},
					["gC"] = {
						desc = "Send to Claude Code",
						callback = function()
							if vim.fn.exists(":ClaudeCodeAdd") ~= 2 then
								vim.notify("ClaudeCode isn't active!", vim.log.levels.WARN)
								return
							end
							local entry = oil.get_cursor_entry()
							local dir = oil.get_current_dir()
							if not entry or not dir then
								return
							end
							if entry.type ~= "file" then
								return
							end
							local file = dir .. entry.name
							vim.cmd("ClaudeCodeAdd " .. file)
						end,
					},
				},
			})

			vim.keymap.set("n", "-", [[<cmd>Oil<cr>]], { desc = " Open parent directory" })
			vim.keymap.set("n", "cd", function()
				local oil_dir = oil.get_current_dir()
				if oil_dir then
					vim.cmd("lcd " .. oil_dir)
				else
					vim.cmd("lcd %:p:h")
				end
			end, { desc = " Change workdir" })

			vim.api.nvim_create_autocmd("User", {
				pattern = "OilActionsPost",
				callback = function(event)
					if event.data.actions.type == "move" then
						Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
					end
				end,
			})
		end,
	},
	{
		"refractalize/oil-git-status.nvim",
		dependencies = {
			"stevearc/oil.nvim",
		},
		config = true,
	},
}
