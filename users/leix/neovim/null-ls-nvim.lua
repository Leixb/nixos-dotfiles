require("null-ls").setup({
    sources = {
        require("null-ls").builtins.completion.spell,
        require("null-ls").builtins.diagnostics.eslint,
        require("null_ls").builtins.diagnostics.actionlint,
        require("null-ls").builtins.formatting.stylua,
    },
})
