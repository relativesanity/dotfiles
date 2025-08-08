#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# rbenv updater
#
# Checks to see if a global ruby version is specified, and then tries to
# install it. Requires rbenv to be installed.

reenv() {
  [[ -e "$HOME/.rbenv/version" ]] && \
    rbenv install -s "$(cat "$HOME/.rbenv/version")"
}

reenv
