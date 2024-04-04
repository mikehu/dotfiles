local cmd = function(command)
	return "<cmd>" .. command .. "<cr>"
end

local keymap = vim.keymap

keymap.set("n", "x", '"_x')
keymap.set("n", "X", '"_X')

keymap.set("n", "<m-h>", "_") -- Home
keymap.set("n", "<m-l>", "$") -- End

keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic message" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic message" })
keymap.set("n", "<leader>L", vim.diagnostic.setloclist, { desc = "Open diagnostic list" })

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
keymap.set("n", "<c-j>", "i<cr><esc>", { desc = "Split line" })
keymap.set("n", "c.", "viWo<esc>ct.", { desc = "Change up to <dot>" })
keymap.set("n", "g,", "A,<esc>", { desc = "End with comma" })

keymap.set("n", "go", [[:e ]], { desc = "Open path" })
keymap.set("n", "<m-tab>", cmd([[bnext]]), { desc = "Cycle next buffer" })
keymap.set("n", "<m-s-tab>", cmd([[bprev]]), { desc = "Cycle prev buffer" })

keymap.set("n", "<leader>h", cmd([[nohl]]), { desc = "Remove highlights" })

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
wk.register({
	x = { close_buffer, "Close buffer" },
	X = { cmd([[bd!]]), "Force close buffer" },
	N = { cmd([[enew]]), "New buffer" },
}, { prefix = "<leader>" })

-- Tab management
wk.register({
	t = {
		name = "Tabs",
		t = { cmd([[tabnext]]), "Cycle next tab" },
		T = { cmd([[tabprevious]]), "Cycle previous tab" },
		n = { cmd([[tabnew]]), "New tab" },
		x = { cmd([[tabclose]]), "Close tab" },
	},
}, { prefix = "<leader>" })

-- Terminal
keymap.set("n", "<m-esc>", cmd([[terminal]]))
keymap.set("t", "<m-esc>", cmd([[bd!]]))
keymap.set("t", "<m-tab>", cmd([[bnext]]))
keymap.set("t", "<m-s-tab>", cmd([[bprev]]))
keymap.set("t", "<c-n>", [[<c-\><c-n>]])
wk.register({
	z = {
		name = "Terminal (zsh)",
		z = { cmd([[BufTermNext]]), "Cycle next terminal" },
		Z = { cmd([[BufTermPrev]]), "Cycle prev terminal" },
		n = { cmd([[terminal]]), "New terminal" },
	},
}, { prefix = "<leader>" })

-- Git
wk.register({
	G = {
		name = "Git",
		b = { cmd([[Gitsigns toggle_current_line_blame]]), "Toggle blame" },
		p = { cmd([[Gitsigns preview_hunk]]), "Preview hunk" },
		f = { cmd([[Telescope git_files theme=dropdown]]), "Find files" },
		w = { cmd([[Telescope git_worktree git_worktrees theme=dropdown]]), "Git worktree" },
	},
}, { prefix = "<leader>" })

-- Prefix registrations
wk.register({
	["gl"] = { name = "LSP" },
	["<leader>D"] = { name = "Definitions" },
	["<leader>p"] = { name = "Project" },
})
