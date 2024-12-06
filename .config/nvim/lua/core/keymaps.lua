local cmd = function(command)
	return "<cmd>" .. command .. "<cr>"
end

local keymap = vim.keymap

keymap.set("n", "x", '"_x')
keymap.set("n", "X", '"_X')

keymap.set("n", "<D-s>", cmd([[w]]), { desc = "Save" })

keymap.set("n", "<c-d>", [[<c-d>zz]], { desc = "Page down" })
keymap.set("n", "<c-u>", [[<c-u>zz]], { desc = "Page up" })

keymap.set("n", "<m-j>", cmd([[m+]]), { desc = "Move line down" })
keymap.set("n", "<m-k>", cmd([[m-2]]), { desc = "Move line up" })
keymap.set("v", "<m-j>", [[:m'>+<cr>gv=gv]], { desc = "Move block down" })
keymap.set("v", "<m-k>", [[:m-2<cr>gv=gv]], { desc = "Move block up" })

keymap.set({ "n", "i" }, "<c-y>", [[<esc>Vyp<cr>k]], { desc = "Duplicate line" })
keymap.set("n", "c.", [[viWo<esc>ct.]], { desc = "Change up to <dot>" })

keymap.set("n", "go", [[:e ]], { desc = "Open path" })

keymap.set("n", "<leader>h", cmd([[nohl]]), { desc = "Remove highlights" })

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

-- Diagnostics / Trouble

keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic message" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic message" })

local wk = require("which-key")

-- Saving
wk.add({
	{ "<leader>s", cmd([[w]]), desc = "Save", icon = "💾" },
	{ "<leader>S", cmd([[wa]]), desc = "Save all" },
})

-- Quitting
wk.add({
	{ "<leader>q", group = "Quit", icon = " " },
	{ "<leader>qq", cmd([[q]]), desc = "Quit" },
	{ "<leader>qQ", cmd([[q!]]), desc = "Force quit" },
})

-- Buffer management
wk.add({
	{ "<leader>b", group = "Buffers", icon = " " },
	{
		"<leader>bb",
		cmd([[Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal]]),
		desc = "Goto buffer",
	},
	{ "<leader>bn", cmd([[enew]]), desc = "New buffer" },
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

-- Various text manipulation shorthands
wk.add({
	{ "<leader>i", group = "Insert", icon = " " },
	{ "<leader>io", [[m`o<esc>``]], desc = "Newline below" },
	{ "<leader>iO", [[m`O<esc>``]], desc = "Newline above" },
})
wk.add({
	{ "<leader>e", group = "End with", icon = " " },
	{ "<leader>e,", [[m`A,<esc>``]], desc = "Comma" },
	{ "<leader>e;", [[m`A;<esc>``]], desc = "Semicolon" },
})
wk.add({
	mode = { "n", "v" },
	{ "<leader>y", [["+y]], desc = "Yank to clipboard" },
})
wk.add({
	mode = { "n", "v" },
	{ "<leader>d", [["_d]], desc = "Delete without register" },
})

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
	{ "<leader>g", group = "Git / Grapple 🪝", icon = " " },
	{ "<leader>gb", cmd([[Gitsigns toggle_current_line_blame]]), desc = "Toggle blame" },
	{ "<leader>gd", cmd([[Gitsigns toggle_deleted]]), desc = "Diff this" },
	{ "<leader>gp", cmd([[Gitsigns preview_hunk]]), desc = "Preview hunk" },
	{ "<leader>gf", cmd([[Telescope git_files theme=dropdown]]), desc = "Find files" },
	{ "<leader>gw", cmd([[Telescope git_worktree git_worktrees theme=dropdown]]), desc = "Git worktree" },
	{ "<leader>G", cmd([[Neogit]]), desc = "Neogit" },
})

-- UI
wk.add({
	{ "<leader>u", group = "UI", icon = " " },
	{ "<leader>ul", cmd([[Lazy]]), desc = "Lazy", icon = "󰒲 " },
	{ "<leader>ub", cmd([[Mason]]), desc = "Mason", icon = "🧱" },
	{ "<leader>ug", cmd([[Neogit]]), desc = "Neogit", icon = "󰊢 " },
	{ "<leader>ue", cmd([[Oil --float]]), desc = "File explorer", icon = " " },
})

-- Prefix registrations
wk.add({
	{ "gl", group = "LSP", icon = "✨" },
	{ "<leader>P", group = "Project", icon = "📁" },
	{ "<leader>k", group = "Definitions", icon = " " },
})
