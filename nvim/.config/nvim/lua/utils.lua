-- Internal helpers shared across modules. NOT a contract module — init.lua
-- does not load this through the module list; other files `require("utils")`
-- directly. Exposes: merge_table (list-aware), gfind (all matches), v_pairs
-- (bracket pairs lookup).

return {
	merge_table = function(t1, t2)
		if t2 == nil then
			return t1
		end
		if t1 == nil then
			return t2
		end

		if t2[1] == nil and t1[1] == nil then
			return vim.tbl_extend("error", t1, t2)
		end

		for _, el in pairs(t2) do
			t1[#t1 + 1] = el
		end
		return t1
	end,

	gfind = function(str, pattern)
		local lst = {}
		local start_search = 1
		while true do
			local left, right = string.find(str, pattern, start_search)
			if not left then
				break
			end
			table.insert(lst, { left, right })
			start_search = right + 1
		end
		return lst
	end,

	v_pairs = { ["{"] = "}", ["["] = "]", ["("] = ")" },
}
