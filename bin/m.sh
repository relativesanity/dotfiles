#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# macOS UI customization script
# Configures Dock and window animations
# Supports:
#   - macOS (via m-cli)
#
# Usage:
#   ./m.sh
#
# Prerequisites:
#   - m-cli must be installed (via Homebrew)

if command -v m >/dev/null 2>&1; then
  m dock --prune
fi
