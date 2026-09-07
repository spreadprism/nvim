local M = {}

M.ft = require("internal.pi.ft")
M.oil_mention = require("internal.pi.mention").oil
M.track_last_buffer = require("internal.pi.mention").track
M.last_buffer_mention = require("internal.pi.mention").last
M.pick_mentions = require("internal.pi.mention").pick
M.register_tool_renderers = require("internal.pi.tools").register
M.close_when_last = require("internal.pi.window").close_when_last

return M
