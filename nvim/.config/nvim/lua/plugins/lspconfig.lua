return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",  -- LSP completion
    "hrsh7th/nvim-cmp",      -- Completion framework
    "hrsh7th/cmp-buffer",    -- Buffer completions
    "hrsh7th/cmp-path",      -- Path completions
    "saadparwaiz1/cmp_luasnip", -- Snippet completions
    "L3MON4D3/LuaSnip",      -- Snippet engine
    "rafamadriz/friendly-snippets", -- Predefined snippets
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Reserve a space in the gutter
    vim.opt.signcolumn = "yes"

    -- Add cmp_nvim_lsp capabilities settings to lspconfig
    -- This should be executed before you configure any language server
    local lspconfig_defaults = lspconfig.util.default_config
    lspconfig_defaults.capabilities = vim.tbl_deep_extend(
      "force",
      lspconfig_defaults.capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    -- This is where you enable features that only work
    -- if there is a language server active in the file
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
        vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
        vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", opts)
        vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
      end,
    })

    -- Configure gopls for Go
    lspconfig.gopls.setup({
      cmd = { "gopls" },
      root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
      on_attach = function(client, bufnr)
        local function organize_imports()
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { "source.organizeImports" } }
          local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
          if result and result[1] then
            local actions = result[1].result
            if actions and actions[1] then
              vim.lsp.util.apply_workspace_edit(actions[1].edit, "utf-8")
            end
          end
        end

        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
            buffer = bufnr,
            callback = function()
              organize_imports()
              vim.lsp.buf.format({ async = false })
            end
          })
        end
      end,
      settings = {
        gopls = {
          gofumpt = true, -- Enforce stricter formatting standards
          usePlaceholders = true, -- Enable placeholders in completions
          analyses = {
            unusedparams = true, -- Highlight unused function parameters
          },
          staticcheck = true, -- Enable additional static analysis checks
        },
      },
    })


    -- Setup nvim-cmp
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body) -- Use LuaSnip for snippet expansion
        end,
      },
      mapping = {
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })

    -- Enable LuaSnip
    require("luasnip.loaders.from_vscode").lazy_load()
  end
}
