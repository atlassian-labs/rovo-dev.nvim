local M = {}

function M.register_keymaps(config)
  local map_opts = { noremap = true, silent = true }
  local defaults = require('rovo-dev.config').defaults
  local keymaps = (config and config.keymaps) or defaults.keymaps or {}

  if keymaps.toggle and keymaps.toggle.normal then
    vim.api.nvim_set_keymap(
      'n',
      keymaps.toggle.normal,
      [[<C-\><C-n>:RovoDevToggle<CR>]],
      vim.tbl_extend('force', map_opts, { desc = 'Rovo Dev: Toggle' })
    )
  end

  if keymaps.toggle and keymaps.toggle.terminal then
    vim.api.nvim_set_keymap(
      't',
      keymaps.toggle.terminal,
      [[<C-\><C-n>:RovoDevToggle<CR>]],
      vim.tbl_extend('force', map_opts, { desc = 'Rovo Dev: Toggle' })
    )
  end

  if keymaps.run and keymaps.run.restore then
    vim.api.nvim_set_keymap(
      'n',
      keymaps.run.restore,
      [[<C-\><C-n>:RovoDevRestore<CR>]],
      vim.tbl_extend('force', map_opts, { desc = 'Rovo Dev: Restore' })
    )
  end

  if keymaps.run and keymaps.run.verbose then
    vim.api.nvim_set_keymap(
      'n',
      keymaps.run.verbose,
      [[<C-\><C-n>:RovoDevVerbose<CR>]],
      vim.tbl_extend('force', map_opts, { desc = 'Rovo Dev: Verbose' })
    )
  end

  if keymaps.run and keymaps.run.shadow then
    vim.api.nvim_set_keymap(
      'n',
      keymaps.run.shadow,
      [[<C-\><C-n>:RovoDevShadow<CR>]],
      vim.tbl_extend('force', map_opts, { desc = 'Rovo Dev: Shadow' })
    )
  end

  if keymaps.run and keymaps.run.yolo then
    vim.api.nvim_set_keymap(
      'n',
      keymaps.run.yolo,
      [[<C-\><C-n>:RovoDevYolo<CR>]],
      vim.tbl_extend('force', map_opts, { desc = 'Rovo Dev: Yolo' })
    )
  end
end

return M
