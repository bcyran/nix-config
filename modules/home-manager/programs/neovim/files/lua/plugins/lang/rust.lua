return {
  -- Ensure external deps are installed
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "rust-analyzer",
      })
    end,
  },

  -- Add Rust & related treesitter syntaxes
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "rust",
          "toml",
          "ron",
        })
      end
    end,
  },

  -- Rust LSP, linter and more
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust debuggables", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = true,
            check = {
              command = "clippy",
              extraArgs = {
                "--no-deps",
                "--",
                "-Dclippy::correctness",
                "-Wclippy::nursery",
                "-Aclippy::option_if_let_else",
                "-Wclippy::pedantic",
                "-Aclippy::module_name_repetitions",
                "-Wclippy::perf",
                "-Wclippy::suspicious",
                "-Wclippy::style",
              },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
        load_vscode_settings = true,
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("force", vim.g.rustaceanvim or {}, opts or {})
    end,
  },

  -- Integrate LSP with crates.nvim
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {},
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
      },
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
}
