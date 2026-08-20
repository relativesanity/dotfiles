# CLAUDE.md

## Repository

Personal macOS dotfiles managed with GNU Stow. All scripts require macOS and use `set -euo pipefail`.

Non-obvious facts:
- `kanata/` is NOT stowed — requires manual setup (see `kanata/kanata.md`)
- Brewfile loading is environment-aware: always `Brewfile`, then `Brewfile.home` or `Brewfile.work` based on `whoami`, then `Brewfile.local` if present, then `Brewfile.keep` if non-empty
- `borders`/`sketchybar` configs are stowed, but the tools are intentionally NOT declared in any tracked Brewfile — they're used only occasionally and get installed per-machine via `Brewfile.local` (gitignored) where wanted. Don't "fix" this apparent drift by adding them to `Brewfile.home` (forces install everywhere) or removing their stow packages (drops the shared config); their `REQUIRED_DIRECTORIES` entries stay put
- `reenv` is a thin wrapper around `mise install`, driven by one file: `mise/.config/mise/config.toml` (pinned Ruby + Node versions, plus CLI tools/language servers via mise's `gem:`/`npm:` backends). Only add `gem:`/`npm:` entries for tools Homebrew has no formula for — `tailwindcss-language-server` has one and belongs in `Brewfile.home`, `@olrtg/emmet-language-server` doesn't and belongs here as `npm:@olrtg/emmet-language-server`. `reenv`'s plan step is `mise install --dry-run`; mise decides what's already installed, so there's no bespoke diffing logic to maintain
- `Brewfile.keep` (gitignored, loaded last) is the keep-list: the casks and mas apps that are installed but not declared in any tracked Brewfile. A bare `repack` rebuilds it before bundling, so `brew bundle --zap` won't uninstall things you installed by hand. It is recomputed against the tracked Brewfiles only — promote keepers into `Brewfile.home`/`Brewfile.work` and they drop off the list. To remove an app: delete its line and run `repack --prune`, which uses the file exactly as it stands and removes anything not declared and not on it. `--install-only` skips the rebuild entirely (it removes nothing, so the list is irrelevant) and is the way through when the brew probe is broken. The two flags are mutually exclusive. It was called `Brewfile.cache` until it was renamed; `repack` carries a legacy file over on first run. Every Brewfile uses double quotes, matching what `repack` generates, so promoting an entry is a straight copy-paste. Don't switch them to single quotes: an app name containing an apostrophe is a Ruby syntax error single-quoted, and since the keep-list is loaded into the bundle, one such app would make `brew bundle` reject the lot
- Homebrew's tap-trust file (`~/.homebrew/trust.json`) is NOT tracked or stowed — brew owns it as a real local file, and `brew bundle` manages its contents *declaratively* from the Brewfiles. Tapped packages carry a `trusted: true` option (the repo's entries — `nikitabobko/tap/aerospace`, `felixkratz/formulae/sketchybar`, `felixkratz/formulae/borders` — all live in `Brewfile.local`, alongside each other since they're the tiling-WM set); on install `brew bundle` trusts those before tapping (so the load is allowed), and on cleanup it calls `Trust.replace!` to rewrite the store so it *exactly* mirrors the declared `trusted:` entries. So there is NO manual `brew trust` plumbing in `repack.sh` — and you must NOT add any: a stray `brew trust <tap>` (or trusting a package not declared `trusted:` in the Brewfile) is silently wiped by the next `brew bundle ... --force-cleanup`, because `replace!` overwrites the whole store from the Brewfile. (brew also UNLINKS the file entirely when the store goes empty — `write_trust_store` → `unlink` — which, plus symlink resolution that would delete the tracked repo file, is why it's never stowed.) To trust a new tapped package: reference it fully-qualified with `, trusted: true` in the right Brewfile (keep its `tap` line, which is what tells `brew bundle` to tap it) and re-run `repack`.
- `restow` pre-creates each app's *main* config dir (the `REQUIRED_DIRECTORIES` list in `restow.sh`: `~/.config/nvim`, `~/.config/git`, …) so stow links files into a real directory instead of tree-folding the whole dir into one symlink. Stow still folds anything *nested* below them (`nvim/lua`, `btop/themes`, `.claude/skills`), which is wanted. The point of the real top dir: tools' own scratch/state files (lock files, machine-specific overrides like git's `config.local`, `lazy-lock.json`) stay local instead of leaking into the repo. When a new package introduces an app dir, add it to `REQUIRED_DIRECTORIES` or that dir will fold.

## Commits

Use `/commit`. Only commit when explicitly asked. Order commits as a logical narrative (foundation before features), not grouped by type of change.

A `PreToolUse` hook (`.claude/hooks/check-doc-drift.sh`, wired up in `.claude/settings.json`) blocks any `git commit` that removes a shell function or deletes a file whose name is still referenced in a tracked file. Both live in the repo's own `.claude/` — project scope, NOT the stowed `claude/` package that becomes `~/.claude`: this check is specific to this repo and has no business firing in every other project. This is enforcement, not a reminder — the harness runs it, so it cannot be skipped. When a mention is deliberate (a migration note naming an old filename, say), put `doc-drift-ok` on that line and the check ignores it. It searches tracked files only, so scratch files never trigger it, and it matches whole words, so deleting `dot.sh` doesn't trip on `redot.sh`. Renames are not deletions — git reports them as `R`, so moving a file doesn't fire it.

## Architecture (`bin/`)

Each script stands alone and is the front door to its own job: `repack.sh`
(packages), `restow.sh` (symlinks), `reenv.sh` (runtimes). `redot.sh` is the
light orchestration on top — pull, then run those three in order (reenv needs
`mise`, which repack installs). `bootstrap.sh` handles a new machine and hands
over to `redot.sh`. The zsh functions in `sh/.zfunctions.sh` are thin wrappers
onto the scripts, so flags flow straight through.

There is deliberately no wrapper command and no TUI: a `dot`/`gum` front door
existed and was removed, because behaviour had started to accumulate in it that
the scripts could not do themselves. Nothing may live only in a wrapper.

One sourced library (no top-level side effects):
- `bin/lib/common.sh` — the plain output/prompt helpers (`print_*`, `confirm`,
  `choose_multi`) plus shared data: `detect_environment`, `intent_brewfiles`,
  `compute_untracked`, `stow_packages_list`.
  This is the single home for the brew intent/cache logic — don't redefine it in an
  engine. `compute_untracked` returns non-zero and echoes nothing when its brew/mas
  probes fail; callers MUST check that status, because the cache it feeds is what
  shields undeclared apps from `brew bundle --zap` — treating a failed probe as
  "nothing untracked" deletes the shield and uninstalls the lot. Never consume it
  via `< <(…)`, which discards the status.

`bootstrap.sh` sources NOTHING — it runs from `curl` before the repo exists, so
it carries its own copies of the handful of helpers it needs. That duplication
(`ensure_homebrew`, `confirm_full_install`) is deliberate; don't merge it away.

`confirm` asks on `/dev/tty`, never on stdin: these scripts can be reached
through `curl | bash`, where stdin is the script text itself and a read would
swallow it as the answer. **Unattended runs are explicitly unsupported** — every
script calls `require_terminal` first and refuses without one, `-y` included:
it still needs a real terminal, it just skips the per-plan `y/N` reads on it.

`redot -y` auto-confirms every plan (`repack`, `restow`, `reenv` in turn) by
exporting `DOTFILES_ASSUME_YES=true`, which `confirm` in `common.sh` checks
before it ever touches `/dev/tty`. This is not a "`--yes`" flag on `repack`,
`restow`, or `reenv` themselves — they still take no such option, and still
reject one if passed directly. It's safe specifically because a bare `repack`
rebuilds `Brewfile.keep` from installed-by-hand apps *before* it zaps, so `-y`
on the default flow never removes anything undeclared and untracked; `--prune`
is already the explicit, typed request to remove what's on the keep-list, with
or without `-y`.

A script invoked as `if ! name "$@"` runs with errexit *disabled* for its entire
body — bash ignores `set -e` inside a condition — so every step must fail
explicitly (`cmd || { print_failure "…"; return 1; }`). A bare
`cmd || print_failure "…"` prints in red and then carries straight on.

Plan-then-confirm convention: every script prints what it would do and asks
before applying. That gate is the safety rail for `brew bundle --zap`, so it
lives in the script, never in a caller. Keep the `plan_*` functions strictly
side-effect-free (no keep-list writes, no symlinks) — they run before consent.
There is no `--plan`: to preview, run it and answer no (or see `redot -y`
above for skipping the answering, not the previewing).

Homebrew has its own separate "ask mode" (`Do you want to proceed with the
upgrade? [y/n]`, gated by `$HOMEBREW_NO_ASK`) that fires from `brew upgrade`
and `brew bundle` themselves, after our own confirm already succeeded.
`repack.sh`'s `update_homebrew`/`bundle_homebrew` set `HOMEBREW_NO_ASK=1` on
those calls unconditionally (not just under `-y`) because it's genuinely
redundant every time, not an `-y`-only concern: `plan_repack` already listed
the exact packages and got a yes from `confirm` moments earlier.

`restow` and `reenv` take no options at all and reject any argument. `repack`
takes exactly two, `--install-only` and `--prune`, and rejects anything else —
an unrecognised flag must never be silently ignored by a script that removes
software.

## Shell Scripts (`bin/`)

All scripts must use this header:

```bash
#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, and pipeline failures
IFS=$'\n\t'       # Stricter word splitting

# Trap Ctrl-C (SIGINT) and exit gracefully
trap 'echo -e "\nInterrupted. Exiting..."; exit 130' INT

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
