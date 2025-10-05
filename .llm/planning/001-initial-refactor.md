# Dotfiles Refactoring Plan

**Status:** Completed (Phases 1-2), Phase 3 deferred
**Last updated:** 2025-10-05
**Branch:** Merged to main from `claude-refactor`

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

### Phase 1: Quick Wins ✅ COMPLETED
- [x] Clean up tmux.conf (removed comments, documented transparent background)
- [x] Simplify starship.toml (added documentation, kept necessary nerd-font config)
- [x] Auto-install tmux plugins (added to repack.sh)
- [x] Document m.sh purpose (standardized header format)
- [x] Standardize all bin/*.sh documentation headers
- [x] Add shell script documentation standards to .llm/rules.md
- [x] Post-bootstrap checklist - SKIPPED (impractical for terminal output)

### Phase 2: Polish & Optimize ✅ COMPLETED
- [x] Refactor Brewfile organization (alphabetical sorting, simple sections)
- [x] Aerospace config review (documented meh/hyper keybindings)
- [x] Add validation to scripts - SKIPPED (current error handling sufficient)
- [x] Bootstrap improvements - SKIPPED (keep simple and scriptable)
- [x] Create .env.local.sh template - SKIPPED (added to README instead)
- [x] Expand README with post-bootstrap documentation

### Phase 3: Advanced Features 🔄 DEFERRED
- [ ] TUI for dotfiles management (item 11)
- [ ] Semi-automated Kanata setup - SKIPPED (requires sudo, infrequent operation)
- [ ] Auth credential helpers (item 13)
- [ ] Package audit tool (item 14)
- [ ] Dotfiles health check (item 15)

## Progress Tracking

### Completed
- [x] Documentation audit and cleanup
- [x] Codebase structure verification
- [x] Manual intervention point identification
- [x] Script quality assessment
- [x] Configuration file audit
- [x] Phase 1: Quick Wins
- [x] Phase 2: Polish & Optimize

### In Progress
- [ ] Phase 3: Advanced Features (deferred for future work)

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

## Decisions Made

1. **bin/m.sh remains manual** - Dock customization is user preference, not required
2. **starship.toml keeps nerd-font symbols** - Required for icon display, not optional
3. **Brewfile uses simple alphabetical organization** - Taps, Brews, Casks, Mac App Store
4. **Prefer simplicity over automation** - No code is bug-free, keep bootstrap scriptable
5. **Documentation over templates** - README covers optional configs (.env.local.sh, etc.)
6. **Skip validation additions** - Existing error handling (set -euo pipefail) is sufficient

## Implementation Notes

### What Worked Well
- Standardized documentation format across all bin scripts
- Alphabetical Brewfile organization removes categorization decisions
- Comprehensive README provides clear post-bootstrap guidance
- Phase 1 and 2 improvements were practical and low-risk

### What Was Skipped and Why
- **Post-bootstrap checklist file**: Markdown doesn't render in terminal, scrolls away
- **Script validation**: Existing error handling sufficient, no Intel support needed
- **Interactive bootstrap**: Breaks automation, Brewfile.local handles machine-specific needs
- **Kanata automation**: Requires sudo, infrequent enough to stay manual
- **Phase 3 advanced features**: Deferred as nice-to-have, not essential
