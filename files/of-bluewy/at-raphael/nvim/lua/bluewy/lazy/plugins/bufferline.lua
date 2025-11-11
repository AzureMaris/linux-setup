return {
   "akinsho/bufferline.nvim",

   --- @type bufferline.UserConfig
   opts = {
      options = {
         separator_style = "slant",
      },
   },

   config = function(_, opts)
      local bufferline = require("bufferline")
      bufferline.setup(opts)

      -- mappings
      --
      vim.keymap.set("n", "<leader>i", function()
         bufferline.cycle(1)
      end, { noremap = true, silent = true, desc = "next buffer" })

      vim.keymap.set("n", "<leader>n", function()
         bufferline.cycle(-1)
      end, { noremap = true, silent = true, desc = "previous buffer" })

      vim.keymap.set("n", "<leader><leader>i", function()
         bufferline.move(1)
      end, { noremap = true, silent = true, desc = "move buffer to the right" })

      vim.keymap.set("n", "<leader><leader>n", function()
         bufferline.move(-1)
      end, { noremap = true, silent = true, desc = "move buffer to the left" })

      vim.keymap.set("n", "<leader>x", function()
         bufferline.close_with_pick()
      end, { noremap = true, silent = true, desc = "close buffer" })
   end,

   dependencies = { "nvim-tree/nvim-web-devicons" },
}
