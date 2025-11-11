return {
   "folke/which-key.nvim",
   event = "VeryLazy",
   --- @type wk.Opts
   opts = {},

   config = function(_, opts)
      require("which-key").setup(opts)
   end,
}
