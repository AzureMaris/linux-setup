return {
   "folke/noice.nvim",
   event = "VeryLazy",

   --- @type NoiceConfig
   opts = {
      lsp = {
         override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
         },
      },

      presets = {
         bottom_search = false,
         command_palette = true,
         long_message_to_split = true,
         inc_rename = true,
         lsp_doc_border = true,
      },
   },

   config = function(_, opts)
      require("noice").setup(opts)
   end,

   dependencies = {
      { "MunifTanjim/nui.nvim" },

      {
         "rcarriga/nvim-notify",

         --- @type notify.Config
         opts = {
            top_down = false,
            merge_duplicates = true,
         },

         config = function(_, opts)
            require("notify").setup(opts)
         end,
      },
   },
}
