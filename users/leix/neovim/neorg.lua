require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ["core.gtd.base"] = {
            config = {
                workspace = "general",
            }
        },
        ["core.norg.dirman"] = {
            config = {
                workspaces = {
                    general = "~/Documents/neorg/general",
                    uni = "~/Documents/neorg/upc",
                    work = "~/Documents/neorg/work",
                    home = "~/Documents/neorg/home",
                }
            }
        },
        ["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
        ["core.norg.qol.toc"] = {},
        ["core.export"] = {},
        ["core.norg.journal"] = {},
        ["core.norg.concealer"] = {},
        ["core.export.markdown"]  = {},
    }
}




