---
name: cowork-inspect
description: Read-only inspector for Claude Cowork / Claude Desktop local state on macOS — projects (Spaces), chats/sessions, and instruction files
---

# cowork-inspect

Report the current local state of Claude Cowork (the Claude Desktop "local agent mode" product) on macOS. **Read-only**: never create, edit, move, or delete anything here. These files are owned by the running Claude Desktop app.

## Important caveats

- The app **buffers state in memory and flushes to disk on a sync cycle or on quit**. For a reliable snapshot, note whether the app is running; if the user needs "final" state, suggest they quit Claude first, then re-run.
- These files are also **account-synced to claude.ai**. The local copies are a cache, not the source of truth.
- Treat all paths as **read-only**. If the user wants to delete chats/projects, point them at the in-app UI (chat history → "Delete Selected"; Spaces archive). Manual file removal is a fallback only, done with the app quit and explicit per-file confirmation — out of scope for this skill.

## Layout (macOS)

App data root: `~/Library/Application Support/Claude/`

Cowork working state lives under:
`~/Library/Application Support/Claude/local-agent-mode-sessions/<accountId>/<workspaceId>/`

Do **not** hardcode the UUIDs — discover the workspace dir dynamically (it's the one containing `spaces.json`). Within it:

- `spaces.json` — Projects/Spaces: array of `{id, name, folders[].path, instructions, createdAt, updatedAt}`. Empty `{"spaces":[]}` means no projects.
- `local_<uuid>.json` (+ matching `local_<uuid>/` dir) — one per chat/session. Each has `title`, `model`, `isArchived`, `userSelectedFolders`, `createdAt`, `lastActivityAt`.
- `memory/CLAUDE.md` — the **global Cowork instructions** (what the UI "global instructions" box writes).
- `cowork_settings.json` — enabled Cowork plugins + marketplaces.

Other relevant files:
- `~/Library/Application Support/Claude/claude_desktop_config.json` — `mcpServers`, `coworkUserFilesPath`, and `preferences` (trusted folders, shortcuts, toggles).

## Instructions

1. Check whether Claude Desktop is running: `pgrep -f Claude.app` (report it, since it affects snapshot freshness).
2. Resolve the workspace dir dynamically:
   `ws=$(dirname "$(find ~/Library/Application\ Support/Claude/local-agent-mode-sessions -maxdepth 3 -name spaces.json 2>/dev/null | head -1)")`
   If none found, report that Cowork has no local state yet and stop.
3. Report **Projects/Spaces** from `$ws/spaces.json`: for each, name, folder path(s), and instructions. Say "none" if empty.
4. Report **chats/sessions**: count `$ws/local_*.json`, and for each print date (`lastActivityAt`), archived flag, model, selected folder(s), and title. Sort by date. Note how many are archived.
5. Report **global instructions**: contents of `$ws/memory/CLAUDE.md` (or "empty/absent").
6. Optionally report **config**: the `preferences` block and `mcpServers` from `claude_desktop_config.json`.
7. Use `python3` to parse JSON for clean field extraction. Keep everything read-only — no `rm`, no writes.
