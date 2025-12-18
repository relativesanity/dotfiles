# Brewfile Split: Home vs Work Environments

**Status:** Planning
**Branch:** `002-brewfile-split`
**Created:** 2025-12-18

## Overview

Split the monolithic Brewfile into environment-specific configurations to support selective package installation on work machines while maintaining the full personal setup at home.

## Goals

1. **Minimal core dependencies** - Only what's absolutely required for dotfiles deployment
2. **Environment-aware installation** - Automatic detection of home vs work based on username
3. **Selective installation** - Ability to incrementally add packages to work environment
4. **Safe testing** - Validate changes in VM before deploying to work machine
5. **Backwards compatible** - Existing home setup continues to work without changes

## Current State Analysis

### Existing Brewfile Structure
- `Brewfile` - 87 packages (36 brews, 30 casks, 21 Mac App Store apps)
- `Brewfile.local` - 2 packages (kanata, karabiner-elements)
- `repack.sh` - Concatenates both files and runs `brew bundle --cleanup --zap`

### Critical Dependencies for Dotfiles Deployment

These packages are **required** for the dotfiles system to function:

| Package | Used By | Purpose | When Installed |
|---------|---------|---------|----------------|
| `git` | bootstrap.sh, redot.sh | Version control, pulling updates | bootstrap.sh:63 |
| `stow` | restow.sh | Symlinking config files | Must be in core |
| `gh` | Post-bootstrap auth | GitHub CLI authentication | Optional, post-bootstrap |

**Additional packages referenced in configs but not critical for deployment:**
- `rbenv`, `ruby-build` - Used by reenv.sh (can fail gracefully)
- `tmux` - Referenced in aliases but not required for shell to work
- `neovim` - Referenced in aliases but not required for shell to work
- `starship` - Shell prompt (shell works without it)
- `zoxide` - Directory jumping (shell works without it)
- `fzf` - Fuzzy finder (shell works without it)

### Recommendation for Core Brewfile
Absolute minimum for deployment:
```ruby
brew 'git'
brew 'stow'
```

Recommended core set (enables basic terminal experience):
```ruby
brew 'git'
brew 'stow'
brew 'gh'          # GitHub authentication
brew 'neovim'      # Primary editor
brew 'starship'    # Shell prompt
brew 'zoxide'      # Directory navigation
brew 'fzf'         # Fuzzy finding
```

## Proposed Architecture

### File Structure
```
.dotfiles/
├── Brewfile           # Core shared dependencies (always loaded)
├── Brewfile.home      # Full personal setup (current Brewfile contents)
├── Brewfile.work      # Work-specific packages (empty initially)
└── Brewfile.local     # Machine-specific (gitignored, unchanged)
```

### Environment Detection Logic

```bash
detect_environment() {
  if [[ "$(whoami)" == "relativesanity" ]]; then
    echo "home"
  else
    echo "work"
  fi
}
```

**Rationale:**
- Simple and reliable - username is set during macOS setup
- No need for additional config files
- Clear and explicit (work machines will have corporate username)

**Alternative considered:** Check for existence of marker file like `~/.dotfiles/.work`
- Rejected: Requires manual creation, easy to forget or misconfigure

### Package Loading Strategy

The modified `repack.sh` will load Brewfiles in this order:

1. **Brewfile** (always - core dependencies)
2. **Brewfile.home** OR **Brewfile.work** (based on environment)
3. **Brewfile.local** (if exists)

```bash
bundle_homebrew() {
  filepath="${DOTFILES_PATH:-$HOME/.dotfiles}"
  environment=$(detect_environment)

  brewfiles=()
  brewfiles+=("$filepath/Brewfile")
  brewfiles+=("$filepath/Brewfile.$environment")

  if [[ -f "$filepath/Brewfile.local" ]]; then
    brewfiles+=("$filepath/Brewfile.local")
  fi

  cat "${brewfiles[@]}" | brew bundle --file=- --cleanup --zap
}
```

## Migration Strategy

### Phase 1: Split Files (No Behavior Change)
1. Create `Brewfile.core` with minimal dependencies
2. Move all current `Brewfile` contents to `Brewfile.home`
3. Create empty `Brewfile.work`
4. Update `repack.sh` with environment detection
5. Test on home machine - should install identical packages

### Phase 2: Test in VM
1. Create macOS VM using UTM (already installed)
2. Set VM username to something other than "relativesanity"
3. Bootstrap dotfiles in VM
4. Verify only core packages install
5. Manually add test packages to Brewfile.work in VM
6. Verify selective installation works

### Phase 3: Deploy to Work Machine
1. Clone dotfiles on work machine
2. Run bootstrap
3. Incrementally add needed packages to Brewfile.work
4. Commit and push Brewfile.work changes

## Testing Strategy

### UTM VM Setup

**Prerequisites:**
- UTM already installed (in current Brewfile)
- macOS Ventura or later installer (~13GB download from Apple)

**VM Configuration:**
```
Name: dotfiles-test
RAM: 4GB
Storage: 40GB
Username: testuser (NOT relativesanity)
```

**Test Checklist:**
- [ ] Fresh VM bootstrap completes successfully
- [ ] Only core packages installed (verify with `brew list`)
- [ ] Dotfiles symlinks created correctly
- [ ] Shell loads without errors
- [ ] Can manually add packages to Brewfile.work
- [ ] `repack` installs new packages correctly
- [ ] `brew bundle cleanup` removes packages not in any Brewfile

### Manual Testing on Home Machine

Before pushing to remote:
- [ ] `repack.sh` detects "home" environment
- [ ] All current packages still install
- [ ] No packages removed by cleanup
- [ ] Can switch between environments (temporarily change whoami check)

## Implementation Steps

1. **Create branch**
   ```bash
   git checkout -b 002-brewfile-split
   ```

2. **Copy existing Brewfile to Brewfile.home**
   ```bash
   cp Brewfile Brewfile.home
   ```

3. **Edit existing Brewfile to keep only core dependencies**
   - Core set: git, stow, gh, neovim, starship, zoxide, fzf
   - Remove all other packages (they're preserved in Brewfile.home)

4. **Create empty Brewfile.work**
   ```bash
   touch Brewfile.work
   echo "# Work-specific packages" > Brewfile.work
   ```

5. **Update repack.sh**
   - Add `detect_environment()` function
   - Modify `bundle_homebrew()` to load environment-specific files
   - Update print statements to show which environment detected

6. **Update documentation**
   - `Readme.md` - Update Brewfile section
   - `.llm/rules.md` - Update package management section
   - Add section about environment detection

7. **Test on home machine**
   - Run `./bin/repack.sh`
   - Verify no packages removed
   - Check output shows "home" environment

8. **Set up VM for testing**
   - Create fresh macOS VM in UTM
   - Use non-relativesanity username
   - Run bootstrap script
   - Verify only core packages installed

9. **Create PR**
   - Review all changes
   - Ensure no unintended modifications
   - Get full diff of what would deploy to work machine

## Risk Mitigation

### Risk: Accidentally removing packages on home machine
**Mitigation:**
- Test environment detection thoroughly
- Review `brew bundle` output before confirming
- Keep backup of original Brewfile as `Brewfile.backup`

### Risk: Missing critical dependency in core Brewfile
**Mitigation:**
- Test bootstrap in fresh VM
- Document all dependencies in this plan
- Start with broader core set, narrow down after testing

### Risk: Work machine needs package that's in home Brewfile
**Mitigation:**
- Document process for moving packages between Brewfiles
- Keep Brewfile.work in git so it syncs across work machine rebuilds
- Can always temporarily add to Brewfile.local for testing

### Risk: VM testing doesn't catch all issues
**Mitigation:**
- Use VM with same macOS version as work machine
- Test full bootstrap process, not just repack
- Document any differences between VM and real hardware

## Future Enhancements

### Possible additions (not in scope for this change):
- **Profile support** - More than 2 environments (e.g., "laptop" vs "desktop")
- **Shared categories** - Move common dev tools to separate Brewfile.dev
- **Interactive mode** - Prompt which packages to install during bootstrap
- **Package tagging** - Mark packages as "essential", "optional", "home-only"

### Environment variable override:
```bash
# Allow manual override for testing
DOTFILES_ENV=work ./bin/repack.sh
```

## Open Questions

1. **Core Brewfile size** - Start with 2 packages or 7?
   - **APPROVED**: 7 packages (git, stow, gh, neovim, starship, zoxide, fzf)
   - Enables reasonable terminal experience while staying minimal

2. **Handle Brewfile.local** - Should it also be environment-aware?
   - Recommendation: No, keep it simple - local is for machine-specific overrides

3. **Cask requirements** - Any GUI apps needed for work?
   - Recommendation: Start with none, add as needed

4. **MAS apps** - Should these move to home-only?
   - Recommendation: Yes, all current MAS apps are personal

## Success Criteria

- [ ] Bootstrap on work machine installs only core packages
- [ ] Bootstrap on home machine installs everything (unchanged behavior)
- [ ] Can add packages to Brewfile.work and they install correctly
- [ ] Documentation updated to reflect new structure
- [ ] VM testing validates the approach
- [ ] No packages accidentally removed from home machine

## Timeline (No estimates, just sequence)

1. Planning and documentation (this document)
2. Get user approval on approach
3. Implement file split and repack.sh changes
4. Test on home machine
5. Set up and test in VM
6. Create PR for review
7. Deploy to work machine after approval

## Related Files

- `bin/repack.sh` - Primary modification point
- `bin/bootstrap.sh` - No changes needed (calls repack.sh)
- `Readme.md` - Documentation updates
- `.llm/rules.md` - Documentation updates
