return function(path, filename)
	local dir = vim.fn.fnamemodify(path, ":t")

	return [[
package ]] .. dir .. [[


import "testing"

|cursor|]]
end
