local eq = assert.are.same
local truthy = assert.is_truthy

local function unload_rovo()
  for name, _ in pairs(package.loaded) do
    if name == 'rovo-dev' or name:match('^rovo%-dev%.') then
      package.loaded[name] = nil
    end
  end
end

local function reset_state()
  pcall(vim.cmd, 'silent! only')
  local ok, state = pcall(require, 'rovo-dev.state')
  if ok then
    if state.has_win() then
      pcall(vim.api.nvim_win_close, state.win, true)
    end
    pcall(state.reset_buf)
    pcall(state.clear_win)
  end
end

local original_termopen

local function stub_termopen(capture)
  original_termopen = original_termopen or vim.fn.termopen
  vim.fn.termopen = function(cmd, opts)
    if capture then
      capture(cmd, opts)
    end
    return 4242 -- fake job id
  end
end

local function restore_termopen()
  if original_termopen then
    vim.fn.termopen = original_termopen
  end
end

local function visible_windows_for_buf(buf)
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      local cfg = vim.api.nvim_win_get_config(win)
      if not cfg or cfg.relative == '' then
        table.insert(wins, win)
      end
    end
  end
  return wins
end

describe('rovo-dev.nvim', function()
  before_each(function()
    restore_termopen()
    unload_rovo()
    reset_state()
  end)

  after_each(function()
    restore_termopen()
    reset_state()
  end)

  it('creates a split with a terminal buffer and fixed width', function()
    stub_termopen()
    local rovo = require('rovo-dev')
    rovo.setup({ terminal = { cmd = { 'echo', 'rovodev' }, side = 'right', width = 0.3 } })

    rovo.toggle()

    local state = require('rovo-dev.state')
    truthy(state.has_win())
    truthy(state.has_buf())

    local win = state.win
    eq(true, vim.wo[win].winfixwidth)

    local buf = state.buf
    eq('rovo-dev', vim.bo[buf].filetype)
    eq('hide', vim.bo[buf].bufhidden)

    local wins = visible_windows_for_buf(buf)
    truthy(#wins >= 1)
  end)

  it('appends flags to cmd for list and string forms', function()
    local captured
    stub_termopen(function(cmd)
      captured = cmd
    end)

    local rovo = require('rovo-dev')
    rovo.setup({ terminal = { cmd = { 'acli', 'rovodev', 'run' } } })

    rovo.toggle({ '--verbose', '--restore' })

    assert.is_true(type(captured) == 'table')
    eq('--verbose', captured[#captured - 1])
    eq('--restore', captured[#captured])

    -- string form
    unload_rovo()
    reset_state()
    captured = nil
    stub_termopen(function(cmd)
      captured = cmd
    end)
    rovo = require('rovo-dev')
    rovo.setup({ terminal = { cmd = 'acli rovodev run' } })
    rovo.toggle({ '--shadow' })
    assert.is_true(type(captured) == 'string')
    assert.is_truthy(captured:match('%-%-shadow'))
  end)

  it('notifies only for visible buffers on FileChangedShellPost', function()
    stub_termopen()
    local rovo = require('rovo-dev')
    rovo.setup({})
    rovo.toggle()

    -- Open a named file buffer to simulate a real file being updated
    vim.cmd('edit tmp_rovodev_visible.txt')
    local file_buf = vim.api.nvim_get_current_buf()

    local notifications = {}
    local old_notify = vim.notify
    vim.notify = function(msg, level, opts)
      table.insert(notifications, { msg = msg, level = level, opts = opts })
    end

    -- Fire for visible buffer
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })
    assert.is_true(#notifications >= 1)

    -- Hidden buffer case
    notifications = {}
    local hidden = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(hidden, 'tmp_rovodev_hidden.txt')
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = hidden })
    eq(0, #notifications)

    vim.notify = old_notify
  end)

  it('handles deleted files correctly without repeated notifications', function()
    stub_termopen()
    local rovo = require('rovo-dev')
    rovo.setup({})
    rovo.toggle()

    -- Create a temporary file
    local test_file = 'tmp_rovodev_deleted_test.txt'
    vim.fn.writefile({ 'test content' }, test_file)

    -- Open the file in a buffer
    vim.cmd('edit ' .. test_file)
    local file_buf = vim.api.nvim_get_current_buf()

    local notifications = {}
    local old_notify = vim.notify
    vim.notify = function(msg, level, opts)
      table.insert(notifications, { msg = msg, level = level, opts = opts })
    end

    -- Delete the file externally
    vim.fn.delete(test_file)

    -- Trigger FileChangedShellPost multiple times
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })

    -- Should only get one notification about deletion
    eq(1, #notifications)
    assert.is_truthy(notifications[1].msg:match('File deleted:'))
    eq(vim.log.levels.WARN, notifications[1].level)

    -- Test recreation resets the flag via external write
    notifications = {}
    vim.fn.writefile({ 'recreated' }, test_file)
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })

    eq(1, #notifications)
    assert.is_truthy(notifications[1].msg:match('Reloaded from disk:'))
    eq(vim.log.levels.INFO, notifications[1].level)

    -- Delete again - should notify again
    notifications = {}
    vim.fn.delete(test_file)
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })

    eq(1, #notifications)
    assert.is_truthy(notifications[1].msg:match('File deleted:'))

    -- Now recreate by writing the buffer (simulates user :write)
    notifications = {}
    vim.api.nvim_buf_set_lines(file_buf, 0, -1, false, { 'recreated by buffer write' })
    vim.cmd('write')
    -- Writing should clear the deletion flag via BufWritePost; no notification expected here
    eq(0, #notifications)

    -- Delete again - should notify again after buffer write recreation
    vim.fn.delete(test_file)
    vim.api.nvim_exec_autocmds('FileChangedShellPost', { buffer = file_buf })

    eq(1, #notifications)
    assert.is_truthy(notifications[1].msg:match('File deleted:'))

    vim.notify = old_notify
    vim.cmd('bdelete! ' .. file_buf)
  end)

  it('creates a centered floating terminal window when enabled', function()
    stub_termopen()
    local rovo = require('rovo-dev')
    -- Use fixed dimensions for deterministic center calculation
    rovo.setup({
      terminal = {
        cmd = { 'echo', 'rovodev' },
        float = { enabled = true, width = 80, height = 20, border = 'single' },
      },
    })

    rovo.toggle()

    local state = require('rovo-dev.state')
    truthy(state.has_win())
    truthy(state.has_buf())

    local win = state.win
    local cfg = vim.api.nvim_win_get_config(win)
    -- It should be a floating window
    assert.is_truthy(cfg and cfg.relative and cfg.relative ~= '')
    eq('editor', cfg.relative)
    -- Account for border taking 2 cells in each dimension
    local border_extra = 2
    local expected_width = math.min(80, vim.o.columns - border_extra)
    local expected_height = math.min(20, (vim.o.lines - vim.o.cmdheight) - border_extra)
    eq(expected_width, cfg.width)
    eq(expected_height, cfg.height)
    -- Centering check
    local expected_col = math.floor((vim.o.columns - expected_width) / 2)
    local expected_row = math.floor(((vim.o.lines - vim.o.cmdheight) - expected_height) / 2)
    -- cfg.col/row can be numbers or tables depending on Neovim version; accept number
    local col = type(cfg.col) == 'table' and cfg.col[1] or cfg.col
    local row = type(cfg.row) == 'table' and cfg.row[1] or cfg.row
    eq(expected_col, math.floor(col))
    eq(expected_row, math.floor(row))
  end)
end)
