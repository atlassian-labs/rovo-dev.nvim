local M = {
  buf = nil, -- terminal buffer id
  win = nil, -- window id showing the terminal buffer (if visible)
  job = nil, -- job id returned by termopen
}

function M.setup()
  local augroup = vim.api.nvim_create_augroup('RovoDevState', { clear = true })

  -- Clean up state if the terminal buffer is wiped out by the user
  vim.api.nvim_create_autocmd({ 'BufWipeout' }, {
    group = augroup,
    callback = function(args)
      if M.buf == args.buf then
        M.reset_buf()
      end
    end,
  })
end

function M.has_buf()
  return M.buf ~= nil and vim.api.nvim_buf_is_valid(M.buf)
end

function M.has_win()
  return M.win ~= nil and vim.api.nvim_win_is_valid(M.win)
end

function M.job_alive()
  if not M.job then
    return false
  end
  local ok, res = pcall(vim.fn.jobwait, { M.job }, 0)
  if not ok then
    return false
  end
  return res and res[1] == -1
end

function M.reset_buf()
  M.buf = nil
  M.job = nil
end

function M.clear_win()
  M.win = nil
end

return M
