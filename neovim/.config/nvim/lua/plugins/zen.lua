return {
  {
    "folke/snacks.nvim",
    opts = {
      zen = {
        -- Zen turns on Snacks.dim by default, which fades everything outside
        -- the current scope. Keep the whole buffer at full contrast.
        toggles = { dim = false },
      },
      styles = {
        zen = {
          -- 80 columns of text: the window width includes the number and sign
          -- columns, so add the gutter back on. Snacks clamps the result to
          -- the screen, so a narrower terminal just wraps at its own edge.
          width = function()
            return 80 + vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
          end,
        },
      },
    },
  },
}
