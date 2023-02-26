vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
	["dap-repl"] = false,
}
vim.keymap.set(
	"i",
	"<M-;>",
	"copilot#Accept('')",
	{ noremap = true, silent = true, expr = true, replace_keycodes = false, desc = "Copilot accept" }
)

local map = vim.keymap.set
