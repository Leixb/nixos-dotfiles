local lspconfig = require("lspconfig")

-- disable autostart on pavilion
-- since resources are limited there
local autostart = vim.fn.hostname() ~= "nixos-pav"

vim.keymap.set(
	"n",
	"<leader>e",
	vim.diagnostic.open_float,
	{ noremap = true, silent = true, desc = "Show line diagnostics" }
)
vim.keymap.set(
	"n",
	"[g",
	vim.diagnostic.goto_prev,
	{ noremap = true, silent = true, desc = "Go to previous diagnostic" }
)
vim.keymap.set("n", "]g", vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Go to next diagnostic" })
vim.keymap.set(
	"n",
	"<leader>q",
	vim.diagnostic.setloclist,
	{ noremap = true, silent = true, desc = "Show diagnostic locations" }
)

local function lsp_attach(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions

	vim.keymap.set(
		"n",
		"gD",
		vim.lsp.buf.declaration,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Goto declaration" }
	)
	vim.keymap.set(
		"n",
		"gd",
		vim.lsp.buf.definition,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Goto definition" }
	)
	vim.keymap.set(
		"n",
		"K",
		vim.lsp.buf.hover,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Show hover info" }
	)
	vim.keymap.set(
		"n",
		"gi",
		vim.lsp.buf.implementation,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Goto implementation" }
	)
	vim.keymap.set(
		{ "n", "i" },
		"<C-s>",
		vim.lsp.buf.signature_help,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Show signature help" }
	)
	vim.keymap.set(
		"n",
		"<leader>wa",
		vim.lsp.buf.add_workspace_folder,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Add workspace folder" }
	)
	vim.keymap.set(
		"n",
		"<leader>wr",
		vim.lsp.buf.remove_workspace_folder,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Remove workspace folder" }
	)

	vim.keymap.set("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, { noremap = true, silent = true, buffer = bufnr, desc = "List workspace folders" })

	vim.keymap.set(
		"n",
		"<leader>D",
		vim.lsp.buf.type_definition,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Get type definition" }
	)
	vim.keymap.set(
		"n",
		"<leader>rn",
		vim.lsp.buf.rename,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Rename symbol" }
	)

	vim.keymap.set(
		"n",
		"<leader>a",
		function()
			require("code_action_menu").open_code_action_menu()
		end, -- vim.lsp.buf.code_action,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Show code actions" }
	)

	vim.keymap.set(
		"n",
		"gr",
		vim.lsp.buf.references,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Find references" }
	)
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, { noremap = true, silent = true, buffer = bufnr, desc = "Format buffer" })

	vim.keymap.set(
		"n",
		"<leader>i",
		vim.lsp.buf.incoming_calls,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Get incoming calls" }
	)
	vim.keymap.set(
		"n",
		"<leader>o",
		vim.lsp.buf.outgoing_calls,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Get outgoing calls" }
	)
	vim.keymap.set(
		"n",
		"<leader>s",
		vim.lsp.buf.document_symbol,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Get document symbols" }
	)
	vim.keymap.set(
		"n",
		"<leader>w",
		vim.lsp.buf.workspace_symbol,
		{ noremap = true, silent = true, buffer = bufnr, desc = "Get workspace symbols" }
	)

	require("lsp_signature").on_attach()

	require("notify")(string.format("[lsp] %s", client.name), "info", { render = "minimal", timeout = 2000 })

	if client.server_capabilities.codeLensProvider then
		vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
			buffer = bufnr,
			callback = vim.lsp.codelens.refresh,
		})
	end

	if client.server_capabilities.documentHightlightProvider then
		local group_id = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
			group = group_id,
		})

		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
			group = group_id,
		})
	end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lsp_list = {
	-- 'bashls', -- high CPU usage...
	"cssls",
	"dartls",
	"dockerls",
	"eslint",
	"gopls",
	-- 'hls',
	"html",
	"jdtls",
	"jsonls",
	"julials",
	-- 'kotlin_language_server',
	-- "rnix",
	"r_language_server",
	-- 'rls',
	"svelte",
	"texlab",
	"tsserver",
	-- "vimls",
}

for _, val in pairs(lsp_list) do
	lspconfig[val].setup({
		on_attach = lsp_attach,
        autostart = autostart,
		capabilities = capabilities,
	})
end

lspconfig.yamlls.setup({
    on_attach = lsp_attach,
    autostart = autostart,
    capabilities = capabilities,
    settings = {
        yaml = {
            keyOrdering = false,
        }
    }
})

lspconfig.nil_ls.setup({
	on_attach = lsp_attach,
    autostart = autostart,
	capabilities = capabilities,
	settings = {
		["formatting.command"] = "nixpkgs-fmt",
	},
})

-- Fix clangd warning on mixed encoding
local capabilities_16 = capabilities
capabilities_16.offsetEncoding = { "utf-16" }
lspconfig.clangd.setup({
	on_attach = lsp_attach,
    autostart = autostart,
	capabilities = capabilities_16,
})

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lspconfig.pylsp.setup({
	on_attach = lsp_attach,
    autostart = autostart,
	capabilities = capabilities,
	settings = {
		formatCommand = { "black" },
		pylsp = {
			plugins = {
				-- pylint = {args = {'--ignore=E501', '-'}, enabled=true, debounce=200},
				ruff = {
					enabled = true,
					lineLength = 120,
				},
				pyls_mypy = {
					enabled = true,
				},
			},
		},
	},
})

lspconfig.lua_ls.setup({
    autostart = autostart,
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Setup your lua path
				path = runtime_path,
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
	capabilities = capabilities,
	on_attach = lsp_attach,
})

-- Diagnostics

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	-- Enable underline, use default values
	underline = true,
	-- Enable virtual text, override spacing to 4
	virtual_text = {
		spacing = 4,
		prefix = "~",
	},
	-- Use a function to dynamically turn signs off
	-- and on, using buffer local variables
	signs = function(bufnr, _)
		local ok, result = pcall(vim.api.nvim_buf_get_var, bufnr, "show_signs")
		-- No buffer local variable set, so just enable by default
		if not ok then
			return true
		end

		return result
	end,
	-- Disable a feature
	update_in_insert = false,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
})

local notify = require("notify")
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	local lvl = ({
		"ERROR",
		"WARN",
		"INFO",
		"DEBUG",
	})[result.type]
	notify({ result.message }, lvl, {
		title = "LSP | " .. client.name,
		timeout = 10000,
		keep = function()
			return lvl == "ERROR" or lvl == "WARN"
		end,
	})
end

local signs = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
}

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- set up vim.diagnostics
-- vim.diagnostic.config opts
vim.diagnostic.config({
	underline = true,
	signs = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		focusable = false,
		header = { " " .. " Diagnostics:", "Normal" },
		source = "always",
	},
	virtual_text = {
		spacing = 4,
		source = "always",
		severity = {
			min = vim.diagnostic.severity.HINT,
		},
	},
})
