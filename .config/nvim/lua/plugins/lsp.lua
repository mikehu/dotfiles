return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "smjonas/inc-rename.nvim", opts = {} },
			{ "j-hui/fidget.nvim", opts = {} },
		},
		opts = {
			inlay_hints = { enabled = true },
		},
		config = function()
			local function global_on_attach(args)
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
				local bufnr = args.buf -- buffer that was just attached

				local nmap = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				nmap("gld", function()
					Snacks.picker.lsp_definitions({
						layout = { preset = "ivy" },
					})
				end, "Goto definition")
				nmap("glD", function()
					Snacks.picker.lsp_declarations({
						layout = { preset = "ivy" },
					})
				end, "Goto declaration")
				nmap("glt", function()
					Snacks.picker.lsp_type_definitions({
						layout = { preset = "ivy" },
					})
				end, "Goto typedef")
				nmap("gli", function()
					Snacks.picker.lsp_implementations({
						layout = { preset = "ivy" },
					})
				end, "Goto implementation")
				nmap("glr", function()
					Snacks.picker.lsp_references({
						layout = { preset = "ivy" },
					})
				end, "List references")

				nmap("gr", ":IncRename ", "Rename cursor word")
				nmap("gla", vim.lsp.buf.code_action, "Code action")

				-- See `:help K` for why this keymap
				nmap("K", function()
					vim.lsp.buf.hover({ border = "rounded" })
				end, "Hover documentation")
				-- nmap("gK", function()
				-- 	vim.lsp.buf.signature_help({ border = "rounded" })
				-- end, "Signature documentation")

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
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "neovim/nvim-lspconfig" },
			{
				"mason-org/mason.nvim",
				config = true,
			},
		},
		config = function()
			-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

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
					root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
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

			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(servers),
			})
		end,
	},
}
