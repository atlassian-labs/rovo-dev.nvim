local M = {}

--- Setup autocommands for file change detection
--- @param config table The plugin configuration
function M.setup(config)
  if not config.file_refresh.enable then
    return
  end

  local augroup = vim.api.nvim_create_augroup('RovoDevFileRefresh', { clear = true })

  -- Periodically/when appropriate, ask Neovim to re-check file mtimes
  vim.api.nvim_create_autocmd({
    'CursorHold',
    'CursorHoldI',
    'FocusGained',
    'BufEnter',
    'InsertLeave',
    'TextChanged',
    'TermLeave',
    'TermEnter',
    'BufWinEnter',
  }, {
    group = augroup,
    callback = function()
      vim.cmd('silent! checktime')
    end,
  })

  -- Helper: check if a buffer is visible in any non-floating window
  local function buf_visible(buf)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local ok, b = pcall(vim.api.nvim_win_get_buf, win)
      if ok and b == buf then
        local cfg = vim.api.nvim_win_get_config(win)
        if not cfg or cfg.relative == '' then
          return true
        end
      end
    end
    return false
  end

  -- Notify when buffers were reloaded from disk
  vim.api.nvim_create_autocmd('FileChangedShellPost', {
    group = augroup,
    callback = function(args)
      local buf = args.buf
      if not buf_visible(buf) then
        return
      end
      local name = vim.api.nvim_buf_get_name(buf)
      if not name or name == '' then
        return
      end
      name = vim.fn.fnamemodify(name, ':~:.')
      vim.notify(
        ('Reloaded from disk: %s'):format(name),
        vim.log.levels.INFO,
        { title = 'Rovo Dev' }
      )
    end,
    desc = 'Notify when a buffer is updated externally',
  })
end

return M
