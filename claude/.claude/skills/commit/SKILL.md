---
name: commit
description: Stage and commit changes following the repository's established commit style
---

## Commit Workflow

1. Run `git log --format='%s' -5` to identify the exact commit message style used in this repository
2. Run `git status` and `git diff` to understand what's changed
3. Check if `CLAUDE.md`, `Readme.md`, or other documentation needs updating given the changes — if so, propose updates and wait for approval before proceeding
4. If the change **removed or renamed** anything referred to by name — a command, flag, function, file or config key — grep the whole repo for the old name before committing. Stale references outlive the thing they describe, and the ones that rot unnoticed live outside `bin/` and the top-level `*.md`: `kanata/kanata.md`, `node/.default-npm`, comments in stowed configs like `neovim/.config/nvim/lua/config/lsp.lua`
5. Stage the relevant files (prefer specific file names over `git add .`)
6. Commit using the style observed in step 1, falling back to the default format below if no history exists

Never amend existing commits. Never use `--no-verify`.

## Default Commit Message Format

- Lowercase, except words that are specifically cased (brands, acronyms, proper nouns — e.g. GitHub, macOS, Ruby)
- Short single-line subject describing the change at a high level
- Present tense verb to start: "adds", "removes", "fixes", "updates", "changes", "moves", "renames", etc.
- Example: `fixes the issue raised in ticket 1234`

If more detail is needed, use the subject as the first line and add a short description after a blank line:

```
fixes session timeout on mobile

Safari aggressively suspends background tabs, causing the auth token
to expire before the user returns. Bumps the timeout to 4 hours.
```

When a commit message would need to be longer than one line just to describe the *what*, consider whether the changes should be split into multiple focused commits instead.
