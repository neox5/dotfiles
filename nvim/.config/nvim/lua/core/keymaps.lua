local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- netrw
keymap("n", "<leader>pe", vim.cmd.Ex, opts) -- po..."project open"

