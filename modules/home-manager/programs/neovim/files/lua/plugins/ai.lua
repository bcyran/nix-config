local settings = require("config.settings")

return {
  -- Base copilot plugin
  {
    "zbirenbaum/copilot.lua",
    enabled = settings.copilot_enabled,
    cmd = "Copilot",
    event = "InsertEnter",
    keys = {
      {
        "<leader>at",
        function()
          require("copilot.suggestion").toggle_auto_trigger()
        end,
        desc = "Toggle Copilot auto trigger",
      },
    },
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          prev = "<C-p>",
          next = "<C-n>",
          dismiss = "<C-e>",
        },
      },
      filetypes = {
        rust = true,
        python = true,
        bash = true,
        lua = true,
        nix = true,
        ["*"] = false,
      },
    },
    init = function()
      -- Define suggestion accept function
      LazyVim.cmp.actions.ai_accept = function()
        if require("copilot.suggestion").is_visible() then
          LazyVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end

      -- Dismiss copilot suggestion when cmp menu is opened
      local cmp = require("blink.cmp.completion.list")
      cmp.show_emitter:on(function()
        require("copilot.suggestion").dismiss()
        vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
      end)
      cmp.hide_emitter:on(function()
        vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
      end)
    end,
  },

  -- Code Companion (chat, agentic workflows etc.)
  {
    "olimorris/codecompanion.nvim",
    enabled = settings.copilot_enabled,
    opts = {
      adapters = {
        http = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-sonnet-4",
                },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          variables = {
            ["buffer"] = {
              opts = {
                -- Always sync the buffer by sharing its "diff"
                default_params = "diff",
              },
            },
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "Toggle Code Companion chat buffer",
      },
      {
        "<leader>ac",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Open new Code Companion chat buffer",
      },
      {
        "<leader>ap",
        "<cmd>CodeCompanionActions<cr>",
        desc = "Open Code Companion actions palette",
      },
      {
        "<leader>ai",
        "<cmd>CodeCompanionChat Add<cr>",
        desc = "Insert visual selection into the Code Companion chat buffer",
      },
    },
  },

  -- Copilot / Codeium indicator in statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      if settings.copilot_enabled then
        table.insert(
          opts.sections.lualine_x,
          2,
          LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
            local clients = package.loaded["copilot"] and vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
            if #clients > 0 then
              local status = require("copilot.status").data.status
              return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
            end
          end)
        )
      end
    end,
  },
}
