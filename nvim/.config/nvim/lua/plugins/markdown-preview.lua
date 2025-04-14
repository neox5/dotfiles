return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    -- Key mappings
    vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>mt", ":MarkdownPreviewToggle<CR>", { noremap = true, silent = true })
  end,
  ft = { "markdown" },
}
