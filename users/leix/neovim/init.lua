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

	updatetime = 300,
	ttimeoutlen = 10,
	timeoutlen = 500,
	lazyredraw = true,

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
	number = true,
	signcolumn = "yes",
	foldenable = false,

	autoindent = true,
	smartindent = true,

	infercase = true,

	expandtab = true,

	shiftwidth = 4,
	softtabstop = 4,
	tabstop = 4,

	textwidth = 80,
	wrap = true,
	formatoptions = "jcroql",

	laststatus = 3, -- Global statusline
}

for k, v in pairs(opts) do
	vim.opt[k] = v
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

vim.g.mapleader = " "

vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { noremap = true })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { noremap = true })

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

vim.keymap.set({ "i", "c" }, "jk", "<ESC>")

vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { desc = "Terminal ESC" })

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"gitcommit",
		"gitrebase",
		"latex",
		"markdown",
		"norg",
		"rmd",
		"tex",
		"text",
	},
	callback = function()
		vim.bo.spell = true
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
