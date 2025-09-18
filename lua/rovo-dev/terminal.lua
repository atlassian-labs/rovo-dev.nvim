local state = require('rovo-dev.state')

local M = {}

local function calc_width(config)
  local w = config.terminal.width
  if type(w) == 'number' and w > 0 and w < 1 then
    return math.min(120, math.floor(vim.o.columns * w))
  end
  return math.min(120, w or 40)
end

local function place_split(side)
  if side == 'left' then
    vim.cmd('topleft vsplit')
  else
    vim.cmd('botright vsplit')
  end
end

local function apply_window(win, config)
  local opts = config.window or {}
  for k, v in pairs(opts) do
    pcall(function()
      vim.wo[win][k] = v
    end)
  end
end

local function reset_view(win)
  -- winrestview applies to the current window, so temporarily switch
  local cur_win = vim.api.nvim_get_current_win()
  local switched = false
  if cur_win ~= win and vim.api.nvim_win_is_valid(win) then
    local ok = pcall(vim.api.nvim_set_current_win, win)
    switched = ok
  end

  -- Reset any horizontal scroll/viewport so TUI content isn't shifted
  pcall(vim.fn.winrestview, { leftcol = 0 })
  -- Ensure the cursor is at column 0 (helps leftcol reset stick)
  local okc, rowcol = pcall(vim.api.nvim_win_get_cursor, win)
  if okc then
    pcall(vim.api.nvim_win_set_cursor, win, { rowcol[1], 0 })
  end

  -- Restore previous window if we switched
  if switched and vim.api.nvim_win_is_valid(cur_win) then
    pcall(vim.api.nvim_set_current_win, cur_win)
  end
end

-- Simple debounce using a sequence counter (no need to manage libuv timers)
local _refresh_seq = 0
local function trigger_checktime_debounced(config)
  if config.file_refresh.refresh_on_terminal_output == false then
    return
  end
  local wait = tonumber(config.file_refresh.refresh_debounce_ms) or 200
  _refresh_seq = _refresh_seq + 1
  local this = _refresh_seq
  vim.defer_fn(function()
    if this ~= _refresh_seq then
      return
    end
    pcall(vim.cmd, 'silent! checktime')
  end, wait)
end

local function create_new_term_in_current_win(config, flags)
  -- Create a scratch buffer which becomes a terminal when termopen runs.
  local buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch
  vim.bo[buf].bufhidden = 'hide' -- keep buffer (and job) on window close
  vim.bo[buf].filetype = 'rovo-dev'

  vim.api.nvim_win_set_buf(0, buf)

  local base_cmd = config.terminal.cmd
  local cmd = base_cmd
  if type(flags) == 'table' and #flags > 0 then
    if type(base_cmd) == 'table' then
      cmd = {}
      for i, v in ipairs(base_cmd) do
        cmd[i] = v
      end
      for _, f in ipairs(flags) do
        table.insert(cmd, f)
      end
    elseif type(base_cmd) == 'string' then
      cmd = base_cmd .. ' ' .. table.concat(flags, ' ')
    end
  end

  local job = vim.fn.termopen(cmd, {
    on_exit = function(_, _code, _event)
      -- Mark job as gone; keep buffer contents for logs if desired
      if state.buf == buf then
        state.job = nil
      end
    end,
    on_stdout = function(_, _data, _name)
      -- Any terminal output could indicate file changes; debounce a check
      trigger_checktime_debounced(config)
    end,
    on_stderr = function(_, _data, _name)
      trigger_checktime_debounced(config)
    end,
  })

  state.buf = buf
  state.job = job
  return buf, job
end

function M.open_win(config, flags)
  -- If it's already visible, focus it and ensure correct buffer is shown
  if state.has_win() then
    if state.has_buf() and vim.api.nvim_win_get_buf(state.win) ~= state.buf then
      pcall(vim.api.nvim_win_set_buf, state.win, state.buf)
    end
    pcall(vim.api.nvim_set_current_win, state.win)
    -- Reset view to ensure no horizontal offset remains from previous session
    pcall(reset_view, state.win)
    vim.cmd('startinsert')
    return
  end

  -- Open a vsplit on the configured side
  place_split(config.terminal.side)
  local win = vim.api.nvim_get_current_win()
  state.win = win
  apply_window(win, config)
  vim.cmd('vertical resize ' .. calc_width(config))
  -- Reset view on fresh window to avoid any shifted viewport
  pcall(reset_view, win)

  -- Determine whether to reuse an existing alive terminal, or create new
  if state.has_buf() and state.job_alive() then
    vim.api.nvim_win_set_buf(win, state.buf)
    -- After attaching the terminal buffer, reset view again to ensure leftcol=0
    pcall(reset_view, win)
  else
    -- If we had a dead job/buffer, reset and create a fresh one
    if state.has_buf() and not state.job_alive() then
      state.reset_buf()
    end
    create_new_term_in_current_win(config, flags)
    -- Reset view for the newly created terminal buffer
    pcall(reset_view, win)
  end

  vim.cmd('startinsert')
end

function M.close_win()
  if state.has_win() then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.clear_win()
end

function M.toggle(config, flags)
  if state.has_win() then
    M.close_win()
  else
    M.open_win(config, flags)
  end
end

return M
