local group_id = vim.api.nvim_create_augroup('nvim-metals', {})

vim.api.nvim_create_autocmd(
    'FileType',
    {
        pattern = 'scala,sbt',
        callback = function()
            require("metals").initialize_or_attach({})
        end,
        group = group_id
    }
)
