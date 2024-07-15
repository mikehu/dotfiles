return {
	"stevearc/oil.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local oil = require("oil")
		local detail = false

		oil.setup({
			default_file_explorer = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				natural_order = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git"
				end,
			},
			keymaps = {
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
			},
		})

		vim.keymap.set("n", "-", [[<cmd>Oil<cr>]], { desc = " Open parent directory" })
		vim.keymap.set("n", "<leader>E", [[<cmd>Oil --float<cr>]], { desc = " File explorer" })
		vim.keymap.set("n", "cd", function()
			local oil_dir = oil.get_current_dir()
			if oil_dir then
				vim.cmd("lcd " .. oil_dir)
			else
				vim.cmd("lcd %:p:h")
			end
		end, { desc = " Change workdir" })
	end,
}
