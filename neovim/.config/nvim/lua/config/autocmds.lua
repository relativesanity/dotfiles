-- Turn the empty startup buffer into a named throwaway scratch buffer, so a
-- dashboard-less launch isn't a "[No Name]" file-buffer that nags on quit.
-- Only fires for `nvim` with no file args; wiped the moment you open a real file.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("startup_scratch", { clear = true }),
  callback = function()
    if vim.fn.argc() ~= 0 then return end
    local buf = vim.api.nvim_get_current_buf()
    local pristine = vim.api.nvim_buf_get_name(buf) == ""
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_line_count(buf) == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
    if not pristine then return end

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "scratch"
    vim.api.nvim_buf_set_name(buf, "scratch")
  end,
})
