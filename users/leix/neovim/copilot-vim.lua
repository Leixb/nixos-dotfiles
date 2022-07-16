vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
    ["dap-repl"] = false,
}
vim.keymap.set('i', '<M-;>', 'copilot#Accept("<M-;>")', {silent = true, noremap = true, expr = true, desc = "Copilot accept"})
