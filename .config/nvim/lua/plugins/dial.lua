return {
	"monaqa/dial.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
	},
	config = function()
		local dial_map = require("dial.map")
		vim.keymap.set("n", "<C-a>", function()
			dial_map.manipulate("increment", "normal")
		end)
		vim.keymap.set("n", "<C-x>", function()
			dial_map.manipulate("decrement", "normal")
		end)
		vim.keymap.set("n", "g<C-a>", function()
			dial_map.manipulate("increment", "gnormal")
		end)
		vim.keymap.set("n", "g<C-x>", function()
			dial_map.manipulate("decrement", "gnormal")
		end)
		vim.keymap.set("v", "<C-a>", function()
			dial_map.manipulate("increment", "visual")
		end)
		vim.keymap.set("v", "<C-x>", function()
			dial_map.manipulate("decrement", "visual")
		end)
		vim.keymap.set("v", "g<C-a>", function()
			dial_map.manipulate("increment", "gvisual")
		end)
		vim.keymap.set("v", "g<C-x>", function()
			dial_map.manipulate("decrement", "gvisual")
		end)

		local augend = require("dial.augend")
		require("dial.config").augends:register_group({
			default = {
				augend.integer.alias.decimal,
				augend.integer.alias.hex,
				augend.constant.alias.bool,
				augend.hexcolor.new({
					case = "prefer_upper",
				}),
				augend.semver.alias.semver,
			},
		})
	end,
}
