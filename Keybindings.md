# Keybindings

Design notes for the Meh/Hyper keybinding scheme shared across AeroSpace,
Hammerspoon, tmux, Neovim, and (via `dotfiles-omarchy`) Hyprland. Linked
from `CLAUDE.md` rather than inlined in each config file, since this is
background for whoever's editing the bindings, not something the bindings
themselves need to say every time.

## Hardware

Both Macs and the Linux boxes' NuPhy/internal keyboards run the same
kanata config (`kanata/.config/kanata/kanata.kbd`, mirrored at
`dotfiles-omarchy/kanata/etc/kanata.kbd`). No standard modifier row exists
on this hardware — every modifier comes from a home-row tap-hold or a
thumb key:

- **Meh** (ctrl+alt+shift) sources from the right thumb *and* Capslock
  (hold; tap still gives Escape) — two independent routes.
- **Hyper** (ctrl+alt+shift+cmd/super) sources from the left thumb and `g`
  (hold) only — one route, always left-handed.
- Bare Ctrl/Alt/Shift/Cmd come from `a`/`s`/`d`/`f` (left hand) and
  `j`/`k`/`l`/`;` (right hand) tap-holds.
- Arrow keys come from a kanata layer (hold Space, press `hjkl`) — kept
  only for general arrow-key access to other apps; nothing in this scheme
  depends on it, since every WM/tmux/Neovim command here takes a direction
  as a config-level argument (`'focus left'`, `select-pane -L`, `<C-w>h`),
  not a literal arrow keystroke.

Your ZSA Voyager is a separate device (independently-reachable thumb keys
on each side, no shared spacebar) with its own QMK/Oryx firmware, not
covered by any of this — findings here about which keys are reliable are
specific to the NuPhy/internal keyboards.

## The meh/hyper split

Meh = **selection** (looking at/switching to something, layout
unchanged). Hyper = **action** (changes the layout). That's the default
rule — but a physical one overrides it for common operations: Meh's
dual-route means it's one-handed with *any* target key (right thumb for
right-hand keys, Capslock for left-hand keys), while Hyper is only
one-handed with left-hand keys (no right-hand route exists). So `move`
(an action) stays on Meh anyway — it's common enough that one-handed
operation matters more than the label.

| Action | Binding | Notes |
|---|---|---|
| Focus direction | `meh+h/j/k/l` | |
| Move window direction | `meh+y/u/i/o` | Action, kept on Meh for one-handedness |
| Per-axis resize | `hyper+a/s/d/f` | Left-hand keys — Hyper has no right-hand route |
| Workspace jump | `meh+1..5` | |
| Move+follow to workspace | `hyper+1..5` | |
| Workspace prev/next | `meh+[` / `meh+]` | |
| Layout/tiling-type toggle | `meh+'` | Platform-specific action behind the key |
| Fullscreen | `meh+f` | |
| Pop out / single-window | `meh+Backspace` (Hammerspoon) | mac floats; Hyprland stays tiled with aspect-ratio coercion |

App tier (tmux, Neovim) can't mirror the two-tier split — `Ctrl+Alt+Shift`
is Meh's exact bitmask, already claimed globally by the WM, so app-level
bindings only get one free modifier: `Ctrl+Alt`.

| Action | Binding |
|---|---|
| Pane/split focus, tmux-boundary-aware | `ctrl-alt+h/j/k/l` |
| tmux pane resize | `prefix` then `H`/`J`/`K`/`L` (see below for why) |
| Neovim split resize | plain vim core `<C-w>+/-/</>` (not tmux-aware) |
| tmux window jump | `alt+1..9` |
| tmux window prev/next | `alt+h` / `alt+l` |

## Why tmux/Neovim resize ended up behind the prefix, not a chord

`Ctrl+Alt+h/j/k/l` (focus) works reliably. Resize went through four
attempts trying to find a second no-prefix chord, and ran out of options:

1. **`ctrl-alt+y/u/i/o`** — `i` arrived indistinguishable from Tab. Ctrl+I
   and Tab are both ASCII `0x09`; universal terminal-encoding fact,
   independent of keyboard.
2. **`ctrl-alt+a/s/d/f`** (mirroring the WM's `hyper+asdf`) — `f` arrived
   as bare Ctrl+F (visible as `^F` printed, or Neovim's native page-down
   firing) despite Alt being held. Root cause never isolated.
3. **`ctrl-shift+h/j/k/l`** — reused already-proven letters, different
   modifier. Also collapsed to bare Ctrl+letter. This one *is* explained:
   classical terminal Ctrl-masking derives the control byte from the
   letter's uppercase form, so Ctrl+H and Ctrl+Shift+H produce the
   identical byte in most encodings — Shift's only effect on a letter is
   case, and Ctrl-masking discards case. This isn't a quirky-letter
   problem, it's true for every letter.
4. **`alt-shift+h/j/k/l`** — ruled out before even testing letter-by-letter:
   Option+Shift is one of macOS's own accented-character/dead-key compose
   tiers, apparently at a layer `macos-option-as-alt` doesn't override.
5. **`ctrl-super+h/j/k/l`** — tmux's `bind-key` syntax only supports three
   modifier prefixes at all: `C-` (Ctrl), `S-` (Shift), `M-` (Alt). There
   is no Cmd/Super prefix in tmux's key-binding language, full stop —
   this was never implementable regardless of whether Ghostty would
   forward a Cmd-modified keystroke (which is also doubtful; macOS
   conventionally reserves Cmd for app-level shortcuts).

That's the *entire* combinatorial space tmux can express for a second
modifier (`C`, `S`, `M` give exactly three 2-way combinations, and the
third, `C-S-M-`, is Meh's own bitmask). With no-prefix options exhausted,
resize went back behind the tmux prefix — `prefix` then a literal
character has no modifier-encoding involved at all, so none of the above
failure modes apply. Neovim's own split resize just uses vim's built-in
`<C-w>+/-/</>` rather than inventing another risky chord.

If resize ever breaks again, don't reach for another new modifier blind —
get a raw byte dump first (`cat -v` in a plain, non-tmux terminal, compare
the failing chord against a working one) before guessing, and restart the
tmux server (not just reload) before concluding anything, since a running
server doesn't clear bindings a `source-file` no longer mentions.

## smart-splits.nvim

`neovim/.config/nvim/lua/plugins/smart-splits.lua` gives Neovim
tmux-boundary-aware split *focus* — `ctrl-alt+hjkl` works whether the
cursor is inside a Neovim split or needs to cross into an adjacent tmux
pane (resize does not cross the boundary; see above). Mechanism: the
plugin sets a pane-local tmux variable, `@pane-is-vim`, while it's loaded
in that pane; `tmux.conf`'s focus bindings check that variable and either
forward the raw keystroke into the running Neovim (`send-keys`) or run
tmux's own pane command directly, depending on what's actually running
there. The plugin is intentionally not lazy-loaded, since the tmux
integration depends on `@pane-is-vim` being set as early as possible.
This replaces LazyVim's default `<C-h/j/k/l>`.

## Hyprland (`dotfiles-omarchy`)

`hypr/.config/hypr/bindings.lua` adds the same Meh/Hyper vocabulary,
unbinding Omarchy's Super-based defaults only where the exact key string
was known with confidence (arrows, `SUPER+CTRL+F`, `SUPER+CTRL+BACKSPACE`).
Workspace-digit defaults reference the number row by raw scancode
(`code:10`..`code:14`) in Omarchy's own source, not the literal digit —
reproducing that wasn't worth the risk of a silently-wrong unbind, so
those are left additive (different modifier anyway, no real collision).
Resize and the layout toggle have no known Omarchy `hl.dsp` wrapper, so
they shell out to `hyprctl dispatch` directly instead of guessing at an
unconfirmed Lua API. None of this has been tested against a running
Hyprland instance — it was written and syntax-checked from macOS only.
