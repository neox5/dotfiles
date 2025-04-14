local M = {}

-- Uninstall function to remove installed plugins
function M.uninstall_plugins()
  local data_path = vim.fn.stdpath("data")
  local lazy_path = data_path .. "/lazy"
  
  -- Confirmation prompt
  local confirm = vim.fn.confirm("Are you sure you want to uninstall all plugins?", "&Yes\n&No", 2)
  if confirm ~= 1 then
    print("Uninstall canceled.")
    return
  end

  -- Delete the lazy.nvim plugin directory
  vim.fn.delete(lazy_path, "rf")
  print("All plugins have been uninstalled.")

  -- Optionally, remove any compiled files or cache
  -- vim.fn.delete(data_path .. '/plugin', 'rf')
end

return M
