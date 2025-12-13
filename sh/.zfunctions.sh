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
