return {
  -- Add Python & related treesitter syntaxes
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "python",
          "rst",
          "toml",
        })
      end
    end,
  },

  -- Setup LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {
          settings = {
            ty = {},
          },
        },
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
          keys = {
            {
              "<leader>co",
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
            },
          },
        },
      },
    },
  },

  -- Formatting: Ruff formatter and import sorting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = {
          "ruff_format",
          "ruff_organize_imports",
          lsp_format = "never",
        },
      },
    },
  },

  -- Virutalenv selector
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    opts = {
      settings = {
        options = {
          enable_cached_venvs = true,
          notify_user_on_venv_activation = true,
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },
}
