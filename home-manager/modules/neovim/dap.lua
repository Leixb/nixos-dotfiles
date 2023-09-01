local dap = require("dap")

vim.keymap.set("n", "<F6>", function()
    dap.continue()
end, { noremap = true, silent = true, desc = "DAP continue" })
vim.keymap.set("n", "<F7>", function()
    dap.step_over()
end, { noremap = true, silent = true, desc = "DAP step over" })
vim.keymap.set("n", "<F8>", function()
    dap.step_into()
end, { noremap = true, silent = true, desc = "DAP step into" })
vim.keymap.set("n", "<F9>", function()
    dap.step_out()
end, { noremap = true, silent = true, desc = "DAP setp out" })

vim.keymap.set("n", "<leader>b", function()
    dap.toggle_breakpoint()
end, { noremap = true, silent = true, desc = "DAP toggle breakpoint" })
vim.keymap.set("n", "<leader>B", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { noremap = true, silent = true, desc = "DAP set conditional breakpoint" })
vim.keymap.set("n", "<leader>lp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { noremap = true, silent = true, desc = "DAP log point" })

vim.keymap.set("n", "<leader>dr", function()
    dap.repl.open()
end, { noremap = true, silent = true, desc = "DAP repl" })
vim.keymap.set("n", "<leader>dl", function()
    dap.run_last()
end, { noremap = true, silent = true, desc = "DAP run last" })

dap.adapters.lldb = {
    type = "executable",
    command = "lldb-vscode",
    name = "lldb",
}

dap.configurations.cpp = {
    {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},

        -- 💀
        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        -- runInTerminal = false,
    },
}

-- If you want to use this for Rust and C, add something like this:

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
