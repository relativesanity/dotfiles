# CLAUDE.md

## Repository

Personal macOS dotfiles managed with GNU Stow. All scripts require macOS and use `set -euo pipefail`.

Non-obvious facts:
- `kanata/` is NOT stowed — requires manual setup (see `kanata/kanata.md`)
- Brewfile loading is environment-aware: always `Brewfile`, then `Brewfile.home` or `Brewfile.work` based on `whoami`, then `Brewfile.local` if present

## Commits

1. Run `git log --format='%s' -5` first — match the exact style (lowercase present tense, e.g. "adds X to Y")
2. Never ask about commit message format — the log tells you
3. Never amend — always create new commits
4. Before committing, check if `CLAUDE.md` or `Readme.md` needs updating; propose and wait for approval first
5. Only commit when explicitly asked

Order commits as a logical narrative (foundation before features), not grouped by type of change.

## Shell Scripts (`bin/`)

All scripts must use this header:

```bash
#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# [Brief title] - one-line description
# Supports:
#   - macOS (via [tool])
#
# Usage:
#   ./script-name.sh [args]
#
# Prerequisites:
#   - [dependency] (via Homebrew)
```

## Conventions

- Small, focused edits — preserve stow package structure and macOS compatibility
- No new dependencies without justification
