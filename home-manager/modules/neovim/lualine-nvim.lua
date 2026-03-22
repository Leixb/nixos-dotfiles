require("lualine").setup({
    options = { globalstatus = true, theme = "catppuccin-macchiato" },
    sections = {
        lualine_c = { "filename", { "diagnostics", sources = { "nvim_diagnostic" } } },
    },
})
