col() {
  awk "{print \$${1:-1}}"
}

redot() {
  cd "${DOTFILES_PATH:-$HOME/.dotfiles}" &&
    echo "Current branch: $(git branch --show-current)" &&
    git pull &&
    ./bin/repack.sh &&
    ./bin/restow.sh &&
    ./bin/reenv.sh
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
