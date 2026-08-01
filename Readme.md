# Dotfiles

Personal macOS dotfiles managed with GNU Stow.

## Bootstrap

To bootstrap a new machine, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/main/bin/bootstrap.sh)"
```

This will:
- Install Homebrew, Git and Zsh
- Clone this repository to `~/.dotfiles`
- Ask whether to continue to the full installation — answer `y`; anything else stops here
- Detect environment (home vs work) and install appropriate packages
- Symlink all configurations using Stow

The prompt defaults to no because continuing runs `brew bundle --zap`, which
uninstalls anything the Brewfiles don't declare. Declining leaves the machine
untouched beyond the prerequisites and the clone — pick up later with
`~/.dotfiles/bin/redot.sh` (nothing is stowed yet, so the `redot` shell function
doesn't exist until the first sync). With no terminal to ask on, bootstrap stops
after the clone rather than installing anything.

**To test a specific branch:**
```bash
DOTFILES_BRANCH=branch-name /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/branch-name/bin/bootstrap.sh)"
```

**To clone to a custom location** (defaults to `~/.dotfiles`):
```bash
DOTFILES_PATH=/custom/path /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/relativesanity/dotfiles/refs/heads/main/bin/bootstrap.sh)"
```
Bootstrap persists `DOTFILES_PATH` to `~/.zprofile.local` so future shells resolve the repo to the same place.

## Post-Bootstrap Steps

### Authentication

**GitHub CLI**
```bash
gh auth login
```

CLIs that write their own credentials into their config (e.g. Hetzner's
`hcloud`) are not stowed — authenticate them locally per each tool's own
instructions, so no API tokens ever land in this repo.

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

**Local Shell Overrides**
Each is sourced if present, after the tracked config:
- `~/.zprofile.local` — machine-specific PATH additions and login-shell setup
- `~/.zshrc.local` — machine-specific interactive shell tweaks

**Environment-Specific Packages**

The dotfiles automatically detect your environment based on username:
- **Home** (`relativesanity`): Installs core packages + all personal packages
- **Work** (other usernames): Installs core packages only

Package files:
- `Brewfile` - Core packages required for deployment and a working terminal (stow, git, gh, neovim, tmux, rv, fzf, ripgrep, bat, zoxide, starship, ghostty, libyaml, tree-sitter-cli) — see `Brewfile` for the full list
- `Brewfile.home` - Personal packages (full setup)
- `Brewfile.work` - Work-specific packages (add as needed)
- `Brewfile.local` - Machine-specific overrides (gitignored)
- `Brewfile.keep` - The keep-list, rebuilt by `repack` (gitignored): casks and App Store apps you installed by hand, so cleanup won't uninstall them. Promote keepers into `Brewfile.home`/`Brewfile.work` and they drop off

**To add packages on a work machine:**
```bash
cd ~/.dotfiles
echo 'brew "package-name"' >> Brewfile.work
repack
```

### Shell Helpers

Defined in `sh/.zfunctions.sh`, alongside the `redot`/`repack`/`restow`/`reenv`
wrappers covered under Maintenance below:
- `ruby-load [version]` — install the Ruby the current project asks for. `rv` reads
  the version from `.ruby-version`, `.tool-versions` or `Gemfile.lock` and switches
  automatically on `cd`, so this only ensures it's installed; pass a version to override
- `git-ssh` — rewrite the current repo's GitHub `origin` from HTTPS to SSH
- `drag-toggle` — enable/disable ctrl+cmd window dragging (`NSWindowShouldDragOnGesture`)

### macOS Customization

**System Permissions**
Grant permissions when prompted:
- Accessibility (for AeroSpace, and for Kanata if installed)
- Input Monitoring (for Kanata, if installed)

Kanata needs *both* Accessibility and Input Monitoring, and macOS revokes them
whenever Homebrew updates the binary — see `kanata/kanata.md` for the re-grant fix.

### Kanata Setup (Laptops Only)

Only needed for home row mods on MacBook internal keyboard.

See `kanata/kanata.md` for detailed instructions.

## Maintenance

Each script does one job and is safe to run on its own — it prints a plan and
asks before changing anything. To preview without applying, run it and answer no.

| Command  | Does                                                   |
| -------- | ------------------------------------------------------ |
| `redot`  | Pull, then all three below, in order                    |
| `repack` | Homebrew packages                                       |
| `restow` | Re-symlink configs                                      |
| `reenv`  | Install ruby runtimes and global tools                  |

A bare `repack` upgrades everything installed, installs what the Brewfiles
declare, keeps the apps you installed by hand, and removes the rest. Two options
change that, and pass through `redot`:

| Option           | Does                                                          |
| ---------------- | ------------------------------------------------------------- |
| `--install-only` | Install what's declared and missing. No upgrades, no removals  |
| `--prune`        | Use `Brewfile.keep` as it stands, removing anything not on it  |

`restow` and `reenv` take no options.

**Removing an app you installed by hand:** it's on the keep-list, so a normal run
protects it. Delete its line from `Brewfile.keep`, then `repack --prune`.

These scripts always ask before applying, so they need a terminal and refuse
without one. Unattended use (cron, CI) is not supported.
