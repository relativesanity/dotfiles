# Dotfiles

Personal macOS dotfiles managed with GNU Stow.

## Bootstrap

To bootstrap a new machine, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/main/bin/bootstrap.sh)"
```

This will:
- Install Homebrew, Git, and Zsh
- Clone this repository to `~/.dotfiles`
- Detect environment (home vs work) and install appropriate packages
- Symlink all configurations using Stow

**To test a specific branch:**
```bash
DOTFILES_BRANCH=branch-name /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/branch-name/bin/bootstrap.sh)"
```

## Post-Bootstrap Steps

### Authentication

**GitHub CLI**
```bash
gh auth login
```

**Hetzner Cloud CLI**
Edit `~/.config/hcloud/cli.toml` and add your API token.

### Optional Configurations

**Git Local Config**
Create `~/.config/git/config.local` for work-specific settings:
```toml
[user]
  email = "work@example.com"
```

**Local Environment Variables**
Create `~/.env.local.sh` for machine-specific environment variables:
```bash
export OPENAI_API_KEY="sk-..."
export WORK_PROJECT_PATH="$HOME/work"
```

**Environment-Specific Packages**

The dotfiles automatically detect your environment based on username:
- **Home** (`relativesanity`): Installs core packages + all personal packages
- **Work** (other usernames): Installs core packages only

Package files:
- `Brewfile` - Core packages (git, stow, gh, neovim, starship, zoxide, fzf, tmux, ghostty)
- `Brewfile.home` - Personal packages (full setup)
- `Brewfile.work` - Work-specific packages (add as needed)
- `Brewfile.local` - Machine-specific overrides (gitignored)

**To add packages on a work machine:**
```bash
cd ~/.dotfiles
echo 'brew "package-name"' >> Brewfile.work
repack
```

### macOS Customization

**Dock and Window Animations**
```bash
~/.dotfiles/bin/m.sh
```

**System Permissions**
Grant permissions when prompted:
- Accessibility (for Hammerspoon, AeroSpace)
- Input Monitoring (for Kanata, if installed)
- Screen Recording (for Hammerspoon screenshots)

### Kanata Setup (Laptops Only)

Only needed for home row mods on MacBook internal keyboard.

See `kanata/kanata.md` for detailed instructions.

## Maintenance

**Update everything**
```bash
redot  # Alias for ./bin/redot.sh
```

**Update packages only**
```bash
repack  # Alias for ./bin/repack.sh
```

**Re-symlink configs**
```bash
restow  # Alias for ./bin/restow.sh
```
