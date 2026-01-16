col() {
  awk "{print \$${1:-1}}"
}

repull() {
  local dotfiles="${DOTFILES_PATH:-$HOME/.dotfiles}"
  echo "Current branch: $(git -C "$dotfiles" branch --show-current)" &&
    git -C "$dotfiles" pull
}

redot() {
  repull &&
    repack &&
    restow &&
    reenv
}

restow() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/restow.sh"
}

repack() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/repack.sh"
}

reenv() {
  "${DOTFILES_PATH:-$HOME/.dotfiles}/bin/reenv.sh"
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

    echo "Installing $plugin $version"
    asdf install "$plugin" "$version"
  done < "$versions_file"
}
