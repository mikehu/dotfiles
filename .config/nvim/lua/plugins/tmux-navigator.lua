return {
	"alexghergh/nvim-tmux-navigation",
	config = function()
		local nvim_tmux_nav = require("nvim-tmux-navigation")

		nvim_tmux_nav.setup({
			disable_when_zoomed = true, -- defaults to false
		})

		-- Floating filetypes that should be treated as a navigable layer.
		-- When one of these is visible, it becomes the only thing C-h/j/k/l can reach.
		local navigable_float_fts = {
			difft = true,
			lazy = true,
			snacks_terminal = true,
			snacks_notif_history = true,
		}

		local function find_navigable_float()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local cfg = vim.api.nvim_win_get_config(win)
				if cfg.relative and cfg.relative ~= "" and cfg.focusable ~= false then
					local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
					if navigable_float_fts[ft] then
						return win
					end
				end
			end
			return nil
		end

		local function in_navigable_float()
			local cfg = vim.api.nvim_win_get_config(0)
			if cfg.relative and cfg.relative ~= "" then
				local ft = vim.bo.filetype
				return navigable_float_fts[ft]
			end
			return false
		end

		local function navigate_with_float_awareness(nav_fn, direction)
			return function()
				if in_navigable_float() then
					-- Already in a navigable float: pass directly to tmux
					if vim.env.TMUX then
						require("nvim-tmux-navigation.tmux_util").tmux_change_pane(direction)
					end
				else
					local float_win = find_navigable_float()
					if float_win then
						-- A navigable float exists: jump into it
						vim.api.nvim_set_current_win(float_win)
					else
						-- No floats: normal navigation
						nav_fn()
					end
				end
			end
		end

		vim.keymap.set({ "n", "i", "t" }, "<C-h>", navigate_with_float_awareness(nvim_tmux_nav.NvimTmuxNavigateLeft, "h"))
		vim.keymap.set({ "n", "i" }, "<C-j>", navigate_with_float_awareness(nvim_tmux_nav.NvimTmuxNavigateDown, "j"))
		vim.keymap.set({ "n", "i" }, "<C-k>", navigate_with_float_awareness(nvim_tmux_nav.NvimTmuxNavigateUp, "k"))
		vim.keymap.set({ "n", "i", "t" }, "<C-l>", navigate_with_float_awareness(nvim_tmux_nav.NvimTmuxNavigateRight, "l"))
	end,
}
