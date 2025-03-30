local M = {}

function M.dapfunc(fname)
	if M[fname] ~= nil and M[fname] ~= M.dapfunc and type(M[fname]) == "function" then
		return M[fname]
	end
	return function()
		require("dap")[fname]()
	end
end

function M.log_point()
	local condition = vim.fn.input("Condition: ")
	if condition ~= nil and condition ~= "" then
		require("dap").set_breakpoint(condition)
	end
end

function M.cond_point()
	local condition = vim.fn.input("Condition: ")
	if condition ~= nil and condition ~= "" then
		require("dap").set_breakpoint(condition)
	end
end

function M.terminate()
	require("dap").terminate()
	local ok, dapui = pcall(require, "dapui")
	if ok then
		dapui.close()
	end
end

function M.eval()
	local ok, dapui = pcall(require, "dapui")
	dapui.eval()
end

function M.debug_test()
	local ok, neotest = pcall(require, "neotest")
	if ok then
		neotest.run.run({ strategy = "dap" })
	else
		vim.notify("Neotest not found", vim.log.levels.WARN)
	end
end

---@param access string
return function(access)
	return M.dapfunc(access)
end
