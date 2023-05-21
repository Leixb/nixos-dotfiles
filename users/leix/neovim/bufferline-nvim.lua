local bufferline = require('bufferline')

bufferline.setup {
    options = {
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        show_buffer_close_icons = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " "
              or (e == "warning" and " " or "" )
            s = s .. n .. sym
          end
          return s
        end
    }
}

vim.keymap.set("n", "<F2>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<F3>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>BufferLinePickClose<CR>", { noremap = true, silent = true, desc = "Close buffer" })
