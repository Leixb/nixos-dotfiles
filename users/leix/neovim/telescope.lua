local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		initial_mode = "insert",
		mappings = {
			i = {
				["<c-k>"] = actions.move_selection_previous,
				["<c-j>"] = actions.move_selection_next,
			},
		},
	},
})
require("telescope").load_extension("notify")
require("telescope").load_extension("fzf")

vim.keymap.set("n", "<C-p>", require("telescope.builtin").fd, { desc = "Telescope fd" })
vim.keymap.set("n", "<C-S-p>", require("telescope.builtin").git_files, { desc = "Telescope git_files" })
vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })

vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><leader>", require("telescope.builtin").buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<Bs>", require("telescope.builtin").live_grep, { desc = "Telescope live_grep" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })

vim.keymap.set("n", "<CR>", function()
	if vim.bo.buftype == "" then
		require("telescope.builtin").builtin()
	else
		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n")
	end
end, { desc = "Telescope" })

vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
