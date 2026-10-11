plugin("snacks")
	:opts({
		image = {
			enabled = true,
		},
		inputs = {
			enabled = true,
		},
		---@type snacks.picker.Config
		picker = {
			main = {
				file = false,
			},
			enabled = true,
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					-- pi.nvim (`pi/ui/winfix.lua`) resets window options on every
					-- `BufEnter` into a window carrying its fingerprint
					-- (`concealcursor=nvic` + no number/relativenumber/cursorline).
					-- Snacks never sets `concealcursor` on the input window, so a
					-- picker opened from the PI sidebar inherits `nvic` from the pi
					-- window, matches the fingerprint and gets `signcolumn` reset to
					-- the global default (`yes`) -> extra blank column in the input.
					-- Setting it explicitly breaks the fingerprint.
					wo = { concealcursor = "nvc" },
					keys = {
						["<S-CR>"] = { "tab", mode = { "n", "i" } },
					},
				},
			},
			on_show = function(_)
				vim.api.nvim_exec_autocmds("User", { pattern = "PickerOnShowClose" })
			end,
			on_close = function(_)
				vim.api.nvim_exec_autocmds("User", { pattern = "PickerOnShowClose" })
			end,
			sources = {
				files = {
					layout = {
						preset = "select",
					},
				},
				grep = {
					layout = {
						preset = "telescope",
					},
				},
				lines = {
					layout = {
						preset = "ivy_split",
					},
				},
				lsp_symbols = {
					layout = {
						preset = "right",
					},
				},
				lsp_workspace_symbols = {
					layout = {
						preset = "telescope",
					},
				},
			},
		},
	})
	:allow_again(vim.env.PROF)
	:keymaps({
		k:map("n", "<leader><leader>", k:require("snacks.picker").files(), "find files"):hidden(),
		k:map("n", "<M-g>", k:require("snacks.picker").grep(), "grep project"),
		k:map("n", "<M-f>", k:require("snacks.picker").lines(), "find in buffer"),
		k:map("n", "<M-m>", k:require("snacks.picker").marks(), "find marks"),
		k:group("find", "<leader>f", {
			k:map("n", "h", k:require("snacks.picker").help(), "help"),
			k:map("n", "H", k:require("snacks.picker").highlights(), "highlights"),
			k:map("n", "l", k:require("snacks.picker").resume(), "last search"),
			k:map("n", "b", k:require("snacks.picker").buffers(), "buffers"),
		}),
		k:group("dev", "<leader>=", {
			k:map("n", "p", k:require("internal.profiler").toggle(), "toggle profile"),
		}),
	})
	:lazy(false)
