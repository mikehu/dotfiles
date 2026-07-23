return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({})

			require("nvim-treesitter").install({
				"bash",
				"c",
				"css",
				"diff",
				"git_rebase",
				"gleam",
				"go",
				"gomod",
				"gosum",
				"html",
				"http",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"rust",
				"javascript",
				"json",
				"tsx",
				"typescript",
				"svelte",
				"vim",
				"vue",
				"xml",
				"yaml",
				"zig",
			})

			-- Neovim 0.12: highlighting is a core feature via vim.treesitter.start().
			-- Only start it when highlight queries actually exist; otherwise fall back
			-- to Neovim's bundled legacy syntax (e.g. syntax/tmux.vim — nvim-treesitter's
			-- main branch has a tmux parser but ships no queries for it).
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
					local ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
					if ok and query then
						pcall(vim.treesitter.start, ev.buf)
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			-- Select textobjects
			local select_maps = {
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			}
			for key, query in pairs(select_maps) do
				vim.keymap.set({ "x", "o" }, key, function()
					select.select_textobject(query, "textobjects")
				end)
			end

			-- Move: next start
			for key, query in pairs({
				["]a"] = "@parameter.outer",
				["]f"] = "@function.outer",
				["]c"] = "@class.outer",
			}) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_next_start(query, "textobjects")
				end)
			end

			-- Move: next end
			for key, query in pairs({
				["]A"] = "@parameter.outer",
				["]F"] = "@function.outer",
				["]C"] = "@class.outer",
			}) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_next_end(query, "textobjects")
				end)
			end

			-- Move: previous start
			for key, query in pairs({
				["[a"] = "@parameter.outer",
				["[f"] = "@function.outer",
				["[c"] = "@class.outer",
			}) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_previous_start(query, "textobjects")
				end)
			end

			-- Move: previous end
			for key, query in pairs({
				["[A"] = "@parameter.outer",
				["[F"] = "@function.outer",
				["[C"] = "@class.outer",
			}) do
				vim.keymap.set({ "n", "x", "o" }, key, function()
					move.goto_previous_end(query, "textobjects")
				end)
			end

			-- Swap parameters
			vim.keymap.set("n", "ga", function()
				swap.swap_next("@parameter.inner")
			end)
			vim.keymap.set("n", "gA", function()
				swap.swap_previous("@parameter.inner")
			end)
		end,
	},
	{
		"windwp/nvim-ts-autotag",
	},
}
