return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = '(f)ind (f)iles' },
      { '<leader>fs', '<cmd>Telescope live_grep<CR>', desc = '(f)ind by (s)earch' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>', desc = '(f)ind open (b)uffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>', desc = '(f)ind in (h)elp' },
      { '<leader>fo', '<cmd>Telescope oldfiles<CR>', desc = '(f)ind in (o)ld files' },
      { '<leader>fc', '<cmd>Telescope commands<CR>', desc = '(f)ind (c)ommands' },
      { '<leader>fg', '<cmd>Telescope git_commits<CR>', desc = '(f)ind (g)it commits' },
    },
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    config = function()
      require('telescope').load_extension('fzf')
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
          }
        }
      }
      require("telescope").load_extension("ui-select")
    end
  }
}
