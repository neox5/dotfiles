return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup {
      options = {
        theme = "rose-pine",
        component_separators = { left = "·", right = "·" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { 
          {
            "branch",
            icon = "",
          }
        },
        lualine_c = {
          {
            "filename",
            path = 1, -- Show relative path
            symbols = {
              modified = " ",
              readonly = " ",
              unnamed = "[No Name]",
            }
          }, 
          {
            "diff",
            symbols = {
              added = " ",
              modified = "󰏫 ",
              removed = " "
            },
          }
        },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌶 " },
          }
        },
        lualine_y = { "filetype" },
        lualine_z = { "location" }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
      },
    }
  end
}
