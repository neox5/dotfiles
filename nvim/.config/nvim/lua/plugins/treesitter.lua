return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- filetype detection for Ansible files
    vim.filetype.add({
      pattern = {
        ['.*/playbooks/.*%.yml'] = 'yaml.ansible',
        ['.*/roles/.*/tasks/.*%.yml'] = 'yaml.ansible',
        ['.*/group_vars/.*'] = 'yaml.ansible',
        ['.*/host_vars/.*'] = 'yaml.ansible',
      },
    })

    require("nvim-treesitter.configs").setup {
      ensure_installed = { "go", "gomod", "gowork", "gosum", "proto", "lua", "vim", "bash", "yaml", "json"},
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    }
  end,
}
