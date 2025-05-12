return {
	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		version = false,
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				opts = {
					history = true,
					delete_check_events = "TextChanged",
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",

			-- Some additional helpers
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-nvim-lua",

			-- Icons
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local compare = require("cmp.config.compare")
			local types = require("cmp.types")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			luasnip.config.setup({})
			local lspkind = require("lspkind")

			local function deprioritize_snippet(entry1, entry2)
				if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
					return false
				end
				if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
					return true
				end
			end

			local function has_words_before()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			local function get_entry_text(entry)
				local item = entry.completion_item
				if item.textEdit then
					-- If textEdit is a table, it has newText (LSP spec)
					-- If it's a string, it's the newText directly (some sources)
					if type(item.textEdit) == "table" then
						return item.textEdit.newText
					else
						return item.textEdit
					end
				end
				return item.label -- Fallback to label
			end

			local intelligent_cr = function(fallback)
				if cmp.visible() then
					local entry = cmp.get_selected_entry()
					if entry then
						local current_cmdline_text = vim.fn.getcmdline()
						local selected_item_text = get_entry_text(entry) -- Use helper or entry:get_label() if simpler

						-- If what's typed is exactly what's selected,
						-- or if the selected item would result in no change to the cmdline.
						-- This check might need refinement based on how sources provide `textEdit` vs `label`.
						-- For simple cmdline sources (path, cmdline), label is often enough.
						if current_cmdline_text == selected_item_text then
							-- Abort cmp so it doesn't try to handle the <CR> itself by just confirming.
							-- Then, use fallback() to let Neovim execute the command line.
							cmp.abort()
							fallback() -- Fallback should make Neovim execute the command.
						else
							-- Different item selected, or current text is a prefix.
							-- Confirm the selection (this will update the command line).
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
							-- The user will then need to press <CR> again to execute, which is standard.
						end
					else
						-- cmp is visible, but no entry is selected (e.g., menu just appeared).
						-- Let Neovim execute what's currently typed.
						fallback()
					end
				else
					-- cmp is not visible. Let Neovim execute the command.
					fallback()
				end
			end

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<c-tab>"] = cmp.mapping.complete({}), -- manual "completion"
					["<c-j>"] = cmp.mapping.select_next_item(),
					["<c-k>"] = cmp.mapping.select_prev_item(),
					["<c-u>"] = cmp.mapping.scroll_docs(-4),
					["<c-d>"] = cmp.mapping.scroll_docs(4),
					["<cr>"] = cmp.mapping({
						i = function(fallback)
							if cmp.visible() then
								local entry = cmp.get_selected_entry()
								local ignore_snippet = false
								if entry == nil then
									if #cmp.get_entries() >= 1 then
										cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
									end
									entry = cmp.get_active_entry()
									ignore_snippet = true
								end
								if entry ~= nil then
									if ignore_snippet and entry:get_kind() == types.lsp.CompletionItemKind.Snippet then
										fallback()
									else
										cmp.confirm()
									end
									return
								end
							end
							fallback()
						end,
						s = cmp.mapping.confirm({ select = true }),
						c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
					}),
					["<esc>"] = cmp.mapping({
						i = function(fallback)
							if cmp.visible() and #cmp.get_entries() > 1 then
								cmp.abort()
							else
								fallback()
							end
						end,
						c = function(fallback)
							if cmp.visible() then
								cmp.close()
							else
								fallback()
							end
						end,
					}),
					["<tab>"] = cmp.mapping(function(fallback)
						local code_complete = "copilot"
						local code_complete_keys = vim.fn[code_complete .. "#Accept"]("")
						if code_complete_keys ~= "" then
							vim.api.nvim_feedkeys(code_complete_keys, "i", true)
						elseif cmp.visible() then
							if #cmp.get_entries() == 1 then
								cmp.confirm({ select = true })
							else
								cmp.select_next_item()
							end
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<s-tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						elseif has_words_before() then
							cmp.complete()
							if #cmp.get_entries() == 1 then
								cmp.confirm({ select = true })
							end
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sorting = {
					priority_weight = 2,
					comparators = {
						deprioritize_snippet,
						compare.offset,
						compare.exact,
						-- compare.scopes,
						compare.score,
						compare.recently_used,
						compare.locality,
						compare.kind,
						-- compare.sort_text,
						compare.length,
						compare.order,
					},
				},
				sources = {
					{ name = "nvim_lsp", keyword_length = 2 }, -- lsp
					{ name = "buffer", keyword_length = 4, ignore_case = false }, -- text within current buffer
					{ name = "luasnip", keyword_length = 3 }, -- snippets
					{ name = "emoji" },
					{ name = "path", keyword_length = 2 }, -- file system paths
					{ name = "render-markdown" },
					{ name = "nvim_lua" },
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = 60,
						symbol_map = {
							Codeium = "󰘦 ",
						},
						ellipsis_char = "...",
					}),
				},
			})

			cmp.setup.filetype({ "codecompanion" }, {
				sources = {
					{ name = "codecompanion" },
				},
			})

			local commandline_mapping = cmp.mapping.preset.cmdline({
				["<c-j>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					else
						-- If you want C-j to do something else when cmp is not visible,
						-- e.g., act like <Down> for history.
						-- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), "n", false)
						fallback() -- Or just fallback to default Neovim behavior for C-j in cmdline
					end
				end, { "c" }),
				["<c-k>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					else
						-- If you want C-k to do something else when cmp is not visible,
						-- e.g., act like <Up> for history.
						-- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), "n", false)
						fallback() -- Or just fallback to default Neovim behavior for C-k in cmdline
					end
				end, { "c" }),
				["<cr>"] = cmp.mapping(intelligent_cr, { "c" }),
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = commandline_mapping,
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = commandline_mapping,
				sources = {
					{ name = "path" },
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				},
			})

			-- autopairs
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
