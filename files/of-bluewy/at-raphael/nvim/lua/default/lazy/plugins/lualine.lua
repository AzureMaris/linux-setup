return {
   "nvim-lualine/lualine.nvim",

   opts = {
      options = {
         theme = "onedark",
      },
   },

   config = function(_, opts)
      require("lualine").setup(opts)
   end,

   dependencies = { "nvim-tree/nvim-web-devicons" },
}
