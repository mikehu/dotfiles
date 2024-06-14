return {
	"folke/flash.nvim",
	event = "VeryLazy",
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
			desc = "Flash treesitter",
		},
		{
			"g/",
			mode = { "o" },
			function()
				require("flash").jump({ jump = {
					inclusive = false,
				} })
			end,
			desc = "Flash",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Remote treesitter search",
		},
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
