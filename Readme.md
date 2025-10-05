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
- Install all packages from the Brewfile
- Symlink all configurations using Stow

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

**Machine-Specific Packages**
Create `~/.dotfiles/Brewfile.local` for additional packages:
```ruby
brew "kubectl"
cask "docker"
```
Run `./bin/repack.sh` to install.

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
