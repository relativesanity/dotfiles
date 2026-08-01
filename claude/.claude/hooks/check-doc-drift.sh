#!/usr/bin/env bash

set -uo pipefail # No -e: this must never abort mid-check and block a commit by accident
IFS=$'\n\t'

# Doc-drift check - PreToolUse hook for `git commit`
# When a commit removes a shell function or deletes a file, the name usually
# survives somewhere else — a Readme bullet, a comment in a stowed config, a
# setup doc in a subdirectory. Those references outlive the thing they describe
# and nothing else catches them.
#
# Reads the hook payload on stdin, does nothing unless the command is a commit,
# and exits 2 (blocking, with the reason fed back to Claude) when a removed name
# is still referenced in the tree.
#
# Escape hatch: put `doc-drift-ok` on the referencing line — for deliberate
# mentions like a migration note naming the old filename.

payload="$(cat)"
command="$(printf '%s' "$payload" | /usr/bin/env jq -r '.tool_input.command // empty' 2>/dev/null)"

# Only commits. Anything else, including `git commit --help`, is none of our business.
[[ "$command" == *"git commit"* ]] || exit 0

root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[[ -n "$root" ]] || exit 0
cd "$root" || exit 0

staged="$(git diff --cached 2>/dev/null)" || exit 0
[[ -n "$staged" ]] || exit 0

names=()

# Shell functions whose definition this commit removes. Only definitions —
# a removed *call* is not evidence the function is gone.
while IFS= read -r name; do
  [[ -n "$name" ]] && names+=("$name")
done < <(printf '%s' "$staged" | sed -nE 's/^-[[:space:]]*([A-Za-z_][A-Za-z0-9_-]*)\(\)[[:space:]]*\{.*/\1/p' | sort -u)

# Files this commit deletes, matched later by basename.
while IFS= read -r path; do
  [[ -n "$path" ]] && names+=("$(basename "$path")")
done < <(git diff --cached --name-only --diff-filter=D 2>/dev/null | sort -u)

((${#names[@]})) || exit 0

# A name only counts as referenced when it is not part of a longer word —
# deleting dot.sh must not trip on redot.sh, and write_cache must not trip on
# write_cache_entries.
#
# `git grep`, not `grep -r`: it searches tracked files only. Scratch files,
# build output and editor droppings are not documentation, and letting them
# trigger a block is how a check earns a reputation for crying wolf.
findings=""
for name in "${names[@]}"; do
  hits="$(git grep -nE "(^|[^A-Za-z0-9_./-])${name//./\\.}([^A-Za-z0-9_-]|$)" 2>/dev/null |
    grep -v 'doc-drift-ok' || true)"
  [[ -n "$hits" ]] && findings+="  $name is still referenced:"$'\n'"$(sed 's/^/    /' <<<"$hits")"$'\n'
done

[[ -n "$findings" ]] || exit 0

cat >&2 <<EOF
Stale references: this commit removes things that are still named elsewhere.

$findings
Update those references, or add \`doc-drift-ok\` to a line whose mention is
deliberate (a migration note naming an old filename, say), then commit again.
EOF
exit 2
