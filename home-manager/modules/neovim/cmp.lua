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
        default = { 'lsp', 'path', 'snippets', 'buffer', 'calc', 'latex' },
        providers = {
            calc = {
                name = 'calc',
                module = 'blink.compat.source',
                score_offset = -3,
            },
            latex = {
                name = 'latex_symbols',
                module = 'blink.compat.source',
                score_offset = -7,
            }
        }
    },
    fuzzy = {
        implementation = "prefer_rust_with_warning"
    },
    cmdline = {
        enabled = true,
        keymap = { preset = 'cmdline' },
        completion = {
            menu = {
                auto_show = function(ctx)
                    return vim.fn.getcmdtype() == ':'
                end,
            },
            list = {
                selection = {
                    -- When `true`, will automatically select the first item in the completion list
                    preselect = false,
                    -- When `true`, inserts the completion item automatically when selecting it
                    auto_insert = true,
                },
            },
        }
    }
})
