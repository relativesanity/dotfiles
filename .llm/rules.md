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

### Package Management
The repository uses multiple Brewfiles for different environments:
- `Brewfile` - Core packages for all systems
- `Brewfile.home` - Additional packages for personal systems (when user is "relativesanity")
- `Brewfile.work` - Additional packages for work systems
- `Brewfile.local` - User-specific packages (gitignored)

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
- `sh/` - Zsh configuration (.zlogin, .zshenv, .aliases.sh)
- `git/` - Git configuration
- `neovim/` - Neovim configuration
- `tmux/` - Tmux configuration
- `hammerspoon/` - Hammerspoon window manager config
- `starship/` - Shell prompt configuration
- `ghostty/` - Terminal emulator settings
- `btop/` - System monitor configuration
- `kanata/` - Keyboard remapping configuration

### Environment-Specific Logic
The `repack.sh` script uses the current username to determine which Brewfile to use:
- User "relativesanity" gets Brewfile.home with cleanup/zap options
- Other users get Brewfile.work without cleanup

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

## How tools should use this file

- Cursor: reads `.cursorrules` which points here
- Claude: reads `CLAUDE.md` which points here