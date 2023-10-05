vim.g.guifont = "Fira Code:h14"

local alpha = function()
	return string.format("%x", math.floor((255 * vim.g.transparency) or 0.8))
end

vim.g.neovide_transparency = 0.0
vim.g.transparency = 0.9
vim.g.neovide_background_color = "#282a36" .. alpha()

vim.g.neovide_floating_blur_amount_x = 6.0
vim.g.neovide_floating_blur_amount_y = 6.0

vim.g.neovide_input_macos_alt_is_meta = true

vim.g.neovide_cursor_vfx_mode = "pixiedust"
