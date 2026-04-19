local ok_dap, dap = pcall(require, "dap")
local ok_ui, dapui = pcall(require, "dapui")
if not ok_dap or not ok_ui then
	return {}
end

local lldb_dap = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap"
if vim.fn.executable(lldb_dap) ~= 1 then
	return {}
end

dap.adapters.lldb = {
	type = "executable",
	command = lldb_dap,
	name = "lldb",
}

local function default_program()
	local default = vim.fn.getcwd() .. "/"
	local ok, cpp = pcall(require, "tools.cpp")
	if ok then
		local root = cpp.find_project_root(0)
		if root then
			local execs = cpp.find_executables(root .. "/build")
			if #execs >= 1 then
				default = execs[1]
			end
		end
	end
	return vim.fn.input("Path to executable: ", default, "file")
end

local cpp_config = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = default_program,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
dap.configurations.cpp = cpp_config
dap.configurations.c = cpp_config
dap.configurations.objc = cpp_config
dap.configurations.objcpp = cpp_config

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

return {
	keymaps = {
		{ { "n" }, "<leader>dc", function() dap.continue() end, { desc = "DAP continue" } },
		{ { "n" }, "<leader>dn", function() dap.step_over() end, { desc = "DAP step over (next)" } },
		{ { "n" }, "<leader>di", function() dap.step_into() end, { desc = "DAP step into" } },
		{ { "n" }, "<leader>do", function() dap.step_out() end, { desc = "DAP step out" } },
		{ { "n" }, "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP toggle breakpoint" } },
		{ { "n" }, "<leader>du", function() dapui.toggle() end, { desc = "DAP toggle UI" } },
		{ { "n" }, "<leader>dt", function() dap.terminate() end, { desc = "DAP terminate" } },
	},
}
