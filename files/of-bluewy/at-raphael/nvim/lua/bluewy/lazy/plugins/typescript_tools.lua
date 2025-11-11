return {
   "pmizio/typescript-tools.nvim",
   opts = {},

   config = function(_, opts)
      require("typescript-tools").setup(opts)
   end,

   dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "neovim/nvim-lspconfig" },
   },
}
