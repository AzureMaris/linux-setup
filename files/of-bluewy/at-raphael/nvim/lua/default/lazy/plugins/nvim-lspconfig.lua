return {
   "neovim/nvim-lspconfig",
   lazy = false,

   config = function()
      local mason_lspconfig = require("mason-lspconfig")

      local custom_lsp_configs = {
         -- { "rust", {} }, -- i believe disabling it below should be enough
      }

      for _, custom_lsp_config in ipairs(custom_lsp_configs) do
         vim.lsp.config(custom_lsp_config)
      end

      local my_lsp_names_to_enable = { "nushell" }
      local my_lsp_names_to_disable = { "rust", "typescript" }
      local mason_lsp_names_to_enable = mason_lspconfig.get_installed_servers()

      local lsp_names_to_enable = vim.list_extend(my_lsp_names_to_enable, mason_lsp_names_to_enable)

      for _, lsp_name_to_enable in ipairs(lsp_names_to_enable) do
         if vim.list_contains(my_lsp_names_to_disable, lsp_name_to_enable) then
            vim.lsp.enable(lsp_name_to_enable, false)
         else
            vim.lsp.enable(lsp_name_to_enable, true)
         end
      end
   end,
}
