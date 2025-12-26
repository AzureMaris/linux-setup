return {
   "nvim-treesitter/nvim-treesitter",

   build = function()
      require("nvim-treesitter.install").update({
         with_sync = true,
      })()
   end,

   --- @type TSConfig
   opts = {
      sync_install = false,
      ignore_install = {},
      modules = {},
      auto_install = true,

      ensure_installed = {
         "vim",
         "regex",

         "lua",
      },

      highlight = {
         enable = true,
      },
   },

   config = function(_, opts)
      local treesitter = require("nvim-treesitter.configs")
      treesitter.setup(opts)
   end,
}
