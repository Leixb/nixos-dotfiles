--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

local opts = {
    encoding = "utf-8",
    termguicolors = true,

    backup = false,
    writebackup = false,
    undofile = true,

    smarttab = true,

    ignorecase = true,
    smartcase = true,

    splitbelow = true,
    splitright = true,

    showmode = false,
    ruler = false,

    cmdheight = 1,

    updatetime = 250,
    ttimeoutlen = 10,
    timeoutlen = 300,

    title = true,

    wildmenu = true,
    wildignore = { "*.o", "*.a", "__pycache__" },
    hidden = true,
    scrolloff = 10,
    showtabline = 2,

    hlsearch = true,
    incsearch = true,

    -- virtualedit   = 'block',
    backspace = { "indent", "eol", "start" },

    shortmess = "filnxtToOIc",

    completeopt = { "menuone", "noinsert", "noselect" },

    cursorline = true,
    colorcolumn = "80,120",
    number = true,
    relativenumber = true,
    signcolumn = "yes",
    foldenable = false,

    autoindent = true,
    smartindent = true,
    breakindent = true,

    infercase = true,

    expandtab = true,

    shiftwidth = 4,
    softtabstop = 4,
    tabstop = 4,

    textwidth = 80,
    wrap = true,
    formatoptions = "jcroql",

    spell = true,

    laststatus = 3, -- Global statusline
    conceallevel = 2,
}

for k, v in pairs(opts) do
    vim.opt[k] = v
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true, desc = "Disable space since it is the leader" })

-- Word wrap aware navigation
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "<F12>", "magg=G`a", { noremap = true, silent = true, desc = "Reindent" })

vim.keymap.set("n", "Y", "y$", { desc = "Yank till eol", noremap = true })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next centered", noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Backwards Next centered", noremap = true })

vim.keymap.set(
    "n",
    "<leader>c",
    "<cmd>ccl <bar> lcl <bar> helpc <CR>",
    { desc = "Close location, qf and help windows" }
)
vim.keymap.set( "n", "<leader><S-c>", vim.cmd.close, { desc = "Close" })
vim.keymap.set( "n", "<leader>bd", vim.cmd.bdelete, { desc = "Delete buffer" })

vim.keymap.set({ "i", "c" }, "jk", "<ESC>", { desc = "jk to escape" })

vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { desc = "Terminal ESC" })

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })

vim.keymap.set({ "n", "i" }, "<A-k>", vim.cmd.cprev, { desc = "Go to prev entry in quickfix list" })
vim.keymap.set({ "n", "i" }, "<A-j>", vim.cmd.cnext, { desc = "Go to next entry in quickfix list" })

--------------------------------------------------------------------------------
-- NETRW
--------------------------------------------------------------------------------

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 30

--------------------------------------------------------------------------------
-- augroups
--------------------------------------------------------------------------------

local group_id = vim.api.nvim_create_augroup("init.lua.group", {})

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        vim.wo.number = false
    end,
    group = group_id,
})

vim.api.nvim_create_autocmd("BufRead", {
    pattern = "flake.lock",
    callback = function()
        vim.bo.ft = "json"
    end,
    group = group_id,
})

-- TODO: Until norg supports spellsitter, disable spellsitter on norg files
vim.api.nvim_create_autocmd("BufRead", {
    pattern = "*.norg",
    callback = function()
        vim.opt.spelloptions = ""
    end,
    group = group_id,
})

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    command = "startinsert",
    group = group_id,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank()
    end,
    group = group_id,
})

-- TODO: This is a hack to fix the issue with telescope and insert mode
-- (When opening a file in telescope, it opens in insert mode)
vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
        if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
        end
    end,
    group = group_id,
})

--------------------------------------------------------------------------------
-- commands
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command(
    "DiffOrig",
    "vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis",
    {}
)

vim.api.nvim_create_user_command("T", "split | terminal <args>", { nargs = "*" })

vim.api.nvim_create_user_command("VT", "vsplit | terminal <args>", { nargs = "*" })

vim.filetype.add({
    extension = {
        cl = "c", -- OpenCL kernels
    },
})
