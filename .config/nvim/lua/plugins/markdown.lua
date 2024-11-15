return {
	"MeanderingProgrammer/render-markdown.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {
		heading = {
			icons = { "󰎦 ", "󰎩 ", "󰎬 ", "󰎮 ", "󰎰 ", "󰎵 " },
		},
		link = {
			custom = {
				web = { pattern = "^http[s]?://", icon = " ", highlight = "RenderMarkdownLink" },
			},
		},
	},
}
