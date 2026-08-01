# CLAUDE.md

## Repository

Personal macOS dotfiles managed with GNU Stow. All scripts require macOS and use `set -euo pipefail`.

Non-obvious facts:
- `kanata/` is NOT stowed — requires manual setup (see `kanata/kanata.md`)
- Brewfile loading is environment-aware: always `Brewfile`, then `Brewfile.home` or `Brewfile.work` based on `whoami`, then `Brewfile.local` if present, then `Brewfile.keep` if non-empty
- `borders`/`sketchybar` configs are stowed, but the tools are intentionally NOT declared in any tracked Brewfile — they're used only occasionally and get installed per-machine via `Brewfile.local` (gitignored) where wanted. Don't "fix" this apparent drift by adding them to `Brewfile.home` (forces install everywhere) or removing their stow packages (drops the shared config); their `REQUIRED_DIRECTORIES` entries stay put
- `reenv` installs two kinds of language tooling: gems as isolated `rv tool`s (`ruby/.default-gems`) and global npm packages (`node/.default-npm`). `.default-npm` is only for things Homebrew has no formula for — `tailwindcss-language-server` has one and belongs in `Brewfile.home`, `@olrtg/emmet-language-server` doesn't and belongs in `.default-npm`. Its `rv` and `npm` passes are gated separately so a machine missing one still gets the other
- `Brewfile.keep` (gitignored, loaded last) is the keep-list: the casks and mas apps that are installed but not declared in any tracked Brewfile. A bare `repack` rebuilds it before bundling, so `brew bundle --zap` won't uninstall things you installed by hand. It is recomputed against the tracked Brewfiles only — promote keepers into `Brewfile.home`/`Brewfile.work` and they drop off the list. To remove an app: delete its line and run `repack --prune`, which uses the file exactly as it stands and removes anything not declared and not on it. `--install-only` skips the rebuild entirely (it removes nothing, so the list is irrelevant) and is the way through when the brew probe is broken. The two flags are mutually exclusive. It was called `Brewfile.cache` until it was renamed; `repack` carries a legacy file over on first run. Generated entries are double-quoted (`mas "Xcode", id: …`) while the tracked Brewfiles are single-quoted by convention — re-quote when promoting, EXCEPT for names containing an apostrophe, which are a Ruby syntax error single-quoted and must stay double-quoted. Don't "fix" the generator to emit single quotes: the first such app would make the keep-list an invalid Brewfile, and since it is loaded into the bundle, `repack` would refuse to run at all
- Homebrew's tap-trust file (`~/.homebrew/trust.json`) is NOT tracked or stowed — brew owns it as a real local file, and `brew bundle` manages its contents *declaratively* from the Brewfiles. Tapped packages carry a `trusted: true` option (the repo's one such entry is `cask 'nikitabobko/tap/aerospace', trusted: true` in `Brewfile.home`); on install `brew bundle` trusts those before tapping (so the load is allowed), and on cleanup it calls `Trust.replace!` to rewrite the store so it *exactly* mirrors the declared `trusted:` entries. So there is NO manual `brew trust` plumbing in `repack.sh` — and you must NOT add any: a stray `brew trust <tap>` (or trusting a package not declared `trusted:` in the Brewfile) is silently wiped by the next `brew bundle ... --force-cleanup`, because `replace!` overwrites the whole store from the Brewfile. (brew also UNLINKS the file entirely when the store goes empty — `write_trust_store` → `unlink` — which, plus symlink resolution that would delete the tracked repo file, is why it's never stowed.) To trust a new tapped package: reference it fully-qualified with `, trusted: true` in the right Brewfile (keep its `tap` line, which is what tells `brew bundle` to tap it) and re-run `repack`.
- `restow` pre-creates each app's *main* config dir (the `REQUIRED_DIRECTORIES` list in `restow.sh`: `~/.config/nvim`, `~/.config/git`, …) so stow links files into a real directory instead of tree-folding the whole dir into one symlink. Stow still folds anything *nested* below them (`nvim/lua`, `btop/themes`, `.claude/skills`), which is wanted. The point of the real top dir: tools' own scratch/state files (lock files, machine-specific overrides like git's `config.local`, `lazy-lock.json`) stay local instead of leaking into the repo. When a new package introduces an app dir, add it to `REQUIRED_DIRECTORIES` or that dir will fold.

## Commits

Use `/commit`. Only commit when explicitly asked. Order commits as a logical narrative (foundation before features), not grouped by type of change.

## Architecture (`bin/`)

Each script stands alone and is the front door to its own job: `repack.sh`
(packages), `restow.sh` (symlinks), `reenv.sh` (runtimes). `redot.sh` is the
light orchestration on top — pull, then run those three in order (reenv needs
`rv`, which repack installs). `bootstrap.sh` handles a new machine and hands
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
script calls `require_terminal` first and refuses without one. There is no
"assume yes" fallback and none should be added: no terminal means nobody
consented, and the thing being consented to is `brew bundle --zap`.

A script invoked as `if ! name "$@"` runs with errexit *disabled* for its entire
body — bash ignores `set -e` inside a condition — so every step must fail
explicitly (`cmd || { print_failure "…"; return 1; }`). A bare
`cmd || print_failure "…"` prints in red and then carries straight on.

Plan-then-confirm convention: every script prints what it would do and asks
before applying. That gate is the safety rail for `brew bundle --zap`, so it
lives in the script, never in a caller. Keep the `plan_*` functions strictly
side-effect-free (no keep-list writes, no symlinks) — they run before consent.
There is no `--plan` or `--yes`: to preview, run it and answer no.

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
