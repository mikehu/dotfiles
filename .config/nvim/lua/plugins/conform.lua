return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				sh = { "shfmt" },
				bash = { "shfmt" },
				css = { "prettierd" },
				lua = { "stylua" },
				html = { "prettierd" },
				handlebars = { "prettierd" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d", "prettierd" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d", "prettierd" },
				json = { "prettierd" },
				yaml = { "yamlfmt" },
				vue = { "eslint_d" },
				svelte = { "eslint_d" },
				go = { "gofmt" },
				["_"] = { "trim_whitespace" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_fallback = true,
			},
			notify_on_error = true,
		})

		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			conform.format({ async = true, lsp_fallback = true, range = range })
		end, { range = true, desc = "Format current buffer" })
		vim.keymap.set("n", "<leader>F", "<cmd>Format<cr>", { desc = "Format buffer" })
	end,
}
