local settings = require("config.settings")

return {
  -- Base copilot plugin
  {
    "zbirenbaum/copilot.lua",
    enabled = settings.copilot_enabled and not settings.copilot_official,
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
          accept_line = "<C-m>",
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

  -- Copilot chat plugin
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enable = settings.copilot_enabled,
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatToggle",
      "CopilotChatExplain",
      "CopilotChatTests",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatFixDiagnostic",
      "CopilotChatCommit",
      "CopilotChatCommitStaged",
      "CopilotChatBuffer",
    },
    opts = {
      proxy = os.getenv("http_proxy"),
      name = "Copilot",
      selection = function(source)
        return require("CopilotChat.select").visual(source)
      end,
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")

      -- Override default prompts
      opts.prompts = {
        Commit = {
          prompt = "Write commit message for the changes using conventional commit format",
          selection = select.gitdiff,
        },
        CommitStaged = {
          prompt = "Write commit message for the changes using conventional commit format",
          selection = function(source)
            return select.gitdiff(source, true)
          end,
        },
      }
      chat.setup(opts)

      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })
    end,
    keys = {
      {
        "<leader>av",
        function()
          local input = vim.fn.input("Chat about selection: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "Copilot chat about visual selection",
        mode = "v",
      },
      {
        "<leader>ab",
        function()
          local input = vim.fn.input("Chat about the buffer: ")
          if input ~= "" then
            vim.cmd("CopilotChatBuffer " .. input)
          end
        end,
        desc = "Copilot chat about current buffer",
      },
    },
  },

  -- Codeium (alternative to Copilot)
  {
    "Exafunction/codeium.vim",
    enabled = settings.codeium_enabled,
    cmd = "Codeium",
    event = "BufEnter",
    keys = {
      {
        "<leader>at",
        "<cmd>Codeium Toggle<cr>",
        desc = "Toggle Codeium auto trigger",
      },
    },
    config = function()
      vim.g.codeium_disable_bindings = 1
      vim.g.codeium_filetypes_disabled_by_default = 1
      vim.g.codeium_filetypes = {
        rust = true,
        python = true,
        bash = true,
        lua = true,
        dart = true,
        nix = true,
      }
      vim.keymap.set("i", "<C-y>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-n>", function()
        return vim.fn["codeium#CycleOrComplete"]()
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-p>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-e>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true, silent = true })
    end,
  },

  {
    "github/copilot.vim",
    enabled = settings.copilot_enabled and settings.copilot_official,
    lazy = false,
    init = function()
      -- Settings
      vim.g.copilot_filetypes = {
        ["*"] = false,
        rust = true,
        python = true,
        bash = true,
        lua = true,
        nix = true,
      }
      vim.g.copilot_no_tab_map = true
      -- Keymaps
      vim.keymap.set("i", "<C-n>", "<Plug>(copilot-next)")
      vim.keymap.set("i", "<C-p>", "<Plug>(copilot-next)")
      vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)")
      vim.keymap.set("i", "<C-a>", "<Plug>(copilot-suggest)")

      -- Dismiss copilot suggestion when cmp menu is opened
      local cmp = require("blink.cmp.completion.list")
      cmp.show_emitter:on(function()
        vim.cmd([[
          if copilot#Enabled()
            call copilot#Dismiss()
          endif
        ]])
      end)

      -- Define suggestion accept function
      LazyVim.cmp.actions.ai_accept = function()
        if vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
          LazyVim.create_undo()
          vim.fn.feedkeys(vim.fn["copilot#Accept"]())
          return true
        end
      end
    end,
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
            local clients = package.loaded["copilot"] and LazyVim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
            if #clients > 0 then
              local status = require("copilot.api").status.data.status
              return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
            end
          end)
        )
      end

      if settings.codeium_enabled then
        table.insert(opts.sections.lualine_x, 2, {
          function()
            local icon = require("lazyvim.config").icons.kinds.Codeium
            local status = vim.api.nvim_call_function("codeium#GetStatusString", {})
            return icon .. status
          end,
        })
      end
    end,
  },
}
