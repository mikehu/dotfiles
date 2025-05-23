local Spinner = require("lualine.component"):extend()

Spinner.processing = false
Spinner.spinner_index = 1

local spinner_symbols = {
	"⠋",
	"⠙",
	"⠹",
	"⠸",
	"⠼",
	"⠴",
	"⠦",
	"⠧",
	"⠇",
	"⠏",
}
local spinner_symbols_len = 10

-- Initializer
function Spinner:init(options)
	Spinner.super.init(self, options)

	local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequest*",
		group = group,
		callback = function(request)
			if request.match == "CodeCompanionRequestStarted" then
				self.processing = true
			elseif request.match == "CodeCompanionRequestFinished" then
				self.processing = false
			end
		end,
	})
end

-- Function that runs every time statusline is updated
function Spinner:update_status()
	if self.processing then
		self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
		return spinner_symbols[self.spinner_index]
	else
		return nil
	end
end

local function codecompanion_modifiable_status()
	local current_bufnr = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_get_option_value("modifiable", { buf = current_bufnr }) then
		return "✨ Working on an answer..."
	else
		return "✏️ Awaiting input..." -- Or perhaps '✏️' to indicate editable
	end
end
local Extension = {
	filetypes = { "codecompanion" },
	sections = {
		lualine_c = {
			{
				"filename",
				path = 1,
			},
			codecompanion_modifiable_status,
		},
	},
}

return {
	component = Spinner,
	extension = Extension,
}
