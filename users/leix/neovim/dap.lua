vim.keymap.set('n', '<F6>'       , function() require'dap'.continue() end,                                             { noremap = true , silent = true, desc = "DAP continue"})
vim.keymap.set('n', '<F7>'       , function() require'dap'.step_over() end,                                            { noremap = true , silent = true, desc = "DAP step over" })
vim.keymap.set('n', '<F8>'       , function() require'dap'.step_into() end,                                            { noremap = true , silent = true, desc = "DAP step into"})
vim.keymap.set('n', '<F9>'       , function() require'dap'.step_out() end,                                             { noremap = true , silent = true, desc = "DAP setp out" })

vim.keymap.set('n', '<leader>b'  , function() require'dap'.toggle_breakpoint() end,                                    { noremap = true , silent = true, desc = "DAP toggle breakpoint"})
vim.keymap.set('n', '<leader>B'  , function() require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { noremap = true , silent = true, desc = "DAP set conditional breakpoint"})
vim.keymap.set('n', '<leader>lp' , function() require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,{ noremap = true , silent = true, desc = "DAP log point" })

vim.keymap.set('n', '<leader>dr' , function() require'dap'.repl.open() end,                                            { noremap = true , silent = true, desc = "DAP repl"})
vim.keymap.set('n', '<leader>dl' , function() require'dap'.run_last() end,                                             { noremap = true , silent = true, desc = "DAP run last" })
