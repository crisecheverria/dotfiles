local parsers = {
	"go",
	"sql",
	"python",
	"gitcommit",
	"javascript",
	"typescript",
	{ lang = "tsx", filetypes = { "typescriptreact" } },
	"rust",
	{ lang = "bash", filetypes = { "bash", "sh" } },
	{ lang = "c", filetypes = { "c", "h" } },
	{ lang = "cpp", filetypes = { "cpp", "hpp" } },
	"java",
}

for _, parser in pairs(parsers) do
	local lang = parser.lang or parser
	local default_filetypes = vim.treesitter.language.get_filetypes(lang)
	local filetypes = parser.filetypes or { lang }
	if #default_filetypes == 0 then
		vim.treesitter.language.add(lang)
		vim.treesitter.language.register(lang, filetypes)
		goto continue
	end

	for _, filetype in pairs(filetypes) do
		if not vim.tbl_contains(default_filetypes, filetype) then
			vim.treesitter.language.register(lang, filetype)
		end
	end
	::continue::
end

return {
	autocmds = {
		{
			"FileType",
			function()
				pcall(vim.treesitter.start)
			end,
		},
	},
}
