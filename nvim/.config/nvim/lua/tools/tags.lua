-- Background-regenerate the project tags file on save.
-- Walks up from the saved file looking for an existing `tags` file; if
-- one is found, runs `ctags -R .` from that directory asynchronously.
-- Opt in per-project by running `ctags -R .` once at the project root.
-- Skips non-file buffers (terminals, scratch, etc.) and serializes runs
-- per project root — ctags writes directly to `tags`, so two concurrent
-- runs on the same root can corrupt the file.

if vim.fn.executable("ctags") == 0 then
	return {}
end

local in_flight = {}

return {
	autocmds = {
		{
			"BufWritePost",
			function(ev)
				if vim.bo[ev.buf].buftype ~= "" then
					return
				end
				local file = vim.api.nvim_buf_get_name(ev.buf)
				if file == "" then
					return
				end
				local tags = vim.fs.find("tags", { upward = true, path = vim.fs.dirname(file) })[1]
				if not tags then
					return
				end
				local root = vim.fs.dirname(tags)
				if in_flight[root] then
					return
				end
				in_flight[root] = true
				vim.system({ "ctags", "-R", "." }, { cwd = root }, function()
					in_flight[root] = nil
				end)
			end,
		},
	},
}
