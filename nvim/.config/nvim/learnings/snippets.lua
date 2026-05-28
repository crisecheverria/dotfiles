local Snippets = {
	list = {
		javascriptreact = {
			rfc = [[export const $ = () => {
	return (
		<div>

		</div>
	);
};]],
			rfcp = [[interface $ {

}

export const $ = (props: $) => {
	return (
		<div>

		</div>
	);
};]],
			us = [[const [$] = useState();]],
			ust = [[const [$] = useState<Type>();]],
			ue = [[useEffect(() => {

}, []);]],
			uea = [[useEffect(() => {

}, [dependencies]);]],
			afn = [[const $ = async () => {

};]],
			fn = [[const $ = () => {

};]],
			fnt = [[const $ = (): ReturnType => {

};]],
		},
		lua = {
			func = [[function $()

end]],
			p = [[print($)]],
		},
	},
}

local function find_prev_word(line, column)
	local before_cursor = line:sub(1, column)
	local word = before_cursor:match("[%w_]+$")
	return word or ""
end

local function find_name(row, column)
	local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, true)
	return find_prev_word(lines[1], column)
end

local function find_snippet(name)
	local ft = vim.bo.filetype
	local ft_snippets = Snippets.list[ft]
	if ft_snippets then
		return ft_snippets[name] or ""
	end
	return ""
end

Snippets.expands = function()
	local row, column = unpack(vim.api.nvim_win_get_cursor(0))
	local name = find_name(row, column)
	local snippet = find_snippet(name)

	if snippet == "" then
		vim.notify(string.format("Snippet %s not found.", name), vim.log.levels.INFO)
		return
	end

	local cursor_position = string.find(snippet, "[$]")

	if cursor_position then
		snippet = string.gsub(snippet, "[$]", "")
	end

	local lines = vim.split(snippet, "\n")

	vim.api.nvim_buf_set_text(0, row - 1, column - string.len(name), row - 1, column, { "" })
	vim.api.nvim_put(lines, "", true, true)

	-- set cursor position
	if cursor_position then
		vim.api.nvim_win_set_cursor(0, { row, cursor_position - 1 })
	end
end

vim.keymap.set("i", "<Tab>", Snippets.expands)
