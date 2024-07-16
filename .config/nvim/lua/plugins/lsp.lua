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
			-- "hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-nvim-lua",

			-- neogen
			{
				"danymat/neogen",
				event = "VeryLazy",
				dependencies = {
					"nvim-treesitter/nvim-treesitter",
				},
				version = "*",
				config = function()
					require("neogen").setup({
						enabled = true,
						input_after_comment = true,
						snippet_engine = "luasnip",
					})

					vim.keymap.set("n", "gC", [[<cmd>Neogen<cr>]], { desc = "Generate annotation" })
				end,
			},

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
			local neogen = require("neogen")

			local function deprioritize_snippet(entry1, entry2)
				if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
					return false
				end
				if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
					return true
				end
			end

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup({
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
						local copilot_keys = vim.fn["copilot#Accept"]("")
						if copilot_keys ~= "" then
							vim.api.nvim_feedkeys(copilot_keys, "i", true)
						elseif cmp.visible() then
							if #cmp.get_entries() == 1 then
								cmp.confirm({ select = true })
							else
								cmp.select_next_item()
							end
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif neogen.jumpable() then
							neogen.jump_next()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<s-tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						elseif neogen.jumpable(true) then
							neogen.jump_prev()
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
					{ name = "buffer", keyword_length = 4 }, -- text within current buffer
					{ name = "luasnip", keyword_length = 3 }, -- snippets
					{ name = "emoji" },
					{ name = "path", keyword_length = 2 }, -- file system paths
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

			-- cmp.setup.cmdline("/", {
			-- 	mapping = cmp.mapping.preset.cmdline(),
			-- 	sources = {
			-- 		{ name = "buffer" },
			-- 	},
			-- })

			-- cmp.setup.cmdline(":", {
			-- 	mapping = cmp.mapping.preset.cmdline(),
			-- 	sources = cmp.config.sources({
			-- 		{ name = "path" },
			-- 	}, {
			-- 		{
			-- 			name = "cmdline",
			-- 			option = {
			-- 				ignore_cmds = { "Man", "!" },
			-- 			},
			-- 		},
			-- 	}),
			-- })

			-- autopairs
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		-- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{
				"williamboman/mason.nvim",
				config = true,
			},
			{
				"williamboman/mason-lspconfig.nvim",
			},
			{
				"hrsh7th/cmp-nvim-lsp",
			},

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- LSP ui
			{
				"dnlhc/glance.nvim",
				event = "LspAttach",
				config = function()
					require("glance").setup({
						border = {
							enable = true,
						},
						list = {
							position = "left",
						},
						hooks = {
							before_open = function(results, open, jump)
								local uri = vim.uri_from_bufnr(0)
								if #results == 1 then
									local target_uri = results[1].uri or results[1].targetUri
									if target_uri == uri then
										jump(results[1])
									else
										open(results)
									end
								else
									open(results)
								end
							end,
						},
					})
				end,
			},
		},

		opts = {
			inlay_hints = { enabled = true },
		},

		config = function()
			local lspconfig = require("lspconfig")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_registry = require("mason-registry")

			-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			--  This function gets run when an LSP connects to a particular buffer.
			local on_attach = function(client, bufnr)
				local nmap = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				nmap("gld", vim.lsp.buf.definition, "Goto definition")
				nmap("glr", "<cmd>Glance references<cr>", "Goto references")
				nmap("gli", "<cmd>Glance implementations<cr>", "Goto implementation")
				nmap("glt", vim.lsp.buf.type_definition, "Goto typedef")
				nmap("glD", vim.lsp.buf.declaration, "Goto declaration")

				nmap("gr", ":IncRename ", "Rename cursor word")
				nmap("gla", vim.lsp.buf.code_action, "Code action")

				local ts_builtin = require("telescope.builtin")
				nmap("<leader>fr", ts_builtin.lsp_references, "Find references")
				nmap("<leader>fs", function()
					ts_builtin.lsp_document_symbols({
						winblend = 20,
						symbols = { "function", "constant", "variable", "class" },
					})
				end, "Find symbols")
				nmap("<leader>fS", ts_builtin.lsp_dynamic_workspace_symbols, "Find workspace symbols")

				-- See `:help K` for why this keymap
				-- nmap("K", vim.lsp.buf.hover, "Hover Documentation")
				nmap("gK", vim.lsp.buf.signature_help, "Signature Documentation")

				-- Lesser used LSP functionality
				nmap("<leader>Pa", vim.lsp.buf.add_workspace_folder, "Add folder")
				nmap("<leader>Pr", vim.lsp.buf.remove_workspace_folder, "Remove folder")
				nmap("<leader>Pl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "List project folders")

				-- inlay hints
				local function toggle_inlay_hints()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end
				nmap("glh", toggle_inlay_hints, "Toggle inlay hints")

				client.server_capabilities.documentFormattingProvider = false
			end

			local lsp_handlers = {
				["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
				["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
			}

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. They will be passed to
			--  the `settings` field of the server config. You must look up that documentation yourself.
			--
			--  If you want to override the default filetypes that your language server will attach to you can
			--  define the property 'filetypes' to the map in question.
			local vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path()
				.. "/node_modules/@vue/language-server"
			local servers = {
				bashls = {},
				-- clangd = {},
				gopls = {
					settings = {
						gopls = {
							completeUnimported = true,
							usePlaceholders = true,
							analyses = {
								unusedparams = true,
							},
						},
					},
					filetypes = { "go", "gomod", "gowork", "gotmpl" },
				},
				-- denols = {},
				emmet_ls = {},
				eslint = {},
				html = {},
				jsonls = {},
				lua_ls = {
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								-- make language server aware of runtime files
								library = {
									[vim.fn.expand("$VIMRUNTIME/lua")] = true,
									[vim.fn.stdpath("config") .. "/lua"] = true,
								},
							},
							hint = { enable = true },
						},
					},
				},
				marksman = {},
				pyright = {},
				-- rust_analyzer = {},
				tsserver = {
					init_options = {
						plugins = {
							{
								name = "@vue/typescript-plugin",
								location = vue_language_server_path,
								languages = { "vue" },
							},
						},
					},
					settings = {
						typescript = {
							inlayHints = {
								-- You can set this to 'all' or 'literals' to enable more hints
								includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
								includeInlayParameterNameHintsWhenArgumentMatchesName = true,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								-- You can set this to 'all' or 'literals' to enable more hints
								includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
								includeInlayParameterNameHintsWhenArgumentMatchesName = true,
								includeInlayVariableTypeHints = true,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
					filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				},
				tailwindcss = {},
				volar = {},
				yamlls = {
					filetypes = { "yaml", "yml", "bu" },
				},
			}

			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(servers),
				automatic_installation = true,
				handlers = {
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = capabilities,
							on_attach = on_attach,
							init_options = (servers[server_name] or {}).init_options,
							settings = (servers[server_name] or {}).settings or {},
							filetypes = (servers[server_name] or {}).filetypes,
							handlers = lsp_handlers,
						})
					end,
				},
			})
		end,
	},
}
