return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
                                                                   
      ████ ██████           █████      ██     by LazyVim     
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
      },
    },
    picker = {
      sources = {
        explorer = {
          hidden = true, -- show hidden files
          ignored = true, -- show ignored files
        },
        files = {
          hidden = true, -- show hidden files
          ignored = true, -- show ignored files
        },
      },
    },
  },
}
