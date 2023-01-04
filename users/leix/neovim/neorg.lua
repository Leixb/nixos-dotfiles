require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.keybinds"] = {
			config = {
				neorg_leader = "<leader>",
			},
		},
		["core.norg.dirman"] = {
			config = {
				workspaces = {
					root = "~/Documents/neorg",
					notes = "~/Documents/neorg/notes",
					blog = "~/Documents/neorg/blog",
				},
			},
		},
		["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
		["core.norg.qol.toc"] = {},
		["core.export"] = {},
		["core.norg.journal"] = {
			config = {
				workspace = "root",
			},
		},
		["core.norg.concealer"] = {},
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
