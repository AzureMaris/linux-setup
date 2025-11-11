return {
   "williamboman/mason.nvim",
   lazy = false,

   --- @type MasonSettings
   opts = {},

   config = function(_, opts)
      require("mason").setup(opts)
   end,
}
