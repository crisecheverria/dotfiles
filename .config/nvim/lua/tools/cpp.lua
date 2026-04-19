local M = {}

function M.find_project_root(bufnr)
	return vim.fs.root(bufnr or 0, { "CMakeLists.txt" })
end

function M.find_executables(build_dir)
	local results = {}
	if not build_dir or vim.fn.isdirectory(build_dir) == 0 then
		return results
	end
	for name, type in vim.fs.dir(build_dir) do
		if type == "file" then
			local path = build_dir .. "/" .. name
			if vim.fn.executable(path) == 1 then
				table.insert(results, path)
			end
		end
	end
	return results
end

return M
