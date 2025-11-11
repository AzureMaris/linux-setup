return {
   "olimorris/onedarkpro.nvim",
   priority = 1000,

   opts = {
      styles = {
         comments = "italic",
      },

      colors = {
         bg = "#282C34",
         fg = "#ABB2BF",
         cyan = "#56b6c2",
         cursorline = "#2C313C",
      },

      options = {
         cursorline = true,
      },

      highlights = {
         -- diagnostics
         --
         DiagnosticUnderlineError = {
            undercurl = true,
            sp = "${red}",
            fg = "NONE",
         },

         DiagnosticUnderlineWarn = {
            undercurl = true,
            sp = "${yellow}",
            fg = "NONE",
         },

         DiagnosticUnderlineInfo = {
            undercurl = true,
            sp = "${green}", --
            fg = "NONE",
         },

         DiagnosticVirtualTextWarn = {
            bg = "#5d4200", --
            fg = "#ffdea4", --
         },

         DiagnosticVirtualTextError = {
            bg = "#733330",
            fg = "#ffdad7",
         },

         DiagnosticVirtualTextInfo = {
            bg = "#2f4f1b",
            fg = "#c7eea9",
         },

         -- rust (treesitter)
         --
         -- ex: (), {}
         ["@punctuation.bracket.rust"] = {},
         ["@odp.punctuation_token_bracket.rust"] = {},
         -- ex: pub static ref SERVER_ADDRESS
         ["@constant.rust"] = { fg = "${red}" },
         -- ex: _
         ["@character.special.rust"] = { fg = "${red}" },

         -- rust (lsp)
         --
         -- ex: unwrap()
         ["@function.builtin"] = {},
         -- ex: self
         ["@lsp.type.selfKeyword.rust"] = { fg = "${purple}" },
         -- ex: *, =, + ...
         ["@operator"] = {},
         -- ex: #[derive()]
         ["@lsp.type.decorator.rust"] = {},
         -- ex: StatusCode::Ok <--
         ["@lsp.type.const.rust"] = { fg = "${orange}" },
         -- ex: Self
         ["@lsp.type.selfTypeKeyword.rust"] = { fg = "${purple}" },

         -- html (treesitter)
         --
         htmlArg = { fg = "${orange}" },

         -- css (treesitter)
         --
         cssUnitDecorators = { fg = "${red}" },
         cssAtRuleLogical = { fg = "${cyan}" },
         cssBraces = { fg = "${orange}" },

         -- fish (treesitter)
         --
         fishForVariable = { fg = "${orange}" },
         fishOption = { fg = "${yellow}" },
         fishEscapedNl = { fg = "${purple}" },
         fishVariable = { fg = "${red}" },

         -- typescript (treesitter)
         --
         typescriptIdentifierName = { fg = "${red}" },
         typescriptBlock = { fg = "${yellow}" },
         special = { fg = "${purple}" },
         ["@namespace"] = { fg = "${yellow}" },
         ["@parameter"] = { fg = "${red}" },
         ["@constructor"] = { fg = "${purple}" },
         ["@constant.builtin"] = { fg = "${yellow}" },
         ["@constant"] = { fg = "${yellow}" },

         -- typescript (lsp)
         --
         ["@lsp.typemod.function.readonly.typescript"] = { fg = "${blue}" },
         ["@lsp.typemod.parameter.declaration.typescript"] = { fg = "${red}" },
      },
   },

   config = function(_, opts)
      require("onedarkpro").setup(opts)
      vim.cmd([[colorscheme onedark]])
   end,
}
