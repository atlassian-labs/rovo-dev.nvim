local M = {}

function M.register_commands(rovo_dev)
  vim.api.nvim_create_user_command('RovoDevToggle', function()
    rovo_dev.toggle({})
  end, {})

  vim.api.nvim_create_user_command('RovoDevRestore', function()
    rovo_dev.toggle({ '--restore' })
  end, {})

  vim.api.nvim_create_user_command('RovoDevVerbose', function()
    rovo_dev.toggle({ '--verbose' })
  end, {})

  vim.api.nvim_create_user_command('RovoDevShadow', function()
    rovo_dev.toggle({ '--shadow' })
  end, {})

  vim.api.nvim_create_user_command('RovoDevYolo', function()
    rovo_dev.toggle({ '--yolo' })
  end, {})
end

return M
