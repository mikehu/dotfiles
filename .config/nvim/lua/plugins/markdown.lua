local filetypes = { "markdown", "codecompanion" }

return {
	"MeanderingProgrammer/render-markdown.nvim",
	event = { "LspAttach" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	ft = filetypes,
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
	config = function(_, opts)
		require("render-markdown").setup(opts)

		-- Apply wrap/linebreak/spell once filetype is known
		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function()
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
			end,
		})
	end,
}
