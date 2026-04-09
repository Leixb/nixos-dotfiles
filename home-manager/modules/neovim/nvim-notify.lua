require("notify").setup({
    max_width = 75,
    on_open = function(win)
        vim.api.nvim_win_set_config(win, { border = "none" })
    end,
})
vim.notify = require("notify")

vim.keymap.set("n", "<leader>nd", vim.notify.dismiss, { noremap = true, silent = true, desc = "Dismiss notification" })

vim.keymap.set(
    "n",
    "<leader>nn",
    "<cmd>Telescope notify<CR>",
    { noremap = true, silent = true, desc = "Open notification list" }
)
