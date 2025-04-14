return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    require("rose-pine").setup({
      variant = "moon", -- Available variants: main, moon, dawn
      dark_variant = "moon",
    })

    -- Set colorscheme after options
    vim.cmd("colorscheme rose-pine")
  end,
}
