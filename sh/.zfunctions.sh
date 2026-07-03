# The dotfiles front door. `dot` opens the menu; the re* commands map to its
# subcommands so existing muscle memory (and flags like --clear-cache) keep working.
dot() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/dot.sh" "$@"
}

redot() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/dot.sh" sync "$@"
}

restow() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/dot.sh" stow "$@"
}

repack() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/dot.sh" pack "$@"
}

reenv() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/dot.sh" env "$@"
}

asdf-load() {
  local versions_file="${1:-.tool-versions}"

  if [[ ! -e "$versions_file" ]]; then
    echo "No .tool-versions found at: $versions_file"
    return 1
  fi

  if ! command -v asdf >/dev/null 2>&1; then
    echo "asdf not installed"
    return 1
  fi

  local installed_plugins
  installed_plugins=$(asdf plugin list 2>/dev/null || true)

  while IFS=' ' read -r plugin version; do
    [[ -z "$plugin" || "$plugin" =~ ^# ]] && continue

    if ! echo "$installed_plugins" | grep -q "^${plugin}$"; then
      echo "Adding asdf plugin: $plugin"
      asdf plugin add "$plugin"
    fi

    # 'system' is a pseudo-version meaning "defer to the OS install"; there
    # is nothing to install for it.
    if [[ "$version" == "system" ]]; then
      echo "Using system $plugin, skipping install"
      continue
    fi

    echo "Installing $plugin $version"
    asdf install "$plugin" "$version"
  done < "$versions_file"
}

drag-toggle() {
  local current
  current=$(defaults read -g NSWindowShouldDragOnGesture 2>/dev/null || echo "false")

  if [[ "$current" == "1" || "$current" == "true" ]]; then
    defaults write -g NSWindowShouldDragOnGesture -bool false
    echo "Window drag on gesture: disabled"
  else
    defaults write -g NSWindowShouldDragOnGesture -bool true
    echo "Window drag on gesture: enabled (ctrl+cmd drag)"
  fi
}

git-ssh() {
  local url
  url=$(git remote get-url origin 2>/dev/null) || { echo "No remote 'origin' found"; return 1; }

  if [[ "$url" != *github.com* ]]; then
    echo "Remote is not GitHub: $url"
    return 1
  fi

  if [[ "$url" == git@* ]]; then
    echo "Already using SSH: $url"
    return 0
  fi

  local new_url
  new_url=$(echo "$url" | sed 's|https://github.com/|git@github.com:|')

  git remote set-url origin "$new_url"
  echo "Updated origin:"
  echo "  $url → $new_url"
}
