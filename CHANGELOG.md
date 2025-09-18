# Changelog

All notable changes to this project will be documented in this file.

This project follows Keep a Changelog and Semantic Versioning (SemVer). For new releases, use the template in `.github/CHANGELOG_TEMPLATE.md`.

## [0.1.1] - 2025-09-18
### Fixed
- Buffers with externally deleted files no longer receive spammy modified notifications
### Changed
- Terminal window now has a max width of 120 columns to prevent wasted space

## [0.1.0] - 2025-08-16
### Added
- Initial public release of rovo-dev.nvim
- Toggleable, fixed-width terminal split for Rovo Dev CLI
- Automatic buffer refresh on file changes (event-driven and terminal-output debounced)
- Notifications for visible buffers when files are reloaded/changed on disk
- Commands: :RovoDevToggle, :RovoDevRestore, :RovoDevVerbose, :RovoDevShadow, :RovoDevYolo

