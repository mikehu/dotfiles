return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local npairs = require("nvim-autopairs")

		npairs.setup({
			disable_filetype = { "TelescopePrompt", "snacks_picker_input" },
			check_ts = true,
			ts_config = {
				lua = { "string" },
				javascript = { "template_string" },
			},
		})

		-- small helper that appends a filetype to any rule that starts with `pat`
		local function extend_ft(pat, ftname)
			for _, r in ipairs(npairs.get_rules(pat) or {}) do -- ← returns table of Rule objects
				-- .filetypes may be nil | string | table, normalise it to a table first
				if r.filetypes == nil then
					r.filetypes = { ftname }
				elseif type(r.filetypes) == "string" then
					r.filetypes = { r.filetypes, ftname }
				else
					table.insert(r.filetypes, ftname)
				end
			end
		end

		extend_ft("```", "codecompanion") -- ``` ↔ ``` rule
		extend_ft("```.*$", "codecompanion") -- newline/regex rule
	end,
}
