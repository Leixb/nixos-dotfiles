require('blink.cmp').setup({
    keymap = { preset = 'enter' },
    appearance = {
        nerd_font_variant = 'mono'
    },
    completion = {
        documentation = { auto_show = true },
        list = { selection = { preselect = false } }
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'digraphs', 'calc', 'latex' },
        providers = {
            digraphs = {
                name = 'digraphs',
                module = 'blink.compat.source',
                score_offset = -3,
            },
            calc = {
                name = 'calc',
                module = 'blink.compat.source',
            },
            latex = {
                name = 'latex_symbols',
                module = 'blink.compat.source',
                score_offset = -2,
            }
        }
    },
    fuzzy = {
        implementation = "prefer_rust_with_warning"
    },
    cmdline = {
        enabled = true,
        completion = {
            menu = {
                auto_show = function(ctx)
                    return vim.fn.getcmdtype() == ':'
                end,
            },
        }
    }
})
