local bufferline = require('bufferline')

bufferline.setup {
    options = {
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        show_buffer_close_icons = false,
    }
}

vim.keymap.set("n", "<F2>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<F3>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>BufferLinePickClose<CR>", { noremap = true, silent = true, desc = "Close buffer" })
