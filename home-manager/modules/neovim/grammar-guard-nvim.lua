require("grammar-guard").init()

vim.lsp.config("grammar_guard", {
    cmd = { "ltex-ls" },
    autostart = autostart,
    settings = {
        ltex = {
            enabled = { "latex", "tex", "bib", "markdown", "norg", "neorg" },
            language = "en",
            diagnosticSeverity = "information",
            setenceCacheSize = 2000,
            additionalRules = {
                enablePickyRules = true,
                motherTongue = "en",
            },
            trace = { server = "verbose" },
            dictionary = {},
            disabledRules = {},
            hiddenFalsePositives = {},
        },
    },
})
