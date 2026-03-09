local M = {}

local defaults = {
	allowed_roots = {
		vim.fn.expand("~"),
	},
}

M.values = vim.deepcopy(defaults)

function M.setup(opts)
	M.values = vim.tbl_deep_extend("force", defaults, opts or {})

	-- Expand ~ in allowed_roots so prefix matching works against absolute paths
	for i, root in ipairs(M.values.allowed_roots) do
		M.values.allowed_roots[i] = vim.fn.expand(root)
	end
end

return M
