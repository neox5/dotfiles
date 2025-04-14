return {
  "tpope/vim-fugitive",
  config = function()
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Common git operations
    keymap("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })  -- Open Git status window
    
    -- Git add current file
    keymap("n", "<leader>ga", ":Git add %<CR>", { desc = "Git add current file", unpack(opts) })
    -- Git add all
    keymap("n", "<leader>gA", ":Git add .<CR>", { desc = "Git add all", unpack(opts) })
    
    -- Git commits
    keymap("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit", unpack(opts) })
    -- Advanced commit operations (using capital C)
    keymap("n", "<leader>gCa", ":Git commit --amend<CR>", { desc = "Git commit amend", unpack(opts) })
    keymap("n", "<leader>gCe", ":Git commit --amend --no-edit<CR>", { desc = "Git commit amend (no edit)", unpack(opts) })
    
    -- Git push
    keymap("n", "<leader>gp", ":Git push<CR>", { desc = "Git push", unpack(opts) })
    
    -- Git pull
    keymap("n", "<leader>gl", ":Git pull<CR>", { desc = "Git pull", unpack(opts) })
    
    -- Custom git log (adog)
    keymap("n", "<leader>gL", ":Git log --all --decorate --oneline --graph<CR>", 
      { desc = "Git log (adog)", unpack(opts) })

    -- Branch management
    keymap("n", "<leader>gb", ":Git branch<CR>", { desc = "List branches", unpack(opts) })
    keymap("n", "<leader>gB", ":Git blame<CR>", { desc = "Git blame", unpack(opts) })
    keymap("n", "<leader>gd", ":Gvdiffsplit<CR>", { desc = "Git diff", unpack(opts) })
    keymap("n", "<leader>gr", ":GRename<CR>", { desc = "Git rename", unpack(opts) })
    
    -- Create a new branch
    keymap("n", "<leader>gnb", ":Git checkout -b ", { desc = "Create new branch" })
    -- Switch branch (can use tab completion)
    keymap("n", "<leader>gCo", ":Git checkout ", { desc = "Checkout branch" })
  end
}
