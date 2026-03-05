-- TODO: multicursor
plugin("multicursor-nvim")
	:event("DeferredUIEnter")
	:keymaps({
		k:map("nx", "<C-Up>", k:require("multicursor-nvim").lineAddCursor(-1), "add cursor top"),
		k:map("nx", "<C-Down>", k:require("multicursor-nvim").lineAddCursor(1), "add cursor under"),
		k:map("nx", "<C-Left>", k:require("multicursor-nvim").lineSkipCursor(-1), "skip cursor top"),
		k:map("nx", "<C-Right>", k:require("multicursor-nvim").lineSkipCursor(1), "skip cursor under"),
		k:map("nx", "<M-m>", k:require("multicursor-nvim").toggleCursor(), "toggle multicursor"),
		k:map("nx", "<M-M>", k:require("multicursor-nvim").matchAllAddCursors(), "toggle multicursor"),
	})
	:after(function()
		local mc = require("multicursor-nvim")

		mc.addKeymapLayer(function(layerSet)
			layerSet("n", "<M-a>", mc.alignCursors)
			-- add or skip adding a cursor by matching word selection
			layerSet({ "n", "x" }, "<M-w>", function()
				mc.matchAddCursor(1)
			end)
			layerSet({ "n", "x" }, "<M-s>", function()
				mc.matchSkipCursor(1)
			end)
			layerSet({ "n", "x" }, "<M-W>", function()
				mc.matchAddCursor(-1)
			end)
			layerSet({ "n", "x" }, "<M-S>", function()
				mc.matchSkipCursor(-1)
			end)

			-- Select a different cursor as the main one.
			layerSet({ "n", "x" }, "<Up>", mc.prevCursor)
			layerSet({ "n", "x" }, "<Down>", mc.nextCursor)

			-- Delete the main cursor.
			layerSet({ "n", "x" }, "<C-x>", mc.deleteCursor)

			-- Enable and clear cursors using escape.
			layerSet("n", "<esc>", function()
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				else
					mc.clearCursors()
				end
			end)
		end)
	end)
