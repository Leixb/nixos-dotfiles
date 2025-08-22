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

    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    vim.keymap.set(
        { "n", "i" },
        "<C-s>",
        vim.lsp.buf.signature_help,
        { noremap = true, silent = true, buffer = bufnr, desc = "Signature Documentation" }
    )

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")
    nmap("<leader>fi", vim.lsp.buf.incoming_calls, "[F]unction [I]ncoming calls")
    nmap("<leader>fo", vim.lsp.buf.outgoing_calls, "[F]unction [O]utgoing calls")

    nmap("<leader>F", vim.lsp.buf.format, "[F]ormat buffer")

    -- require("lsp-format").on_attach(client)
    require("lsp_signature").on_attach({}, bufnr)

    require("notify")(string.format("[LSP] %s", client.name), "info", { render = "minimal", timeout = 2000 })

    -- if client.server_capabilities.codeLensProvider then
    --     vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    --         buffer = bufnr,
    --         callback = vim.lsp.codelens.refresh,
    --     })
    -- end

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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local lsp_list = {
    -- 'bashls', -- high CPU usage...
    "cssls",
    "dartls",
    "dockerls",
    "eslint",
    "gopls",
    -- 'hls',
    "html",
    "marksman",
    "jdtls",
    "jsonls",
    "taplo", -- toml lsp
    "julials",
    -- 'kotlin_language_server',
    -- "rnix",
    "r_language_server",
    -- 'rls',
    "svelte",
    "texlab",
    "ts_ls",
    "ty",
    -- 'hls',
    "yamlls",
    "nil_ls",
    "clangd",
    "pylsp",
    "lua_ls",
    -- "vimls",
}

for _, val in pairs(lsp_list) do
    vim.lsp.enable(val)
end

vim.lsp.config("*", {
    on_attach = lsp_attach,
    autostart = autostart,
    capabilities = capabilities,
})

-- vim.lsp.config('hls', {
--     filetypes = { "haskell", "lhaskell", "cabal" },
--     on_attach = lsp_attach,
--     autostart = autostart,
--     capabilities = capabilities,
-- })

vim.g.haskell_tools = {
    ---@type ToolsOpts
    tools = {
        -- ...
    },
    ---@type HaskellLspClientOpts
    hls = {
        ---@param client number The LSP client ID.
        ---@param bufnr number The buffer number
        ---@param ht HaskellTools = require('haskell-tools')
        on_attach = lsp_attach,
        -- ...
    },
    ---@type HTDapOpts
    dap = {
        -- ...
    },
}

vim.lsp.config("yamlls", {
    on_attach = lsp_attach,
    autostart = autostart,
    capabilities = capabilities,
    settings = {
        yaml = {
            keyOrdering = false,
        },
    },
})

vim.lsp.config("nil_ls", {
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
vim.lsp.config("clangd", {
    on_attach = lsp_attach,
    autostart = autostart,
    capabilities = capabilities_16,
})

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

vim.lsp.config("pylsp", {
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

vim.lsp.config("lua_ls", {
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
    notify(result.message, lvl, {
        title = "LSP | " .. client.name,
        timeout = 10000,
        keep = function()
            return lvl == "ERROR" or lvl == "WARN"
        end,
    })
end

-- set up vim.diagnostics
-- vim.diagnostic.config opts
vim.diagnostic.config({
    underline = true,
    signs = {
        text = {
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.ERROR] = " ",
        },
    },
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
