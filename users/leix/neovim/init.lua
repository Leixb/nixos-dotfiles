--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

local opts = {
    encoding      = 'utf-8',
    termguicolors = true,

    backup        = false,
    writebackup   = false,
    undofile      = true,

    smarttab      = true,

    ignorecase    = true,
    smartcase     = true,

    splitbelow    = true,
    splitright    = true,

    showmode      = false,
    ruler         = false,

    cmdheight     = 1,

    updatetime    = 300,
    ttimeoutlen   = 10,
    timeoutlen    = 500,
    lazyredraw    = true,

    title         = true,

    wildmenu      = true,
    wildignore    = {'*.o', '*.a', '__pycache__'},
    hidden        = true,
    scrolloff     = 10,
    showtabline   = 2,

    hlsearch      = true,
    incsearch     = true,

    -- virtualedit   = 'block',
    backspace     = {'indent', 'eol', 'start'},

    shortmess     = 'filnxtToOIc',

    completeopt   = {'menuone', 'noinsert', 'noselect'},

    cursorline    = true,
    number        = true,
    signcolumn    = 'yes',
    foldenable    = false,

    autoindent    = true,
    smartindent   = true,

    infercase     = true,

    expandtab     = true,

    shiftwidth    = 4,
    softtabstop   = 4,
    tabstop       = 4,

    textwidth     = 80,
    wrap          = true,
    formatoptions = 'jcroql',

    omnifunc      = 'v:lua.vim.lsp.omnifunc',

    laststatus    = 3, -- Global statusline
}

for k, v in pairs(opts) do
	vim.opt[k] = v
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

vim.api.nvim_command('let mapleader=" "')

local nmap = {
    ['<space>'] = '<NOP>',

    ['<C-j>'] = '<C-w><C-j>',
    ['<C-k>'] = '<C-w><C-k>',
    ['<C-l>'] = '<C-w><C-l>',
    ['<C-h>'] = '<C-w><C-h>',

    ['<F2>']  = {'<cmd>BufferPrevious<CR>',  { noremap = true , silent = true, desc = "BufferPrevious" }},
    ['<F3>']  = {'<cmd>BufferNext<CR>',      { noremap = true , silent = true, desc = "BufferNext" }},
    ['<F4>']  = {'<cmd>SymbolsOutline<CR>',     { noremap = true , silent = true, desc = "SymbolsOutline toggle" }},

    ['<leader>bd'] = {'<cmd>BufferClose<CR>', {noremap = true, silent = true, desc = "BufferClose"}},

    ['<F12>'] = {'magg=G`a',             { noremap = true , silent = true, desc = "Reindent"}},

    ['Y'] = {'y$', {desc = "Yank till eol"}},

    ['n'] = {'nzzzv', {desc = "Next centered"}},
    ['N'] = {'Nzzzv', {desc = "Backwards Next centered"}},

-- LSP mappings

    ['[g']         = {vim.diagnostic.goto_prev,  {silent = true, desc = "Goto prev diagnostic"}},
    [']g']         = {vim.diagnostic.goto_next,  {silent = true, desc = "Goto next diagnostic" }},
    ['<leader>ld'] = {vim.diagnostic.open_float, {silent = true, nowait = true, noremap = true, desc = "Show line diagnostics"}},
    ['<leader>d']  = {vim.diagnostic.setloclist, {silent = true, nowait = true, noremap = true, desc = "Set location list"}},

    ['gd']         = {vim.lsp.buf.definition,      { silent = true, desc = "Goto definition" }},

    ['gy']         = {vim.lsp.buf.type_definition, { silent = true, desc = "Goto type definition" }},
    ['gi']         = {vim.lsp.buf.implementation,  { silent = true, desc = "Goto implementation" }},
    ['gr']         = {vim.lsp.buf.references,      { silent = true, desc = "Goto references"}},

    ['<leader>rn'] = {vim.lsp.buf.rename,                                               { noremap = true, silent = true, desc = "Rename" }},
    ['<leader>f']  = {vim.lsp.buf.formatting,                                           { desc = "Format buffer" }},

    ['K']          = {vim.lsp.buf.hover,         { silent = true, noremap = true, desc = "Hover definition"}},
    ['<c-S>']      = {vim.lsp.buf.signature_help, { noremap = true, silent = true, desc = "Show signature help" }},

    ['<leader>i']  = {vim.lsp.buf.incoming_calls,                {silent = true, nowait = true, noremap = true, desc = "Show incoming calls"}},
    ['<leader>o']  = {vim.lsp.buf.outgoing_calls,                {silent = true, nowait = true, noremap = true, desc = "Show outgoing calls"}},
    ['<leader>s']  = {vim.lsp.buf.document_symbol,               {silent = true, nowait = true, noremap = true, desc = "Show document symbols"}},
    ['<leader>w']  = {vim.lsp.buf.workspace_symbol,              {silent = true, nowait = true, noremap = true, desc = "Show workspace symbols"}},

    ['<leader>a']  = {function() require'code_action_menu'.open_code_action_menu() end, { noremap = true, silent = true, desc = "Open code action menu"}},

    -- Close location, quickfix and help windows
    ['<leader>c']  = {'<cmd>ccl <bar> lcl <bar> helpc <CR>', {desc = "Close location, qf and help windows"}},
}

local imap = {
    ['jk']        = '<ESC>',
    ['<F13>']     = {'<Plug>luasnip-next-choice',     {silent = true, desc = "Luasnip next choice"}},
    ['']         = {'<Plug>luasnip-next-choice',     {silent = true, desc = "Luasnip next choice"}},

    ['<c-S>']     = {vim.lsp.buf.signature_help, {noremap = true, desc = "Show signature help"}},
}

local smap = {
    ['<F13>']     = {'<Plug>luasnip-next-choice',                 {silent = true, desc = "Luasnip next choice"}},
    ['']         = {'<Plug>luasnip-next-choice',                 {silent = true, desc = "Luasnip next choice"}},
}
local xmap = {}
local omap = {}
local vmap = { }

local tmap = {
    ['<ESC>'] = {'<C-\\><C-n>', {desc = "Terminal ESC"}}
}

local cmap = {
    ['jk'] = {'<ESC>', {desc = "ESC"}}
}

local default_args = { noremap = true }

for mode, map in pairs({ n = nmap, v = vmap, s = smap, t = tmap, c = cmap, i = imap, x = xmap, o = omap }) do
    for from, to in pairs(map) do
        if type(to) == 'table' then
            vim.keymap.set(mode, from, to[1], to[2])
        else
            vim.keymap.set(mode, from, to, default_args)
        end
    end
end

--------------------------------------------------------------------------------
-- NETRW
--------------------------------------------------------------------------------

vim.g.netrw_banner    = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize   = 30

--------------------------------------------------------------------------------
-- augroups
--------------------------------------------------------------------------------

local group_id = vim.api.nvim_create_augroup('init.lua.group', {})

vim.api.nvim_create_autocmd(
    'TermOpen',
    {
        pattern = 'term://*',
        callback = function()
            vim.wo.number = false
        end,
        group = group_id
    })


vim.api.nvim_create_autocmd(
    'BufRead',
    {
        pattern = 'flake.lock',
        callback = function()
            vim.bo.ft = 'json'
        end,
        group = group_id
    })

vim.api.nvim_create_autocmd(
    'TermOpen',
    {
        pattern = '*',
        command = 'startinsert',
        group = group_id
    })

vim.api.nvim_create_autocmd(
    'TextYankPost',
    {
        pattern = '*',
        callback = function() vim.highlight.on_yank() end,
        group = group_id
    })

vim.api.nvim_create_autocmd(
    'FileType',
    {
        pattern = {
            'gitcommit',
            'gitrebase',
            'latex',
            'markdown',
            'norg',
            'rmd',
            'tex',
            'text',
        },
        command = 'setlocal spell',
        group = group_id
    })

--------------------------------------------------------------------------------
-- commands
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command(
    'DiffOrig',
    'vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis',
    {}
)

vim.api.nvim_create_user_command(
    'T',
    'split | terminal <args>',
    { nargs='*' }
)

vim.api.nvim_create_user_command(
    'VT',
    'vsplit | terminal <args>',
    { nargs='*' }
)
