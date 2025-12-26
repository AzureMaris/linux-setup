return {
   "mrcjkb/rustaceanvim",
   version = "^6",
   ft = { "rust" },

   init = function()
      vim.g.rust_recommended_style = false
   end,
}
