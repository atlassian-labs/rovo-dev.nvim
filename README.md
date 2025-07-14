# Rovo Dev Neovim Plugin

[![Atlassian license](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)
[![GitHub Stars](https://img.shields.io/github/stars/atlassian-labs/rovo-dev.nvim?style=flat-square)](https://github.com/atlassian-labs/rovo-dev.nvim/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/atlassian-labs/rovo-dev.nvim?style=flat-square)](https://github.com/atlassian-labs/rovo-dev.nvim/issues)
[![CI](https://img.shields.io/github/actions/workflow/status/atlassian-labs/rovo-dev.nvim/ci.yml?branch=main&style=flat-square&logo=github)](https://github.com/atlassian-labs/rovo-dev.nvim/.github/workflows/ci.yml)
[![Neovim Version](https://img.shields.io/badge/Neovim-0.7%2B-blueviolet?style=flat-square&logo=neovim)](https://github.com/neovim/neovim)
[![Tests](https://img.shields.io/badge/Tests-44%20passing-success?style=flat-square&logo=github-actions)](https://github.com/atlassian-labs/rovo-dev.nvim/actions/workflows/ci.yml)
<!-- [![Version](https://img.shields.io/badge/Version-0.4.2-blue?style=flat-square)](https://github.com/atlassian-labs/rovo-dev.nvim/releases/tag/v0.4.2) -->
[![Discussions](https://img.shields.io/github/discussions/atlassian-labs/rovo-dev.nvim?style=flat-square&logo=github)](https://github.com/atlassian-labs/rovo-dev.nvim/discussions)

*A seamless integration between [Rovo Dev](https://community.atlassian.com/forums/Rovo-for-Software-Teams-Beta/Introducing-Rovo-Dev-CLI-AI-Powered-Development-in-your-terminal/ba-p/3043623) AI assistant and Neovim*

## Usage

- 🚀 Toggle Rovo Dev in a terminal window with a single key press
- 🧠 Support for command-line arguments like `--restore` and custom variants
- 🔄 Automatically detect and reload files modified by Rovo Dev
- ⚡ Real-time buffer updates when files are changed externally
- 📱 Customizable window position and size (including floating windows)
- 🤖 Integration with which-key (if available)
- 📂 Automatically uses git project root as working directory (when available)
- 🧩 Modular and maintainable code structure
- 📋 Type annotations with LuaCATS for better IDE support
- ✅ Configuration validation to prevent errors
- 🧪 Testing framework for reliability (44 comprehensive tests)

## Installation

### Requirements

- Neovim 0.7.0 or later
- Rovo Dev CLI tool installed and available in your PATH
- plenary.nvim (dependency for git operations)

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  "atlassian-labs/rovo-dev.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    require("rovo-dev").setup()
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'atlassian-labs/rovo-dev.nvim',
  requires = {
    'nvim-lua/plenary.nvim', -- Required for git operations
  },
  config = function()
    require('rovo-dev').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'atlassian-labs/rovo-dev.nvim'
" After installing, add this to your init.vim:
" lua require('rovo-dev').setup()
```

## Documentation

### Configuration

The plugin can be configured by passing a table to the `setup` function. Here's the default configuration:

```lua
require("rovo-dev").setup({
  -- Terminal window settings
  window = {
    split_ratio = 0.3,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
    position = "botright",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
    enter_insert = true,    -- Whether to enter insert mode when opening Rovo Dev
    hide_numbers = true,    -- Hide line numbers in the terminal window
    hide_signcolumn = true, -- Hide the sign column in the terminal window

    -- Floating window configuration (only applies when position = "float")
    float = {
      width = "80%",        -- Width: number of columns or percentage string
      height = "80%",       -- Height: number of rows or percentage string
      row = "center",       -- Row position: number, "center", or percentage string
      col = "center",       -- Column position: number, "center", or percentage string
      relative = "editor",  -- Relative to: "editor" or "cursor"
      border = "rounded",   -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    },
  },
  -- File refresh settings
  refresh = {
    enable = true,           -- Enable file change detection
    updatetime = 100,        -- updatetime when Rovo Dev is active (milliseconds)
    timer_interval = 1000,   -- How often to check for file changes (milliseconds)
    show_notifications = true, -- Show notification when files are reloaded
  },
  -- Git project settings
  git = {
    use_git_root = true,     -- Set CWD to git root when opening Rovo Dev (if in git project)
  },
  -- Shell-specific settings
  shell = {
    separator = '&&',        -- Command separator used in shell commands
    pushd_cmd = 'pushd',     -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
    popd_cmd = 'popd',       -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushell)
  },
  -- Command settings
  command = "acli rovodev run",        -- Command used to launch Rovo Dev
  -- Command variants
  command_variants = {
    -- Conversation management
    restore = "--restore", -- Resume the most recent conversation
    -- Output options
    verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
  },
  -- Keymaps
  keymaps = {
    toggle = {
      normal = "<C-,>",       -- Normal mode keymap for toggling Rovo Dev, false to disable
      terminal = "<C-,>",     -- Terminal mode keymap for toggling Rovo Dev, false to disable
      variants = {
        restore = "<leader>cR", -- Normal mode keymap for Rovo Dev with restore flag
        verbose = "<leader>cV",  -- Normal mode keymap for Rovo Dev with verbose flag
      },
    },
    window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
    scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
  }
})
```

### Usage

#### Quick Start

```vim
" In your Vim/Neovim commands or init file:
:RovoDev
```

```lua
-- Or from Lua:
vim.cmd[[RovoDev]]

-- Or map to a key:
vim.keymap.set('n', '<leader>cc', '<cmd>RovoDev<CR>', { desc = 'Toggle Rovo Dev' })
```

#### Commands

Basic command:

- `:RovoDev` - Toggle the Rovo Dev terminal window

Conversation management commands:

- `:RovoDevRestore` - Resume the most recent conversation

Output options command:

- `:RovoDevVerbose` - Enable verbose logging with full turn-by-turn output

Note: Commands are automatically generated for each entry in your `command_variants` configuration.

#### Key Mappings

Default key mappings:

- `<leader>ac` - Toggle Rovo Dev terminal window (normal mode)
- `<C-,>` - Toggle Rovo Dev terminal window (both normal and terminal modes)

Variant mode mappings (if configured):

- `<leader>cR` - Toggle Rovo Dev with --restore flag
- `<leader>cV` - Toggle Rovo Dev with --verbose flag

Additionally, when in the Rovo Dev terminal:

- `<C-h>` - Move to the window on the left
- `<C-j>` - Move to the window below
- `<C-k>` - Move to the window above
- `<C-l>` - Move to the window on the right
- `<C-f>` - Scroll full-page down
- `<C-b>` - Scroll full-page up

Note: After scrolling with `<C-f>` or `<C-b>`, you'll need to press the `i` key to re-enter insert mode so you can continue typing to Rovo Dev.

When Rovo Dev modifies files that are open in Neovim, they'll be automatically reloaded.

#### Floating Window Example

To use Rovo Dev in a floating window:

```lua
require("rovo-dev").setup({
  window = {
    position = "float",
    float = {
      width = "90%",      -- Take up 90% of the editor width
      height = "90%",     -- Take up 90% of the editor height
      row = "center",     -- Center vertically
      col = "center",     -- Center horizontally
      relative = "editor",
      border = "double",  -- Use double border style
    },
  },
})
```

## Tests

The project includes comprehensive setup for development:

- Complete installation instructions for all platforms in [DEVELOPMENT.md](DEVELOPMENT.md)
- Pre-commit hooks for code quality
- Testing framework with 44 comprehensive tests
- Linting and formatting tools
- Weekly dependency updates workflow for Rovo CLI and actions

```bash
# Run tests
make test

# Check code quality
make lint

# Set up pre-commit hooks
scripts/setup-hooks.sh

# Format code
make format
```

## Contributions

Contributions to rovo-dev.nvim are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Copyright (c) [2025] Atlassian US., Inc.
Apache 2.0 licensed, see [LICENSE](LICENSE) file.

<br/>

[![With â¤ï¸ from Atlassian](https://raw.githubusercontent.com/atlassian-internal/oss-assets/master/banner-cheers-light.png)](https://www.atlassian.com)
