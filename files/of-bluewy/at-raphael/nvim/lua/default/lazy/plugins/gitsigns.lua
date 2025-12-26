return {
   "lewis6991/gitsigns.nvim",
   event = "VeryLazy",
   opts = {},

   config = function(_, opts)
      local gitsigns = require("gitsigns")
      gitsigns.setup(opts)

      -- mappings
      --
      vim.keymap.set("n", "<leader>nh", function()
         if vim.wo.diff then
            return "[c"
         end
         vim.schedule(function()
            gitsigns.nav_hunk("next", nil)
         end)
         return "<Ignore>"
      end, { noremap = true, silent = true, expr = true, desc = "next hunk" })

      vim.keymap.set("n", "<leader>rh", gitsigns.reset_hunk, { noremap = true, silent = true, desc = "reset hunk" })
      vim.keymap.set("n", "<leader>ph", gitsigns.preview_hunk, { noremap = true, silent = true, desc = "preview hunk" })

      vim.keymap.set(
         "n",
         "<leader>phi",
         gitsigns.preview_hunk_inline,
         { noremap = true, silent = true, desc = "preview hunk inline" }
      )
   end,
}
