require("notify").setup({
	max_width = 75,
})
vim.notify = require("notify")

vim.keymap.set("n", "<leader>nd", vim.notify.dismiss,
    { noremap = true, silent = true, desc = "Dismiss notification" })

vim.keymap.set("n", "<leader>nn", "<cmd>Telescope notify<CR>",
    { noremap = true, silent = true, desc = "Open notification list" })
