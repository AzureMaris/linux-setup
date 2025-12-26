return {
   "williamboman/mason-lspconfig.nvim",
   lazy = false,

   --- @type MasonLspconfigSettings
   opts = {
      ensure_installed = {
         "lua_ls",
      },

      automatic_installation = true,
   },

   config = function(_, opts)
      require("mason-lspconfig").setup(opts)
   end,
}
