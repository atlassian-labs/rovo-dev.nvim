# rovo-dev.nvim

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

A Neovim plugin that integrates Atlassian's Rovo Dev CLI into a toggleable, fixed-width terminal split. The plugin provides seamless access to AI-powered development assistance while maintaining your workflow and keeping your buffers synchronized when Rovo Dev makes file changes.

**What it is:** A lightweight Neovim integration for the Rovo Dev CLI that provides a persistent terminal interface with intelligent buffer management.

**Why it exists:** Developers using Rovo Dev need quick access to the CLI without disrupting their editor workflow. This plugin solves the context-switching problem by embedding the CLI directly in Neovim with smart file synchronization.

## Usage

Toggle the Rovo Dev terminal with a simple command or keymap:

```vim
:RovoDevToggle
```

Or use the default keymap `<C-,>` in normal or terminal mode.

The plugin also supports Rovo Dev CLI flags:

```vim
:RovoDevRestore  " Start with --restore flag
:RovoDevVerbose  " Start with --verbose flag
:RovoDevShadow   " Start with --shadow flag
:RovoDevYolo     " Start with --yolo flag
```

## Installation

### Using lazy.nvim (recommended)

```lua
{
  "atlassian-labs/rovo-dev.nvim",
  opts = {
    terminal = {
      cmd = { "acli", "rovodev", "run" },
      side = "right",
      width = 0.33, -- ratio of total columns when 0<width<1, else fixed cols
    },
    file_refresh = {
      enable = true,
      refresh_on_terminal_output = true,
      refresh_debounce_ms = 200,
    },
    keymaps = {
      toggle = {
        normal = "<C-,>",
        terminal = "<C-,>",
      },
      run = {
        restore = '<leader>rR',
        verbose = '<leader>rV',
        shadow = '<leader>rS',
        yolo = '<leader>rY',
      }
    },
    window = { number = false, signcolumn = "no", winfixwidth = true },
  },
}
```

### Using packer.nvim

```lua
use {
  "atlassian-labs/rovo-dev.nvim",
  config = function()
    require("rovo-dev").setup()
  end
}
```

## Documentation

### Features

- **Fixed-width terminal split** that doesn't auto-expand when other windows are closed
- **Persistent sessions** - the terminal buffer and job survive window closes
- **Automatic buffer refresh** when Rovo Dev modifies files on disk
- **Smart notifications** via vim.notify for file changes (only for visible buffers)
- **Multiple CLI flag support** with dedicated commands and keymaps
- **Configurable positioning** (left or right split)

### Configuration

Complete configuration options:

```lua
{
  terminal = {
    cmd = { "acli", "rovodev", "run" },
    side = "right",          -- "right" | "left"
    width = 0.33,            -- 0<width<1 as ratio, else fixed columns
  },
  file_refresh = {
    enable = true,
    refresh_on_terminal_output = true,
    refresh_debounce_ms = 200,
  },
  keymaps = {
    toggle = {
      normal = "<C-,>",
      terminal = "<C-,>",
    },
    run = {
      restore = '<leader>rR',
      verbose = '<leader>rV',
      shadow = '<leader>rS',
      yolo = '<leader>rY',
    }
  },
  window = {
    number = false,
    relativenumber = false,
    signcolumn = "no",
    cursorline = false,
    wrap = false,
    winfixwidth = true,
    sidescrolloff = 0,
    sidescroll = 1,
    foldcolumn = "0",
    colorcolumn = "",
  },
}
```

### API

- `require("rovo-dev").setup(opts)` - Initialize the plugin
- `require("rovo-dev").toggle()` - Toggle the terminal split
- `require("rovo-dev").version` - Current plugin version (SemVer string)

### Behavior

- Split vs Floating window:
  - By default, the Rovo Dev terminal opens as a vertical split on the configured side.
  - You can also open it in a centered floating window by enabling `terminal.float.enabled` in your setup.

Example:

```lua
require('rovo-dev').setup({
  terminal = {
    -- existing split options
    side = 'right',
    width = 0.33,

    -- floating window options
    float = {
      enabled = true,      -- open as a float instead of a split
      width = 0.8,         -- 80% of columns (or a fixed integer like 100)
      height = 0.7,        -- 70% of total lines (excluding cmdheight)
      border = 'rounded',  -- 'single', 'double', 'none', etc.
      -- row/col can be set to numbers to override centering (defaults to centered)
      -- row = 5,
      -- col = 10,
    },
  },
})
```

- **Session persistence**: The terminal buffer and job persist when the window is closed (`bufhidden=hide`)
- **Fixed width**: Uses `winfixwidth = true` to prevent auto-resizing when other windows change
- **File synchronization**: Automatically runs `:checktime` on focus/idle events and terminal output
- **Smart notifications**: Only notifies about file changes for buffers visible in non-floating windows

## Tests

## Contributions

Contributions to rovo-dev.nvim are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Versioning policy

We follow Semantic Versioning (SemVer) using Git tags of the form `vX.Y.Z`.

- MAJOR: Breaking changes to the user-facing API (Lua API, commands, config schema, or documented behavior)
- MINOR: Backward-compatible features
- PATCH: Backward-compatible bug fixes

The current version is available at runtime via:

```lua
print(require('rovo-dev').version)
```

We maintain a human-readable changelog in `CHANGELOG.md` (Keep a Changelog style).

## How to release

Two supported paths:

1. Tag-driven release (recommended)

- Update `CHANGELOG.md` and `lua/rovo-dev/version.lua` (no leading `v` in the file)
- Commit your changes
- Create and push a tag:

```bash
git tag -a vX.Y.Z -m "vX.Y.Z"
git push origin vX.Y.Z
```

- CI will verify that `version.lua` matches the tag and create the GitHub release

2. Manual release (workflow dispatch)

- In GitHub Actions, run the “Release” workflow manually
- Provide the version as `X.Y.Z` (no leading `v`)
- The workflow will write `lua/rovo-dev/version.lua`, commit, push, and create the release

Notes

- Avoid force-updating or reusing tags
- Optionally sign tags: `git tag -s vX.Y.Z -m "vX.Y.Z"`

## License

Copyright (c) 2025 Atlassian US., Inc.
MIT licensed, see [LICENSE](LICENSE) file.

<br/>

[![With ❤️ from Atlassian](https://raw.githubusercontent.com/atlassian-internal/oss-assets/master/banner-with-thanks.png)](https://www.atlassian.com)
