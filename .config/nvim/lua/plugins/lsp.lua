return {
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
		},

		opts = {
			inlay_hints = { enabled = true },
		},

		config = function()
			local mason_lspconfig = require("mason-lspconfig")

			-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local function global_on_attach(args)
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
				local bufnr = args.buf -- buffer that was just attached

				local nmap = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				nmap("gld", vim.lsp.buf.definition, "Goto definition")
				nmap("glt", vim.lsp.buf.type_definition, "Goto typedef")
				nmap("glD", vim.lsp.buf.declaration, "Goto declaration")

				nmap("glr", "<cmd>Glance references<cr>", "Glance references")
				nmap("gli", "<cmd>Glance implementations<cr>", "Glance implementation")
				nmap("glT", "<cmd>Glance type_definitions<cr>", "Glance type definitions")

				nmap("gr", ":IncRename ", "Rename cursor word")
				nmap("gla", vim.lsp.buf.code_action, "Code action")

				-- See `:help K` for why this keymap
				nmap("K", function()
					vim.lsp.buf.hover({ border = "rounded" })
				end, "Hover Documentation")
				nmap("gK", function()
					vim.lsp.buf.signature_help({ border = "rounded" })
				end, "Signature Documentation")

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

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("MyLspAttach", { clear = true }),
				callback = global_on_attach,
			})

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. They will be passed to
			--  the `settings` field of the server config. You must look up that documentation yourself.
			--
			--  If you want to override the default filetypes that your language server will attach to you can
			--  define the property 'filetypes' to the map in question.
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
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
					filetypes = { "go", "gomod", "gowork", "gotmpl" },
				},
				-- denols = {},
				emmet_ls = {},
				eslint = {
					filetypes = {
						"typescript",
						"javascript",
						"javascriptreact",
						"typescriptreact",
						"vue",
						"svelte",
						"html",
						"markdown",
					},
					experimental = { useFlatConfig = true },
					workingDirectory = { mode = "auto" },
				},
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
				ts_ls = {
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
					filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
				},
				tailwindcss = {
					filetypes = { "html", "css", "vue", "svelte" },
				},
				volar = {
					filetypes = { "vue" },
				},
				svelte = {
					filetypes = { "svelte" },
					settings = {
						svelte = {
							plugin = {
								css = { enable = true },
							},
						},
					},
				},
				yamlls = {
					filetypes = { "yaml", "yml", "bu" },
					settings = {
						yaml = {
							schemas = {
								["kubernetes"] = {
									".kube/config",
									"*-deployment.yaml",
									"*-service.yaml",
									"*-store.yaml",
									"*-configmap.yaml",
									"secret-*.yaml",
									"secret.yaml",
								},
							},
						},
					},
				},
			}

			for server, server_config in pairs(servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
					init_options = server_config.init_options,
					settings = server_config.settings or {},
					filetypes = server_config.filetypes,
				})
			end

			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(servers),
			})
		end,
	},
}
