col() {
  awk "{print \$${1:-1}}"
}
