-- local workspace_folders = {
-- 	"~/Code/neurox",
-- 	"~/Code/illustrious-industries",
-- 	"~/Code/personal",
-- }

return {
	-- {
	-- 	"github/copilot.vim",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		vim.g.copilot_filetypes = {
	-- 			["*"] = false,
	-- 			["javascript"] = true,
	-- 			["typescript"] = true,
	-- 			["lua"] = false,
	-- 			["rust"] = true,
	-- 			["c"] = true,
	-- 			["c#"] = true,
	-- 			["c++"] = true,
	-- 			["html"] = false,
	-- 			["htmx"] = true,
	-- 			["go"] = true,
	-- 			["python"] = true,
	-- 			["vue"] = true,
	-- 		}
	-- 		vim.g.copilot_workspace_folders = workspace_folders
	-- 	end,
	-- },
	{
		"coder/claudecode.nvim",
		keys = {
			{ "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>cR", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>ca", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		},
		config = function()
			local cc = require("claudecode")
			cc.setup({
				focus_after_send = true,
				terminal = {
					split_width_percentage = 0.35,
					provider = "snacks",
				},
				diff_opts = {
					keep_terminal_focus = true,
				},
			})

			-- Buffer-local keymaps for diff accept/reject, only active in diff buffers.
			-- vim.schedule defers the check because claudecode.nvim sets the buffer
			-- variable AFTER nvim_set_current_win triggers BufEnter (diff.lua:592-594).
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("ClaudeCodeDiffKeymaps", { clear = true }),
				callback = function(ev)
					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(ev.buf) then
							return
						end
						if vim.b[ev.buf].claudecode_diff_tab_name then
							vim.keymap.set(
								"n",
								"<leader>cy",
								"<cmd>ClaudeCodeDiffAccept<cr>",
								{ buffer = ev.buf, desc = "Accept diff" }
							)
							vim.keymap.set(
								"n",
								"<leader>cn",
								"<cmd>ClaudeCodeDiffDeny<cr>",
								{ buffer = ev.buf, desc = "Reject diff" }
							)
						end
					end)
				end,
			})
		end,
	},
	{
		name = "chisel",
		dir = vim.fn.stdpath("config") .. "/lua/chisel",
		cmd = { "Chisel", "ChiselFile", "ChiselAbort", "ChiselReview" },
		keys = {
			{ "<leader>ci", ":Chisel<CR>", mode = "v", desc = "Chisel inline edit" },
			{ "<leader>ci", ":ChiselFile<CR>", mode = "n", desc = "Chisel file edit" },
			{ "<leader>cr", ":ChiselReview<CR>", mode = "n", desc = "Review chisel response" },
		},
		config = function()
			require("chisel").setup()
		end,
	},
}
