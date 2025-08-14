# Development Guide

This document explains how to work on rovo-dev.nvim, run it locally, execute the test suite, and understand the CI/release setup. It reflects the current repository structure and tooling.

## Requirements

- Neovim 0.10+ (tested in CI on stable and nightly)
- Git
- Optional (for formatting/linting if you prefer):
  - stylua (formatter)
  - luacheck (linter)

## Project Layout

```
.
├── README.md
├── README_ATLASSIAN.md
├── DEVELOPMENT.md
├── doc/
│   └── rovo-dev.txt          # :help rovo-dev
├── lua/
│   └── rovo-dev/
│       ├── init.lua          # minimal entry; wires modules
│       ├── config.lua        # defaults and user options
│       ├── state.lua         # buffer/window/job state
│       ├── terminal.lua      # split creation, CLI launch, flags
│       ├── file_refresh.lua  # checktime + notifications
│       ├── keymaps.lua       # default keymap registration
│       └── commands.lua      # :RovoDev* commands
├── tests/
│   ├── minimal_init.lua      # headless test init (loads plenary.busted)
│   └── test_rovo_dev_spec.lua
└── .github/workflows/
    ├── ci.yml                # runs plenary tests on stable/nightly
    ├── dependency-updates.yml
    └── release.yml
```

## Local Setup

You can develop by putting this repo on your runtimepath or as a local plugin.

- Easiest: open Neovim in this repo and add it to `runtimepath` for the session:

```vim
:lua vim.opt.runtimepath:append(vim.fn.fnamemodify('.', ':p'))
```

- Or, symlink/clone into your site packpath:

```
~/.local/share/nvim/site/pack/dev/start/rovo-dev.nvim -> /path/to/this/repo
```

Then in Neovim/Lua:

```lua
require('rovo-dev').setup({
  terminal = { cmd = { 'acli', 'rovodev', 'run' }, side = 'right', width = 0.33 },
})
```

## Running Tests

Tests use plenary’s busted runner.

1) Ensure plenary.nvim is available. For example:

```
mkdir -p ~/.local/share/nvim/site/pack/vendor/start
git clone --depth 1 https://github.com/nvim-lua/plenary.nvim \
  ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
```

2) Run the suite headless from the repo root:

```
nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }" \
  -c 'qa!'
```

- `tests/minimal_init.lua` sets up the runtimepath and loads `plenary.busted`.
- Specs live in `tests/test_rovo_dev_spec.lua`.

### Running tests inside Neovim

From a normal Neovim session (with plenary on runtimepath):

```
:luafile tests/minimal_init.lua
:PlenaryBustedDirectory tests/ { minimal_init = './tests/minimal_init.lua' }
```

## Coding Standards (optional)

This repository doesn’t enforce formatter/linter in CI yet. If you prefer, use:
- stylua for formatting
- luacheck for linting

## Continuous Integration

GitHub Actions workflow runs on push/PR to main (see `.github/workflows/ci.yml`):
- Installs Neovim (stable, nightly)
- Clones plenary into the default site packpath
- Runs the Plenary test suite with the minimal init

## Release Process

Releases are created via tags or manual dispatch (see `.github/workflows/release.yml`):
- Tag push `vX.Y.Z` triggers a release
- Or run the workflow with an input version (validates X.Y.Z)
- Changelog body is generated from CHANGELOG.md section or fallback git log

## Troubleshooting

- “module 'rovo-dev' not found”: ensure the repo is on `runtimepath`.
- Plenary commands missing: verify plenary is installed in site packpath or by your plugin manager.
- No notifications: notifications are only shown for buffers visible in non-floating windows.
- Tests fail headless: run `nvim --version` to make sure you’re on 0.10+.

## Contributing

Issues and PRs are welcome. Please keep changes minimal and focused. Add/adjust tests for behavior changes where possible.


This document outlines the development workflow, testing setup, and requirements for working with Neovim Lua projects such as this configuration, Laravel Helper plugin, and Rovo Dev plugin.

## Requirements

### Core Dependencies

- **Neovim**: Version 0.10.0 or higher
  - Required for `vim.system()`, splitkeep, and modern LSP features
- **Git**: For version control
- **Make**: For running development commands

### Development Tools

- **stylua**: Lua code formatter
- **luacheck**: Lua linter
- **ripgrep**: Used for searching (optional but recommended)
- **fd**: Used for finding files (optional but recommended)

## Installation Instructions

### Linux

#### Ubuntu/Debian

```bash
# Install Neovim (from PPA for latest version)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

# Install luarocks and other dependencies
sudo apt-get install luarocks ripgrep fd-find git make

# Install luacheck
sudo luarocks install luacheck

# Install stylua
curl -L -o stylua.zip $(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep -o "https://.*stylua-linux-x86_64.zip")
unzip stylua.zip
chmod +x stylua
sudo mv stylua /usr/local/bin/
```

#### Arch Linux

```bash
# Install dependencies
sudo pacman -S neovim luarocks ripgrep fd git make

# Install luacheck
sudo luarocks install luacheck

# Install stylua (from AUR)
yay -S stylua
```

#### Fedora

```bash
# Install dependencies
sudo dnf install neovim luarocks ripgrep fd-find git make

# Install luacheck
sudo luarocks install luacheck

# Install stylua
curl -L -o stylua.zip $(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep -o "https://.*stylua-linux-x86_64.zip")
unzip stylua.zip
chmod +x stylua
sudo mv stylua /usr/local/bin/
```

### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install neovim luarocks ripgrep fd git make

# Install luacheck
luarocks install luacheck

# Install stylua
brew install stylua
```

### Windows

#### Using scoop

```powershell
# Install scoop if not already installed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install dependencies
scoop install neovim git make ripgrep fd

# Install luarocks
scoop install luarocks

# Install luacheck
luarocks install luacheck

# Install stylua
scoop install stylua
```

#### Using chocolatey

```powershell
# Install chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install dependencies
choco install neovim git make ripgrep fd

# Install luarocks
choco install luarocks

# Install luacheck
luarocks install luacheck

# Install stylua (download from GitHub)
# Visit https://github.com/JohnnyMorganz/StyLua/releases
```

## Development Workflow

### Setting Up the Environment

1. Clone the repository:

   ```bash
   git clone https://github.com/atlassian-labs/rovo-dev.nvim.git
   ```

2. Install Git hooks:

   ```bash
   cd rovo-dev.nvim
   ./scripts/setup-hooks.sh
   ```

### Common Development Tasks

- **Run tests**: `make test`
- **Run linting**: `make lint`
- **Format code**: `make format`
- **View available commands**: `make help`

### Pre-commit Hooks

The pre-commit hook automatically runs:

1. Code formatting with stylua
2. Linting with luacheck
3. Basic tests

If you need to bypass these checks, use:

```bash
git commit --no-verify
```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run with verbose output
make test-verbose

# Run specific test suites
make test-basic
make test-config
```

### Running Tests from Within Neovim/Rovo Dev

When running tests from within a Neovim instance (such as when using Rovo Dev via rovo-dev.nvim), the test script automatically handles the `$NVIM` environment variable which normally points to a socket file instead of the nvim executable.

The test script will:

- Use the `$NVIM` variable if it points to a valid executable file
- Fall back to finding `nvim` in `$PATH` if `$NVIM` points to a socket or invalid path
- Display which nvim binary is being used for transparency

To verify the NVIM detection logic works correctly, you can run:

```bash
./scripts/test_nvim_detection.sh
```

### Writing Tests

Tests are written in Lua using a simple BDD-style API:

```lua
local test = require("tests.run_tests")

test.describe("Feature name", function()
  test.it("should do something", function()
    -- Test code
    test.expect(result).to_be(expected)
  end)
end)
```

## Continuous Integration

This project uses GitHub Actions for CI:

- **Triggers**: Push to main branch, Pull Requests to main
- **Jobs**: Install dependencies, Run linting, Run tests
- **Platforms**: Ubuntu Linux (primary)

## Tools and Their Purposes

Understanding why we use each tool helps in appreciating their role in the development process:

### Neovim

Neovim is the primary development platform and runtime environment. We use version 0.10.0+ because it provides:

- Better API support for plugin development
- Improved performance for larger codebases
- Enhanced LSP integration
- Support for modern Lua features via LuaJIT

### StyLua

StyLua is a Lua formatter specifically designed for Neovim configurations. It:

- Ensures consistent code style across all contributors
- Formats according to Lua best practices
- Handles Neovim-specific formatting conventions
- Integrates with our pre-commit hooks for automated formatting

Our configuration uses 2-space indentation and 100-character line length limits.

### LuaCheck

LuaCheck is a static analyzer that helps catch issues before they cause problems:

- Identifies syntax errors and semantic issues
- Flags unused variables and unused function parameters
- Detects global variable access without declaration
- Warns about whitespace and style issues
- Ensures code adheres to project-specific standards

We configure LuaCheck with `.luacheckrc` files that define project-specific globals and rules.

### Ripgrep & FD

These tools improve development efficiency:

- **Ripgrep**: Extremely fast code searching to find patterns and references
- **FD**: Fast alternative to `find` for locating files in complex directory structures

### Git & Make

- **Git**: Version control with support for feature branches and collaborative development
- **Make**: Common interface for development tasks that work across different platforms

## Project Structure

All our Neovim projects follow a similar structure:

```plaintext
```

.
├── .github/            # GitHub-specific files and workflows
├── .githooks/          # Git hooks for pre-commit validation
├── lua/                # Main Lua source code
│   └── [project-name]/ # Project-specific modules
├── test/               # Basic test modules
├── tests/              # Extended test suites
├── .luacheckrc         # LuaCheck configuration

```plaintext
```

├── .stylua.toml        # StyLua configuration
├── Makefile            # Common commands
├── CHANGELOG.md        # Project version history
└── README.md           # Project overview

```plaintext
```

## Troubleshooting

### Common Issues

- **stylua not found**: Make sure it's installed and in your PATH
- **luacheck errors**: Run `make lint` to see specific issues
- **Test failures**: Use `make test-verbose` for detailed output
- **Module not found errors**: Check that you're using the correct module name and path
- **Plugin functionality not loading**: Verify your Neovim version is 0.10.0 or higher

### Getting Help

If you encounter issues:

1. Check the error messages carefully
2. Verify all dependencies are correctly installed
3. Check that your Neovim version is 0.10.0 or higher
4. Review the project's issues on GitHub for similar problems
5. Open a new issue with detailed reproduction steps if needed
