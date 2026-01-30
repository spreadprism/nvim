local loader = require("internal.loader")

loader.read_plugins()
loader.read_languages()
loader.load_plugins()
loader.load_lsp()
