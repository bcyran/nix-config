return {
  -- Add Dart & related treesitter syntaxes
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "dart",
          "yaml",
        })
      end
    end,
  },

  -- LSP and more
  {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    opts = {
      dev_log = {
        enabled = true,
        notify_errors = true,
        open_cmd = "tabedit",
      },
      widget_guides = {
        enabled = true,
      },
      lsp = {
        settings = {
          lineLength = 100,
        },
      },
    },
  },
}
