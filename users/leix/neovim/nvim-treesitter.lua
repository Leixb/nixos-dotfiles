require'nvim-treesitter.configs'.setup {
    highlight = {enable = true},
    indent = {enable = true},
    autopairs = {enable = true},
    rainbow = {enable = true},
    autotag = {enable = true},
    context_commentstring = {enable = true},
}
vim.g.foldmethod    = 'expr'
vim.g.foldexpr      = 'nvim_treesitter#foldexpr()'
