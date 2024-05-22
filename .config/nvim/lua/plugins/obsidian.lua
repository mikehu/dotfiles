return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	-- ft = "markdown",
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
		"BufReadPre "
			.. vim.fn.expand("~")
			.. "/Nextcloud/obsidian-vaults/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/Nextcloud/obsidian-vaults/**.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "ThoughtQuarry",
				path = "~/Nextcloud/obsidian-vaults/ThoughtQuarry",
			},
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		disable_frontmatter = true,
		mappings = {
			-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			-- Smart action depending on context, either follow link or toggle checkbox.
			["<c-x>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
	},
}
