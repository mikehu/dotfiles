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
		checkbox = {
			checked = {
				scope_highlight = "@comment",
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
				vim.keymap.set("n", "<leader>x", function()
					local line = vim.api.nvim_get_current_line()
					local new_line

					-- Check if line contains unchecked checkbox and toggle to checked
					if line:match("%[%s*%]") then
						new_line = line:gsub("%[%s*%]", "[x]", 1)
					-- Check if line contains checked checkbox and toggle to unchecked
					elseif line:match("%[x%]") or line:match("%[X%]") then
						new_line = line:gsub("%[[xX]%]", "[ ]", 1)
					else
						-- If no checkbox found, add one at the beginning of list item
						-- Handle both bullet points and numbered lists
						if line:match("^%s*[-*+]%s") then
							-- Bullet point: "- item" -> "- [ ] item"
							new_line = line:gsub("^(%s*[-*+]%s)", "%1[ ] ")
						elseif line:match("^%s*%d+%.%s") then
							-- Numbered list: "1. item" -> "1. [ ] item"
							new_line = line:gsub("^(%s*%d+%.%s)", "%1[ ] ")
						else
							return -- Do nothing if not a list item
						end
					end

					vim.api.nvim_set_current_line(new_line)
				end, { buffer = true, desc = "Toggle markdown checkbox" })
			end,
		})
	end,
}
