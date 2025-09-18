local M = {}

M.defaults = {
  -- Terminal
  terminal = {
    cmd = { 'acli', 'rovodev', 'run' }, -- Command to start rovodev
    side = 'right', -- Which side to open the terminal split
    -- Width of the split. If 0 < width < 1, it's treated as a ratio of total columns.
    -- Otherwise, it's treated as fixed number of columns.
    width = 0.33,
    -- Floating window configuration
    float = {
      enabled = false, -- When true, open terminal in a centered floating window
      -- If 0 < width < 1, treated as a ratio of total columns. Otherwise fixed columns.
      width = 0.9,
      -- If 0 < height < 1, treated as a ratio of total lines. Otherwise fixed lines.
      height = 0.8,
      -- Floating window border style (rounded, single, double, none, etc.)
      border = 'rounded',
      -- If row/col are nil, window is centered. Provide numbers to override placement.
      row = nil,
      col = nil,
      style = 'minimal',
    },
  },

  -- File refresh
  file_refresh = {
    -- Automatically refresh buffers that changed on disk
    enable = true,
    -- Also trigger :checktime when the Rovo Dev terminal produces output
    refresh_on_terminal_output = true,
    -- Debounce for terminal-output-triggered checktime (ms)
    refresh_debounce_ms = 200,
  },

  -- Keymaps
  keymaps = {
    toggle = {
      normal = '<C-,>',
      terminal = '<C-,>',
    },
    run = {
      restore = '<leader>rR', -- Normal mode keymap for Rovo Dev with restore flag
      verbose = '<leader>rV', -- Normal mode keymap for Rovo Dev with verbose flag
      shadow = '<leader>rS', -- Normal mode keymap for Rovo Dev with shadow flag
      yolo = '<leader>rY', -- Normal mode keymap for Rovo Dev with yolo flag
    },
  },

  -- Terminal window options
  window = {
    number = false,
    relativenumber = false,
    signcolumn = 'no',
    cursorline = false,
    wrap = false,
    -- Keep a fixed width so this panel doesn't auto-resize when other windows open/close
    winfixwidth = true,
    -- Avoid horizontal scroll margins that can push TUI content out of view
    sidescrolloff = 0,
    sidescroll = 1,
    -- Avoid extra columns that can reduce usable width
    foldcolumn = '0',
    colorcolumn = '',
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
  return M.options
end

return M
