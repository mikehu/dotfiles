return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		modes = {
			-- options used when flash is activated through
			-- a regular search with `/` or `?`
			search = {
				enabled = false,
			},
		},
	},
	keys = {
		{
			"s",
			mode = { "n", "x" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"S",
			mode = { "n", "x" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		-- {
		-- 	"r",
		-- 	mode = "o",
		-- 	function()
		-- 		flash.remote()
		-- 	end,
		-- 	desc = "Remote Flash",
		-- },
		-- {
		-- 	"R",
		-- 	mode = { "o", "x" },
		-- 	function()
		-- 		flash.treesitter_search()
		-- 	end,
		-- 	desc = "Treesitter Search",
		-- },
		-- {
		-- 	"<c-s>",
		-- 	mode = { "c" },
		-- 	function()
		-- 		flash.toggle()
		-- 	end,
		-- 	desc = "Toggle Flash Search",
		-- },
	},
}
