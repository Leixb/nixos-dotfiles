vim.g.tex_flavor = "latex"

vim.g.vimtex_compiler_progname = "nvr"
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_view_use_temp_files = 1
vim.g.vimtex_compiler_latexmk = {
	backend = "nvim",
	background = 1,
	build_dir = "",
	callback = 1,
	continuous = 1,
	executable = "latexmk",
	hooks = {},
	options = {
		"-verbose",
		"-file-line-error",
		"-synctex=1",
		"-shell-escape",
		"-interaction=nonstopmode",
	},
}
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_engine = "lualatex"
vim.g.vimtex_compiler_latexmk_engines = {
	_ = "-lualatex", -- default to lualatex
	pdflatex = "-pdf",
	dvipdfex = "-pdfdvi",
	lualatex = "-lualatex",
	xelatex = "-xelatex",
	["context (pdftex)"] = "-pdf -pdflatex=texexec",
	["context (luatex)"] = "-pdf -pdflatex=context",
	["context (xetex)"] = "-pdf -pdflatex=''texexec --xtx''",
}
