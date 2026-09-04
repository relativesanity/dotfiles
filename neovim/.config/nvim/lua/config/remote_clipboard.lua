-- Clipboard for sessions whose yanks may need to reach another machine:
-- every copy is emitted as OSC 52 (inside tmux this becomes a tmux buffer,
-- rebroadcast to every attached client, local or SSH). Paste prefers the
-- local macOS pasteboard when one is reachable, so content copied in other
-- apps remains pasteable; without one, paste is an OSC 52 query that tmux
-- (or the terminal) answers.
local M = {}

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

  if not (in_tmux or in_ssh) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local has_pasteboard = vim.fn.executable("pbcopy") == 1 and vim.fn.executable("pbpaste") == 1

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines)
      if has_pasteboard then
        vim.fn.system("pbcopy", lines)
      end

      if vim.g.remote_clipboard_osc52 ~= false then
        emit(lines)
      end
    end
  end

  local function paste(register)
    if not has_pasteboard then
      return osc52.paste(register)
    end

    return function()
      local lines = vim.fn.systemlist("pbpaste")
      return vim.v.shell_error == 0 and lines or {}
    end
  end

  vim.g.clipboard = {
    name = "RemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }
end

return M
