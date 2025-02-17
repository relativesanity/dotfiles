#!/usr/bin/env bash

if command -v m >/dev/null 2>&1; then
  m dock prune
  m dock autohide YES
fi
