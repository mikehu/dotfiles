return {
	"github/copilot.vim",
	event = "InsertEnter",
	config = function()
		vim.g.copilot_filetypes = {
			["*"] = false,
			["javascript"] = true,
			["typescript"] = true,
			["lua"] = false,
			["rust"] = true,
			["c"] = true,
			["c#"] = true,
			["c++"] = true,
			["go"] = true,
			["python"] = true,
			["vue"] = true,
		}
		vim.g.copilot_workspace_folders = {
			"~/Code/neurox",
			"~/Code/illustrious-industries",
		}
	end,
}
