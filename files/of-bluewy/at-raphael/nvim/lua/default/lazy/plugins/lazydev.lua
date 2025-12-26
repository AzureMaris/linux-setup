return {
   {
      "folke/lazydev.nvim",
      ft = "lua",

      --- @type lazydev.Config
      opts = {
         library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
         },
      },

      config = function(_, opts)
         require("lazydev").setup(opts)
      end,
   },

   -- { -- optional cmp completion source for require statements and module annotations
   --    "hrsh7th/nvim-cmp",
   --
   --    opts = function(_, opts)
   --       opts.sources = opts.sources or {}
   --       table.insert(opts.sources, {
   --          name = "lazydev",
   --          group_index = 0, -- set group index to 0 to skip loading LuaLS completions
   --       })
   --    end,
   -- },
}
