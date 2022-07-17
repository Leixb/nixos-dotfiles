local null_ls = require("null-ls")

-- register any number of sources simultaneously
local sources = {
	null_ls.builtins.completion.spell,
	null_ls.builtins.diagnostics.eslint,
	null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.vale,
	null_ls.builtins.formatting.stylua,
}

null_ls.setup({ sources = sources })
