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

vim.keymap.set("n", "<C-S-p>", function()
	require("telescope.builtin").git_files()
end, { desc = "Telescope git_files" })
vim.keymap.set("n", "<C-p>", function()
	require("telescope.builtin").fd()
end, { desc = "Telescope fd" })
vim.keymap.set("n", "<leader><leader>", function()
	require("telescope.builtin").buffers()
end, { desc = "Telescope buffers" })
vim.keymap.set("n", "<Bs>", function()
	require("telescope.builtin").live_grep()
end, { desc = "Telescope live_grep" })
vim.keymap.set("n", "<CR>", function()
	if vim.bo.buftype == "" then
		require("telescope.builtin").builtin()
	else
		vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n")
	end
end, { desc = "Telescope" })
