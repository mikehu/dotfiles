local Component = require("lualine.component"):extend()

Component.processing = false
Component.spinner_index = 1
Component.model = nil

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
function Component:init(options)
	Component.super.init(self, options)

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

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionChatModel",
		group = group,
		callback = function(event)
			if event.data and event.data.model then
				Component.model = event.data.model
			end
		end,
	})
end

-- Function that runs every time statusline is updated
function Component:update_status()
	if self.processing then
		self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
		return spinner_symbols[self.spinner_index]
	else
		return nil
	end
end

local function codecompanion_current_model()
	if Component.model then
		return "  " .. Component.model
	end
	return "  config not ready!"
end

local function codecompanion_modifiable_status()
	local current_bufnr = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_get_option_value("modifiable", { buf = current_bufnr }) then
		return "⏳ Working on an answer..."
	else
		return "✏️ Awaiting input..."
	end
end

local Extension = {
	filetypes = { "codecompanion" },
	sections = {
		lualine_c = {
			{
				"filename",
				path = 1,
				separator = "⟩",
			},
			{
				codecompanion_current_model,
				separator = "⟩",
			},
			codecompanion_modifiable_status,
		},
	},
}

return {
	component = Component,
	extension = Extension,
}
