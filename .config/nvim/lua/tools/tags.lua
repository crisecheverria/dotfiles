-- Background-regenerate the project tags file on save.
-- Walks up from the saved file looking for an existing `tags` file; if
-- one is found, runs `ctags -R .` from that directory asynchronously.
-- Opt in per-project by running `ctags -R .` once at the project root.

return {
	autocmds = {
		{
			"BufWritePost",
			function(ev)
				local file = vim.api.nvim_buf_get_name(ev.buf)
				if file == "" then
					return
				end
				local tags = vim.fs.find("tags", { upward = true, path = vim.fs.dirname(file) })[1]
				if not tags then
					return
				end
				vim.system({ "ctags", "-R", "." }, { cwd = vim.fs.dirname(tags) })
			end,
		},
	},
}
