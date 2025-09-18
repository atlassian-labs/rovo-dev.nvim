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

  -- Reset deletion notification flag when the user writes the buffer (recreates file)
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    callback = function(args)
      local buf = args.buf
      local name = vim.api.nvim_buf_get_name(buf)
      if not name or name == '' then
        return
      end
      -- If the file now exists on disk, clear any previous deletion notification flag
      if vim.fn.filereadable(name) == 1 then
        vim.b[buf].rovo_dev_deletion_notified = nil
      end
    end,
    desc = 'Rovo Dev: reset deletion notification on write',
  })

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

      -- Check if the file actually exists
      if vim.fn.filereadable(name) == 1 then
        -- Reset deletion notification flag since file exists again
        vim.b[buf].rovo_dev_deletion_notified = nil
        name = vim.fn.fnamemodify(name, ':~:.')
        vim.notify(
          ('Reloaded from disk: %s'):format(name),
          vim.log.levels.INFO,
          { title = 'Rovo Dev' }
        )
      else
        -- File was deleted - show a different notification only once
        -- We use a buffer variable to track if we've already notified about deletion
        local already_notified = vim.b[buf].rovo_dev_deletion_notified
        if not already_notified then
          vim.b[buf].rovo_dev_deletion_notified = true
          name = vim.fn.fnamemodify(name, ':~:.')
          vim.notify(('File deleted: %s'):format(name), vim.log.levels.WARN, { title = 'Rovo Dev' })
        end
      end
    end,
    desc = 'Notify when a buffer is updated externally',
  })
end

return M
