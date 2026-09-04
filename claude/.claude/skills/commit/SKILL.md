---
name: commit
description: Stage and commit changes following the repository's established commit style
---

## Commit Workflow

1. Run `git log --format='%s' -5` to identify the exact commit message style used in this repository
2. Run `git status` and `git diff` to understand what's changed
3. Check if `CLAUDE.md`, `Readme.md`, or other documentation needs updating given the changes — if so, propose updates and wait for approval before proceeding
4. If the change **removed or renamed** anything referred to by name — a command, flag, function, file or config key — grep the whole repo for the old name before committing. Stale references outlive the thing they describe, and the ones that rot unnoticed live outside `bin/` and the top-level `*.md`: `kanata/kanata.md`, `mise/.config/mise/config.toml`, comments in stowed configs like `sketchybar/.config/sketchybar/plugins/vpn.sh`
5. Stage the relevant files (prefer specific file names over `git add .`)
6. Draft the commit message(s) using the style observed in step 1, falling back to the default format below if no history exists.
7. **Gate check, before showing the draft to anyone:** does step 1's history show single-line subjects only? If so, the draft must be a single line too — even for a change that feels like it deserves a body. Re-read the draft against step 1's actual output, not against the body example below; that example is the no-history fallback, not a default to reach for. If the honest single-line version can't capture the *what*, that's a signal to split into multiple focused commits (see bottom) rather than to add a body anyway.
8. Show the drafted commit message(s) — all of them, if there are several — to the user and wait for explicit approval. Only then run `git commit`.

Never amend existing commits. Never use `--no-verify`.

## Default Commit Message Format

- Lowercase, except words that are specifically cased (brands, acronyms, proper nouns — e.g. GitHub, macOS, Ruby)
- Short single-line subject describing the change at a high level
- Present tense verb to start: "adds", "removes", "fixes", "updates", "changes", "moves", "renames", etc.
- Keep the subject line between 80 and 100 characters. If the honest version runs longer, cut detail rather than wrap it, or split into multiple commits (see bottom) if no cut leaves it accurate.
- Example: `fixes the issue raised in ticket 1234`

If more detail is needed *and* the repo's own history uses bodies (step 1), add one — but only for context that isn't already recoverable from the diff or from docs the commit itself updates. A body that restates a rationale already written into `CLAUDE.md` or a code comment is redundant; skip it.

Use the subject as the first line and add a short description after a blank line:

```
fixes session timeout on mobile

Safari aggressively suspends background tabs, causing the auth token
to expire before the user returns. Bumps the timeout to 4 hours.
```

When a commit message would need to be longer than one line just to describe the *what*, consider whether the changes should be split into multiple focused commits instead.
