-- Minimal Neovim init for running plugin tests with plenary
-- Make sure default site packpath is included (so cloned plugins load)
vim.o.packpath = vim.fn.stdpath('data') .. '/site'
local site = vim.o.packpath
-- Ensure expected pack structure exists to satisfy runtime plugins (e.g., netrw)
if vim.fn.isdirectory(site .. '/pack') == 0 then
  vim.fn.mkdir(site .. '/pack', 'p')
end

-- Disable netrw to avoid packpath-related E919 during tests
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Add current workspace to runtimepath
local root = vim.fn.fnamemodify('.', ':p')
vim.opt.runtimepath:append(root)
vim.opt.runtimepath:append(root .. 'tests')

-- If plenary is installed in your packpath, ensure it's on runtimepath
-- Otherwise, running PlenaryBustedDirectory should inject it.

-- Keep UI simple/stable for headless
vim.o.swapfile = false
vim.o.hidden = true
vim.o.shortmess = 'filnxtToOFI'
vim.o.termguicolors = false
vim.o.more = false
vim.o.equalalways = false

-- Load plenary busted test framework
pcall(require, 'plenary.busted')
