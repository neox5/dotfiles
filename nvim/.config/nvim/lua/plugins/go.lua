return {
  "ray-x/go.nvim",
  dependencies = {
    "ray-x/guihua.lua",                 -- Floating window UI library
    "neovim/nvim-lspconfig",           -- LSP support
    "nvim-treesitter/nvim-treesitter", -- Syntax highlighting
  },
  config = function()
    require("go").setup({
      -- Disable LSP integration in go.nvim
      lsp_cfg = false,      -- Use lsp.lua for LSP setup
      lsp_diag_hdlr = false, -- Disable diagnostic handlers in go.nvim

      -- Debugging and Testing Features
      test_runner = "go",   -- Use the standard `go test` for testing
      dap_debug = true,     -- Enable nvim-dap integration for debugging
      luasnip = true,       -- Use luasnip for snippet support

      -- Formatter and Imports (delegated to lsp.lua)
      fmt = false,          -- Disable formatting in go.nvim
      import_on_save = false, -- Disable imports in go.nvim

      -- Build tags (optional for debugging/testing)
      build_tags = "",      -- Specify build tags if necessary
    })

    -- Key mappings for Go-specific functionality
    local go_group = vim.api.nvim_create_augroup("GoMappings", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "go",
      group = go_group,
      callback = function(event)
        -- Test mappings
        vim.keymap.set("n", "<leader>tt", "<cmd>GoTest<CR>", { buffer = event.buf, desc = "Run Go test package" })
        vim.keymap.set("n", "<leader>tf", "<cmd>GoTestFunc<CR>", { buffer = event.buf, desc = "Run Go test function" })
        vim.keymap.set("n", "<leader>tl", "<cmd>GoTestFile<CR>", { buffer = event.buf, desc = "Run Go test file" })
        vim.keymap.set("n", "<leader>tv", "<cmd>GoTestVerbose<CR>", { buffer = event.buf, desc = "Run Go tests verbose" })
        vim.keymap.set("n", "<leader>tc", "<cmd>GoCoverage<CR>", { buffer = event.buf, desc = "Show Go test coverage" })
        vim.keymap.set("n", "<leader>tC", "<cmd>GoCoverageClear<CR>", { buffer = event.buf, desc = "Clear Go test coverage" })

        -- Debugging mappings
        vim.keymap.set("n", "<leader>dd", ":GoDebug<CR>", { buffer = event.buf, desc = "Start debugging" })
        vim.keymap.set("n", "<leader>db", ":GoBreakToggle<CR>", { buffer = event.buf, desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dr", ":GoDebugRestart<CR>", { buffer = event.buf, desc = "Restart debugging" })
        vim.keymap.set("n", "<leader>dc", ":lua require('dap').continue()<CR>", { buffer = event.buf, desc = "Continue debugging" })
        vim.keymap.set("n", "<leader>ds", ":lua require('dap').step_over()<CR>", { buffer = event.buf, desc = "Step over" })
        vim.keymap.set("n", "<leader>di", ":lua require('dap').step_into()<CR>", { buffer = event.buf, desc = "Step into" })
        vim.keymap.set("n", "<leader>do", ":lua require('dap').step_out()<CR>", { buffer = event.buf, desc = "Step out" })
      end,
    })
  end,
  event = { "CmdlineEnter" },
  ft = { "go", "gomod" },
  build = ':lua require("go.install").update_all_sync()',
}
