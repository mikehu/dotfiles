return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
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
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	},
}
