require("catppuccin").setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
    custom_highlights = function(colors)
        return {
            WinSeparator = { fg = colors.blue },
        }
    end
})

vim.cmd.colorscheme("catppuccin")
