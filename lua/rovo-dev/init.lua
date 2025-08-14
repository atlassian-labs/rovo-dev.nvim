local config = require('rovo-dev.config')
local state = require('rovo-dev.state')
local file_refresh = require('rovo-dev.file_refresh')
local keymaps = require('rovo-dev.keymaps')
local commands = require('rovo-dev.commands')
local term = require('rovo-dev.terminal')
local version = require('rovo-dev.version')

local M = {}

-- Store the current configuration
--- @type table
M.config = {}
M.version = version.version

function M.setup(opts)
  M.config = config.setup(opts)

  -- Setup state
  state.setup()

  -- Setup file refresh
  file_refresh.setup(M.config)

  -- Register keymaps
  keymaps.register_keymaps(M)

  -- Register commands
  commands.register_commands(M.config)

  return M
end

function M.toggle(flags)
  term.toggle(M.config, flags or {})
end

return M
