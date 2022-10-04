local rt = require("rust-tools")

rt.setup({
	tools = {
		autoSetHints = true,
		runnables = { use_telescope = true },

		inlay_hints = {
			show_parameter_hints = true,
		},
	},
	server = {
		on_attach = function(client, bufnr)
			lsp_attach(client, bufnr)

			-- Hover actions
			vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr, desc = "Hover action" })
			-- Code action groups
			vim.keymap.set(
				"n",
				"<Leader>a",
				rt.code_action_group.code_action_group,
				{ buffer = bufnr, desc = "Code action" }
			)
		end,
	},
})
