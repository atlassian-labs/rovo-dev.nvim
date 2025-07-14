---
name: Bug report
about: Create a report to help improve Rovo-Dev.nvim
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

A clear and concise description of what the bug is.

## Steps To Reproduce

1. Go to '...'
2. Run command '....'
3. See error

## Expected Behavior

A clear and concise description of what you expected to happen.

## Screenshots

If applicable, add screenshots to help explain your problem.

## Environment

- OS: [e.g. Ubuntu 22.04, macOS 13.0, Windows 11]
- Neovim version: [e.g. 0.9.0]
- Rovo Dev CLI version: [e.g. 1.0.0]
- Plugin version or commit hash: [e.g. main branch as of date]

## Plugin Configuration

```lua
-- Your Rovo-Dev.nvim configuration here
require("rovo-dev").setup({
  -- Your configuration options
})
```

## Additional Context

Add any other context about the problem here, such as:
- Error messages from Neovim (:messages)
- Logs from the Rovo Dev terminal
- Any recent changes to your setup

## Minimal Reproduction

For faster debugging, try to reproduce the issue using our minimal configuration:

1. Create a new directory for testing
2. Copy `tests/minimal-init.lua` from this repo to your test directory
3. Start Neovim with this minimal config:
   ```bash
   nvim --clean -u minimal-init.lua
   ```
4. Try to reproduce the issue with this minimal setup
