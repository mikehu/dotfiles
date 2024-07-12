local cmd = function(command)
	return "<cmd>" .. command .. "<cr>"
end

local keymap = vim.keymap

keymap.set("n", "x", '"_x')
keymap.set("n", "X", '"_X')

keymap.set("n", "<D-s>", cmd([[w]]), { desc = "Save" })
keymap.set("n", "<leader>s", cmd([[w]]), { desc = "Save" })
keymap.set("n", "<leader>q", cmd([[q]]), { desc = "Quit" })
keymap.set("n", "<leader>Q", cmd([[q!]]), { desc = "Force quit" })
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over" })

keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without register" })

keymap.set("n", "<leader>+", "<c-a>", { desc = "Increment" })
keymap.set("n", "<leader>-", "<c-x>", { desc = "Decrement" })

keymap.set("n", "<m-o>", "o<esc>k", { desc = "Insert line below" })
keymap.set("n", "<m-O>", "O<esc>j", { desc = "Insert line above" })

keymap.set("n", "<c-d>", [[<c-d>zz]], { desc = "Page down" })
keymap.set("n", "<c-u>", [[<c-u>zz]], { desc = "Page up" })

keymap.set("n", "<m-j>", cmd([[m+]]), { desc = "Move line down" })
keymap.set("n", "<m-k>", cmd([[m-2]]), { desc = "Move line up" })
keymap.set("v", "<m-j>", [[:m'>+<cr>gv=gv]], { desc = "Move block down" })
keymap.set("v", "<m-k>", [[:m-2<cr>gv=gv]], { desc = "Move block up" })

keymap.set({ "n", "i" }, "<c-y>", "<esc>Vyp<cr>k", { desc = "Duplicate line" })
keymap.set("n", "c.", "viWo<esc>ct.", { desc = "Change up to <dot>" })

keymap.set("n", "go", [[:e ]], { desc = "Open path" })
keymap.set("n", "<m-tab>", cmd([[bnext]]), { desc = "Cycle next buffer" })
keymap.set("n", "<m-s-tab>", cmd([[bprev]]), { desc = "Cycle prev buffer" })

keymap.set("n", "<leader>h", cmd([[nohl]]), { desc = "Remove highlights" })
keymap.set("n", "<leader>,", "A,<esc>", { desc = "End with comma" })

keymap.set("n", "<c-q>", cmd([[cclose]]), { desc = "Close quickfix list" })
keymap.set("t", "<c-q>", cmd([[bd!]]), { desc = "Close terminal buffer" })

keymap.set("i", "<c-c>", "<esc>")
keymap.set("i", "jk", "<esc>")
keymap.set("i", "kj", "<esc>")
keymap.set("i", "<m-h>", "<left>")
keymap.set("i", "<m-j>", "<down>")
keymap.set("i", "<m-k>", "<up>")
keymap.set("i", "<m-l>", "<right>")
keymap.set("n", "Q", "<nop>")

local wk = require("which-key")

local function close_buffer()
	local bufnr = vim.fn.bufnr("%")
	vim.cmd("silent! bn | bd " .. bufnr .. " | silent! bp")
end

-- Buffer management
wk.add({
	{ "<leader>x", close_buffer, desc = "Close buffer" },
	{ "<leader>X", cmd([[bd!]]), desc = "Force close buffer" },
	{ "<leader>N", cmd([[enew]]), desc = "New buffer" },
})

-- Lists
local function toggle_list(type)
	local windows = vim.fn.getwininfo()
	local ll = type == "l" and 1 or 0
	local wintype = ll == 1 and "loclist" or "quickfix"
	local close_command = type .. "close"
	local open_command = type .. "open"
	for _, win in pairs(windows) do
		if win[wintype] == 1 then
			vim.cmd[close_command]()
			return
		end
	end
	vim.cmd[open_command]()
end
wk.add({
	{ "<leader>l", group = "Lists", icon = "📝" },
	-- d = { vim.diagnostic.setloclist, "Open diagnostic list" },
	{
		"<leader>ll",
		function()
			toggle_list("l")
		end,
		desc = "Toggle local list",
	},
	{
		"<leader>lq",
		function()
			toggle_list("c")
		end,
		desc = "Toggle quickfix list",
	},
})

-- Diagnostics / Trouble

keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic message" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic message" })

-- Terminal
keymap.set("t", "<m-tab>", cmd([[bnext]]))
keymap.set("t", "<m-s-tab>", cmd([[bprev]]))
keymap.set("t", "<c-n>", [[<c-\><c-n>]])
wk.add({
	{ "<leader>z", group = "Terminal (zsh)", icon = " " },
	{ "<leader>zz", cmd([[BufTermNext]]), desc = "Cycle next terminal" },
	{ "<leader>zZ", cmd([[BufTermPrev]]), desc = "Cycle prev terminal" },
	{ "<leader>zn", cmd([[terminal]]), desc = "New terminal" },
})

-- Git
wk.add({
	{ "<leader>G", group = "Git", icon = " " },
	{ "<leader>Gg", cmd([[Neogit]]), desc = "Neogit" },
	{ "<leader>Gb", cmd([[Gitsigns toggle_current_line_blame]]), desc = "Toggle blame" },
	{ "<leader>Gd", cmd([[Gitsigns toggle_deleted]]), desc = "Diff this" },
	{ "<leader>Gp", cmd([[Gitsigns preview_hunk]]), desc = "Preview hunk" },
	{ "<leader>Gf", cmd([[Telescope git_files theme=dropdown]]), desc = "🔭 Find files" },
	{ "<leader>Gw", cmd([[Telescope git_worktree git_worktrees theme=dropdown]]), desc = "🔭 Git worktree" },
})

-- Prefix registrations
wk.add({
	{ "gl", group = "LSP" },
	{ "<leader>p", group = "Project" },
	{ "<leader>K", group = "Definitions" },
})
