return {
   "saecki/crates.nvim",
   tag = "stable",
   --- @type crates.UserConfig
   opts = {},

   config = function(_, opts)
      require("crates").setup(opts)
   end,
}
