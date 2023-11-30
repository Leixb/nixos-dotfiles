require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        ["core.keybinds"] = {
            config = {
                neorg_leader = "<leader>",
            },
        },
        ["core.dirman"] = {
            config = {
                workspaces = {
                    root = "~/Documents/neorg",
                    tfm = "~/Documents/neorg/TFM",
                    gtd = "~/Documents/neorg/gtd",
                    notes = "~/Documents/neorg/notes",
                    blog = "~/Documents/neorg/blog",
                },
            },
        },
        ["core.completion"] = { config = { engine = "nvim-cmp" } },
        ["core.qol.toc"] = {},
        ["core.export"] = {},
        ["core.journal"] = {
            config = {
                workspace = "root",
            },
        },
        ["core.concealer"] = {},
        ["core.export.markdown"] = {
            config = {
                extensions = "all",
            },
        },
        ["core.presenter"] = {
            config = {
                zen_mode = "zen-mode",
            },
        },
    },
})
