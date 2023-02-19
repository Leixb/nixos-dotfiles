require("catppuccin").setup({
	flavour = "macchiato", -- latte, frappe, macchiato, mocha
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
})

vim.cmd.colorscheme("catppuccin")
