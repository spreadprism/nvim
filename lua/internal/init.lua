local M = {}

M.plugin = require("internal.loader.plugin").plugin

for k, v in pairs(M) do
	_G[k] = v
end

_G.internal = M
_G.plugin = M.plugin
