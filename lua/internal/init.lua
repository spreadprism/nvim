local M = {}

M.load_all = require("internal.loader").load_all

for k, v in pairs(M) do
	_G[k] = v
end

_G.internal = M
