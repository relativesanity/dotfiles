# LLM Rules

This file documents rules, conventions, and context for this dotfiles project. It is the single source of truth for agents (Claude, Cursor, etc.). Tool-specific entrypoints should reference this file rather than duplicate content.

## Objectives
- Provide consistent guidance to LLM agents working with dotfiles
- Capture project constraints and domain context for macOS system configuration
- Maintain consistency across different environments and setups

## Scope
- Applies to all LLM-assisted work in this repository
- Covers dotfiles management, system configuration, and environment setup

## Repository Overview

This is a personal dotfiles repository that manages macOS system configuration and application settings using GNU Stow for symlink management. The repository is designed to bootstrap a new macOS system and maintain consistent configurations across different environments.

## Key Scripts and Commands

### Bootstrap Commands
- `./bin/bootstrap.sh` - One-time setup script for new systems. Installs Homebrew, Git, Zsh, downloads dotfiles, and runs initial setup
- `./bin/redot.sh` - Main sync script that pulls updates and runs all configuration steps in order

### Configuration Management
- `./bin/restow.sh` - Uses GNU Stow to symlink configuration files from the repository to home directory
- `./bin/repack.sh` - Updates Homebrew packages using Brewfiles and sets up tmux plugins
- `./bin/reenv.sh` - Installs Ruby versions specified in rbenv configuration
- `./bin/m.sh` - macOS dock and window animation customization script (uses `m` CLI tool)

### Package Management
The repository uses Brewfiles for package management:
- `Brewfile` - Core packages shared across all environments
- `Brewfile.local` - Optional machine-specific packages (gitignored)

### Aliases
Key aliases are defined in `sh/.aliases.sh`:
- `restow`, `repack`, `redot`, `reenv` - Quick access to main scripts
- `dotfiles` - Navigate to dotfiles directory
- `start` - Start/attach tmux session
- `lg` - Launch lazygit
- `gs`, `gd` - Git shortcuts

## Architecture and Structure

### Stow Package Organization
Configuration files are organized into stow packages (directories that get symlinked):
- `aerospace/` - AeroSpace tiling window manager configuration for macOS
- `borders/` - JankyBorders configuration for window borders
- `btop/` - System resource monitor configuration with Catppuccin theme
- `claude/` - Claude desktop application settings
- `gh/` - GitHub CLI configuration and authentication
- `ghostty/` - Terminal emulator configuration with Catppuccin theme and transparency
- `git/` - Git configuration including user info, aliases, and LFS setup
- `hammerspoon/` - macOS automation tool with hotkeys for reload, screenshots, and date insertion
- `hetzner/` - Hetzner Cloud CLI configuration and contexts
- `leaderkey/` - App launcher keyboard shortcuts organized by categories
- `neovim/` - Neovim editor configuration with LazyVim
- `rbenv/` - Ruby version manager configuration (currently set to 3.4.6)
- `sh/` - Shell configuration including zshrc, aliases, functions, and environment variables
- `starship/` - Shell prompt configuration with custom symbols for various tools
- `tmux/` - Terminal multiplexer configuration with custom prefix key (C-f) and vi mode

### Kanata (Keyboard Remapping)
The `kanata/` directory contains keyboard remapping configuration but is **NOT stowed** automatically. It requires manual setup:
- Home row mods configuration for MacBook's internal keyboard only
- Uses LaunchDaemon for system-level keyboard interception
- Requires Karabiner Elements to be installed and configured first
- Must grant Input Monitoring permissions manually
- See `kanata/kanata.md` for detailed installation instructions

### Package Installation
The `repack.sh` script installs packages from Brewfile and optional Brewfile.local using `brew bundle` with cleanup and zap options to remove unused packages.

### Shell Configuration
The shell setup uses Zsh with:
- Zinit plugin manager for zsh-users plugins (autosuggestions, completions, syntax highlighting)
- Vim keybindings (`bindkey -v`)
- Integration with zoxide, starship, fzf, and rbenv
- Extensive history configuration for persistence across sessions

## Development Workflow

1. Make changes to configuration files in their respective directories
2. Run `./bin/restow.sh` to update symlinks
3. Run `./bin/repack.sh` if Brewfile changes were made
4. Use `./bin/redot.sh` to sync changes from remote and apply all updates

## System Requirements

- macOS (Darwin) - All scripts check for macOS and exit on other systems
- Homebrew will be installed automatically if not present
- Git and Zsh will be installed via Homebrew if not present

## Error Handling

All shell scripts use `set -euo pipefail` for strict error handling and will exit on any command failure, undefined variables, or pipeline errors.

## Git Commit Process (MANDATORY)

When making any changes that require commits:

1. **ALWAYS run `git log --oneline -10` first** to analyze recent commit message patterns
2. **NEVER suggest commit messages** without analyzing the repository's style
3. **Use the exact format observed in recent commits** (typically lowercase, present tense: "adds X to Y")
4. **Follow the complete commit workflow:**
   - Run `git status` and `git diff` to understand changes
   - Stage relevant files with `git add`
   - Commit with analyzed message format
   - Verify with `git status`
5. **ONLY commit when explicitly asked** - never assume the user wants changes committed

## Commit Message Format
- Analyze recent commits with `git log --oneline -10` 
- Match the observed pattern (e.g., "adds slack to base Brewfile")
- Use lowercase, present tense
- Be concise and descriptive
- Focus on what was added/changed, not why

## Conventions

- Keep edits small and focused
- Follow repository commit style (analyze git history first)
- Avoid introducing dependencies without justification
- Preserve existing file structure and stow package organization
- Test changes with appropriate scripts (restow, repack, etc.)
- Maintain macOS compatibility for all configurations

### Shell Script Documentation

All shell scripts in `bin/` must follow this consistent documentation format:

```bash
#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# [Script name/purpose] - brief one-line description
# [Optional second line for additional context]
# Supports:
#   - [Platform/tool requirements]
#
# Usage:
#   ./script-name.sh [arguments]
#
# Prerequisites:
#   - [Required dependencies and their installation method]
```

**Example:**
```bash
# macOS UI customization script
# Configures Dock and window animations
# Supports:
#   - macOS (via m-cli)
#
# Usage:
#   ./m.sh
#
# Prerequisites:
#   - m-cli must be installed (via Homebrew)
```

**Rules:**
- Brief, concise language - use short phrases not full sentences
- Always include: title, "Supports:", "Usage:", "Prerequisites:" sections
- No extra "Note:" sections or verbose explanations
- Match the format in bootstrap.sh, restow.sh, repack.sh, and m.sh

## Planning Documents

Planning documents are stored in `.llm/planning/` using sequential numbering:
- `001-initial-refactor.md` - First major refactoring effort (completed 2025-10-05)
- Future planning docs follow the pattern: `NNN-descriptive-name.md`
- The descriptive name should match the git branch name used for implementation

See `.llm/planning/README.md` for an index of all planning documents.

## How tools should use this file

- Cursor: reads `.cursorrules` which points here
- Claude: reads `CLAUDE.md` which points here