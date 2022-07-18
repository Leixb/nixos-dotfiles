local null_ls = require("null-ls")

-- register any number of sources simultaneously
local sources = {
	null_ls.builtins.completion.spell,
	null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.vale.with({
        filetypes = { "text", "markdown", "tex", "asciidoc", "norg" },
    }),
	null_ls.builtins.formatting.stylua,
    null_ls.builtins.hover.dictionary.with({
        filetypes = { "text", "markdown", "tex", "asciidoc", "norg" },
    }),
}

-- lsp_attach from lsp_config file
null_ls.setup({ sources = sources, on_attach = lsp_attach })
