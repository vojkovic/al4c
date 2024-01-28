local M = {}

function M.get()
	local hi = {
		IndentBlanklineChar = { fg = C.surface0 },
		IndentBlanklineContextChar = { fg = C.text },
		IndentBlanklineContextStart = { sp = C.text, style = { "underline" } },
	}

	if O.integrations.indent_blankline.colored_indent_levels then
		hi["IndentBlanklineIndent6"] = { blend = 0, fg = C.yellow }
		hi["IndentBlanklineIndent5"] = { blend = 0, fg = C.red }
		hi["IndentBlanklineIndent4"] = { blend = 0, fg = C.teal }
		hi["IndentBlanklineIndent3"] = { blend = 0, fg = C.peach }
		hi["IndentBlanklineIndent2"] = { blend = 0, fg = C.blue }
		hi["IndentBlanklineIndent1"] = { blend = 0, fg = C.pink }
	end

	return hi
end

return M
