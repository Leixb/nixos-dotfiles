local luasnip = require("luasnip")
local cmp = require("cmp")

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping(function(fallback)
            if luasnip.choice_active() then
                luasnip.change_choice(1)
            elseif cmp.visible() then
                cmp.mapping.close()
            else
                fallback()
            end
        end),

        ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand()
                elseif cmp.get_selected_entry() then
                    cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = false,
                    })
                else
                    fallback()
                end
            else
                fallback()
            end
        end
        )
    ,
        -- Super tab with priority for luasnip jumps
        -- Selections can still be done through C-{n,p}
        ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            elseif cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            elseif cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "calc" },
        { name = "path" },
        { name = "nvim_lua" },
        { name = "latex_symbols" },
        { name = "neorg" },
        { name = "conjure" },
        { name = "orgmode" },
    }, {
        { name = "buffer" },
    }),
    formatting = {
        format = function(entry, vim_item)
            -- fancy icons and a name of kind
            vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind

            -- set a name for each source
            vim_item.menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                nvim_lua = "[Lua]",
                latex_symbols = "[Latex]",
                path = "[Path]",
                calc = "[Calc]",
                neorg = "[Neorg]",
            })[entry.source.name]
            return vim_item
        end,
    },
})

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "cmp_git" },
        { name = "path" },
    }, {
        { name = "buffer" },
        { name = "dictionary" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
