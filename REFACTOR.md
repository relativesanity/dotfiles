# Dotfiles Refactoring Plan

**Status:** Planning phase
**Last updated:** 2025-10-01
**Branch:** `claude-refactor`

## Goals

1. **Documentation** - Clear, concise, accurate documentation that matches the codebase
2. **Configuration simplicity** - Each config provides only what's needed, no cruft
3. **Script quality** - Clean, human-readable, maintainable installation/maintenance scripts
4. **Single bootstrap** - Entire repo remains installable via one bootstrap command
5. **Automation** - Minimize manual intervention points

## Audit Findings

### Documentation Status ✅
- [x] Removed duplicate CLAUDE.local.md
- [x] Updated .llm/rules.md to match actual codebase
- [x] Fixed README.md case sensitivity
- [x] Added kanata special handling documentation
- [x] Verified all package lists match restow.sh

### Configuration Files

#### Clean & Minimal ✅
- `git/.config/git/config` - Bare essentials only (15 lines)
- `hammerspoon/.hammerspoon/init.lua` - Simple hotkeys only (31 lines)
- `sh/.zfunctions.sh` - Single utility function (4 lines)
- `sh/.aliases.sh` - Well organized, no bloat (33 lines)
- `sh/.zshrc` - Clean structure, good comments (72 lines)

#### Reasonable Complexity ⚠️
- `tmux/.tmux.conf` - 74 lines, mostly necessary config, some commented cruft
- `Brewfile` - 76 packages, could benefit from organization review

#### High Complexity 🔍
- `starship/.config/starship.toml` - 176 lines of symbol definitions (mostly defaults)
- `aerospace/.config/aerospace.toml` - 177 lines, extensive keybindings and config

### Scripts

#### Clean & Well-Structured ✅
- `bin/bootstrap.sh` - 138 lines, good error handling, clear structure
- `bin/restow.sh` - 135 lines, explicit package array, solid error handling
- `bin/repack.sh` - 107 lines, straightforward Brewfile bundling
- `bin/redot.sh` - 21 lines, simple orchestration script
- `bin/reenv.sh` - 17 lines, minimal rbenv version installer
- `bin/m.sh` - 21 lines, macOS dock customization

All scripts use proper error handling (`set -euo pipefail`) and clear status messages.

### Manual Intervention Points

#### Current Manual Steps
1. **Kanata setup** (documented in `kanata/kanata.md`)
   - Requires Karabiner Elements pre-installation
   - Manual LaunchDaemon plist copy: `sudo cp kanata/com.example.kanata.plist /Library/LaunchDaemons/`
   - Manual permissions: Input Monitoring in System Preferences
   - Manual start: `sudo launchctl load/start`

2. **GitHub CLI authentication** (`gh/.config/gh/hosts.yml`)
   - Requires `gh auth login` after bootstrap

3. **Hetzner CLI authentication** (`hetzner/.config/hcloud/cli.toml`)
   - Requires manual token configuration

4. **Git local config** (`git/.config/git/config.local`)
   - Optional work-specific git config overrides

5. **Local environment variables** (`sh/.env.local.sh`)
   - Referenced in .zshrc but not tracked in repo

6. **Brewfile.local**
   - Optional machine-specific packages (currently exists but gitignored)

7. **First-time tmux plugin install**
   - TPM is cloned by repack.sh, but plugins need manual `prefix + I` in tmux

8. **macOS System Preferences**
   - Various permission dialogs (Accessibility, Input Monitoring, etc.)
   - Dock preferences set by m.sh but not automated on first run

## Refactoring Recommendations

### Priority 1: High Impact, Low Effort

1. **Clean up tmux.conf**
   - Remove commented-out lines (52-54)
   - Document why transparent background hack is needed

2. **Simplify starship.toml**
   - Current file is 176 lines of mostly symbol overrides
   - Starship comes with good defaults - only customize what's truly needed
   - Consider: Keep only the symbols that differ from defaults

3. **Add post-bootstrap checklist**
   - Create `BOOTSTRAP_CHECKLIST.md` that lists remaining manual steps
   - Have bootstrap.sh echo this checklist at the end
   - Track what still needs manual intervention

4. **Auto-install tmux plugins**
   - After TPM clone, run plugin install automatically
   - Add to repack.sh: `$HOME/.tmux/plugins/tpm/bin/install_plugins`

5. **Document m.sh purpose**
   - Add comment header explaining what it does
   - Clarify when/why to run it (not part of redot.sh)

### Priority 2: Medium Impact, Medium Effort

6. **Refactor Brewfile organization**
   - Add comment sections (currently minimal)
   - Consider: Group by purpose (terminal, dev, productivity, etc.)
   - Review if all 76 packages are truly "core" or some should move to local

7. **Aerospace config review**
   - 177 lines is extensive but appears well-organized
   - Document custom keybindings in a comment header
   - Consider: Extract common patterns or reduce duplication

8. **Add validation to scripts**
   - Check if running on Apple Silicon vs Intel (affects /opt/homebrew path)
   - Validate macOS version compatibility
   - Add dry-run mode for testing

9. **Bootstrap script improvements**
   - Add interactive mode: Ask which optional features to enable
   - Ask about Kanata setup (laptop vs desktop)
   - Ask about work vs personal environment

10. **Create .env.local.sh template**
    - Add `.env.local.sh.example` with common patterns
    - Document what should go there
    - Maybe generate it during bootstrap with interactive prompts

### Priority 3: Nice to Have, Higher Effort

11. **TUI for dotfiles management**
    - Interactive tool for:
      - Viewing current configuration status
      - Selectively enabling/disabling stow packages
      - Running individual maintenance tasks
      - Viewing package lists and installed status
    - Consider: Use `gum` or `charmbracelet/bubbletea` for TUI
    - Defer until P1 and P2 complete

12. **Semi-automated Kanata setup**
    - Detect if on laptop (built-in keyboard present)
    - Prompt whether to install Kanata
    - Automate LaunchDaemon installation (needs sudo)
    - Provide clear instructions for permissions
    - Add to bootstrap wizard

13. **Auth credential helpers**
    - Script to check auth status: `./bin/check-auth.sh`
    - Reports: gh, hetzner, git, etc.
    - Provides commands to fix each

14. **Package audit tool**
    - Check which Brewfile packages are actually installed
    - Check which installed packages aren't in Brewfile
    - Suggest cleanup or addition to Brewfile.local

15. **Dotfiles health check**
    - `./bin/doctor.sh` style script
    - Verifies all stow packages are linked correctly
    - Checks for broken symlinks
    - Validates configuration file syntax where possible

## Implementation Strategy

### Phase 1: Quick Wins (Current)
- Complete documentation cleanup ✅
- Priority 1 items (1-5 above)
- Low risk, immediate value

### Phase 2: Polish & Optimize
- Priority 2 items (6-10 above)
- Improve existing functionality
- Better user experience

### Phase 3: Advanced Features
- Priority 3 items (11-15 above)
- New capabilities
- Automation of complex tasks

## Progress Tracking

### Completed
- [x] Documentation audit and cleanup
- [x] Codebase structure verification
- [x] Manual intervention point identification
- [x] Script quality assessment
- [x] Configuration file audit

### In Progress
- [ ] None

### Blocked
- [ ] None

## Notes for Future Claude Instances

When picking up this refactoring:

1. **Read this file first** - It contains the complete audit and plan
2. **Check git branch** - Work should continue on `claude-refactor` branch
3. **Verify documentation** - `.llm/rules.md` is the source of truth for project rules
4. **Test changes** - Each script can be tested individually before committing
5. **Follow commit style** - Run `git log --oneline -10` to match existing patterns
6. **Maintain bootstrap capability** - Any changes MUST keep `bootstrap.sh` working
7. **Update this file** - As work progresses, check off completed items and add notes

## Open Questions

1. Should `bin/m.sh` be integrated into bootstrap or remain manual?
2. Is starship.toml providing value with all those symbols, or using defaults better?
3. Should Brewfile be split further (base, terminal, dev, apps)?
4. What's the right balance between automation and letting users make choices?
