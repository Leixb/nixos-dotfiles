require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ["core.keybinds"] = {
           config = {
                neorg_leader = "<leader>",
           }
        },
        ["core.gtd.base"] = {
            config = {
                workspace = "gtd",
            }
        },
        ["core.norg.dirman"] = {
            config = {
                workspaces = {
                    notes = "~/Documents/neorg/notes",
                    gtd = "~/Documents/neorg/gtd",
                }
            }
        },
        ["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
        ["core.norg.qol.toc"] = {},
        ["core.export"] = {},
        ["core.norg.journal"] = {
            config = {
                workspace = "notes",
            }
        },
        ["core.norg.concealer"] = {},
        ["core.export.markdown"]  = {},
    }
}
