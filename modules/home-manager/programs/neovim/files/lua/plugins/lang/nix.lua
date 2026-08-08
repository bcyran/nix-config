return {
  -- Add Nix treesitter syntax
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "nix",
        })
      end
    end,
  },

  -- Setup LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {},
      },
    },
  },

  -- Setup formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = {
          "alejandra",
        },
      },
    },
  },

  -- Setup linters
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.nix = { "statix" }
      return opts
    end,
  },
}
