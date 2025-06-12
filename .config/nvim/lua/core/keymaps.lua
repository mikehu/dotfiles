local cmd = function(command)
	return "<cmd>" .. command .. "<cr>"
end

local keymap = vim.keymap

keymap.set("n", "x", '"_x')
keymap.set("n", "X", '"_X')

keymap.set("n", "<D-s>", cmd([[w]]), { desc = "Save" })

keymap.set("n", "<c-d>", [[<c-d>zz]], { desc = "Page down" })
keymap.set("n", "<c-u>", [[<c-u>zz]], { desc = "Page up" })
keymap.set("n", "n", [[nzzzv]], { desc = "Next match" })
keymap.set("n", "N", [[Nzzzv]], { desc = "Prev match" })

keymap.set("n", "<m-j>", cmd([[m+]]), { desc = "Move line down" })
keymap.set("n", "<m-k>", cmd([[m-2]]), { desc = "Move line up" })
keymap.set("v", "<m-j>", [[:m '>+<cr>gv=gv]], { desc = "Move block down" })
keymap.set("v", "<m-k>", [[:m '<-2<cr>gv=gv]], { desc = "Move block up" })
keymap.set("n", "J", [[mzJ`z]], { desc = "Join lines" })

keymap.set("v", "<", "<gv", { desc = "Dedent selection" })
keymap.set("v", ">", ">gv", { desc = "Indent selection" })

keymap.set("i", "<c-y>", [[<esc>Ypi]], { desc = "Duplicate line" })
keymap.set("n", "<c-y>", [[Yp]], { desc = "Duplicate line" })
keymap.set("v", "<c-y>", [["zyP`[V`]p`]"]], { desc = "Duplicate selection" })
keymap.set("n", "c.", [[viWoc]], { desc = "Change <dot> segment" })

keymap.set("n", "go", [[:e ]], { desc = "Open path" })

keymap.set("n", "<leader>h", cmd([[nohl]]), { desc = "Remove highlights" })

keymap.set("n", "<c-q>", cmd([[cclose]]), { desc = "Close quickfix list" })
keymap.set("t", "<c-q>", cmd([[bd!]]), { desc = "Close terminal buffer" })

keymap.set("i", "<esc><esc>", "<esc>")
keymap.set("i", "<c-c>", "<esc>")
keymap.set("i", "jk", "<esc>")
keymap.set("i", "kj", "<esc>")
keymap.set("i", "<m-h>", "<left>")
keymap.set("i", "<m-j>", "<down>")
keymap.set("i", "<m-k>", "<up>")
keymap.set("i", "<m-l>", "<right>")
keymap.set("n", "Q", "<nop>")

local ok, wk = pcall(require, "which-key")
if ok then
	-- Prefix registrations
	wk.add({
		{ "gl", group = "LSP", icon = "✨" },
		{ "<leader>b", group = "Buffers", icon = " " },
		{ "<leader>c", group = "Chat / AI", icon = "🤖" },
		{ "<leader>e", group = "End with", icon = " " },
		{ "<leader>f", group = "Find", icon = " " },
		{ "<leader>g", group = "Git / Grapple 🪝", icon = " " },
		{ "<leader>i", group = "Insert", icon = " " },
		{ "<leader>k", group = "Definitions", icon = " " },
		{ "<leader>l", group = "Lists", icon = "📝" },
		{ "<leader>P", group = "Project", icon = "📁" },
		{ "<leader>q", group = "Quit", icon = " " },
		{ "<leader>t", group = "Test / Trouble 🚦", icon = "🔬" },
		{ "<leader>u", group = "UI", icon = " " },
		{ "<leader>z", group = "Terminal (zsh)", icon = " " },
	})

	-- Saving
	wk.add({
		{ "<leader>s", cmd([[w]]), desc = "Save", icon = "💾" },
		{ "<leader>S", cmd([[wa]]), desc = "Save all" },
	})

	-- Quitting
	wk.add({
		{ "<leader>qq", cmd([[q]]), desc = "Quit" },
		{ "<leader>qQ", cmd([[q!]]), desc = "Force quit" },
	})

	-- Buffer management
	wk.add({
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
		{ "<leader>io", [[m`o<esc>``]], desc = "Newline below" },
		{ "<leader>iO", [[m`O<esc>``]], desc = "Newline above" },
	})
	wk.add({
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
	keymap.set("t", "<c-n>", [[<c-\><c-n>]])
	wk.add({
		{ "<leader>zz", cmd([[BufTermNext]]), desc = "Cycle next terminal" },
		{ "<leader>zZ", cmd([[BufTermPrev]]), desc = "Cycle prev terminal" },
		{ "<leader>zn", cmd([[terminal]]), desc = "New terminal" },
	})

	-- UI
	wk.add({
		{ "<leader>ul", cmd([[Lazy]]), desc = "Lazy", icon = "󰒲 " },
		{ "<leader>ub", cmd([[Mason]]), desc = "Mason", icon = "🧱" },
		-- { "<leader>ug", cmd([[Neogit]]), desc = "Neogit", icon = "󰊢 " },
		{ "<leader>ue", cmd([[Oil --float]]), desc = "File explorer", icon = " " },
		{ "<leader>uh", cmd([[MCPHub]]), desc = "MCPHub", icon = " " },
	})
end
