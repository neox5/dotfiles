return {
  "pearofducks/ansible-vim",
  ft = { "yaml.ansible" },
  config = function()
    -- Optional: Configure ansible-vim settings here
    vim.g.ansible_unindent_after_newline = 1
    vim.g.ansible_extra_keywords_highlight = 1
  end
}
