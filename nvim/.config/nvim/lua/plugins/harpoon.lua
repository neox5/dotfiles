return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local function harpoon_file()
      harpoon:list():add()
      vim.api.nvim_echo({{"harpooned...", "None"}}, false, {})
      vim.defer_fn(function() vim.cmd("echo ''") end, 1500)
    end

    vim.keymap.set("n", "<leader>a", harpoon_file, { desc = "harpoon - add" })
    vim.keymap.set("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "harpoon - menu" })

    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "harpoon - file 1" })
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "harpoon - file 2" })
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "harpoon - file 3" })
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "harpoon - file 4" })

    vim.keymap.set("n", "<C-S-H>", function() harpoon:list():next() end, { desc = "harpoon - next" })
  end
}

