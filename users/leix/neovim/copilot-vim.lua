vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
	["dap-repl"] = false,
}
vim.keymap.set(
	"i",
	"<Plug>(vimrc:copilot-dummy-map)",
	'copilot#Accept("")',
	{ silent = true, expr = true, desc = "Copilot dummy accept" }
)
