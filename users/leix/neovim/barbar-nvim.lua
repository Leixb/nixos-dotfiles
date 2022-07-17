vim.g.bufferline = { closable = false }

vim.keymap.set("n", "<F2>", "<cmd>BufferPrevious<CR>", { noremap = true, silent = true, desc = "BufferPrevious" })
vim.keymap.set("n", "<F3>", "<cmd>BufferNext<CR>", { noremap = true, silent = true, desc = "BufferNext" })
vim.keymap.set("n", "<leader>bd", "<cmd>BufferClose<CR>", { noremap = true, silent = true, desc = "BufferClose" })
