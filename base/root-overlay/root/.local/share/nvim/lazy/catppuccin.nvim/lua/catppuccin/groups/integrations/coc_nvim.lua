local M = {}

function M.get()
	return {
		-- These groups are for the coc.nvim, see ":h coc-highlights"
		-- Custom popup menu since coc v0.0.82
		CocMenuSel = { link = "PmenuSel" },
		CocPumSearch = { fg = C.sky, style = { "bold" } },
		-- InlayHints
		CocInlayHint = { fg = C.teal },
	}
end

return M
