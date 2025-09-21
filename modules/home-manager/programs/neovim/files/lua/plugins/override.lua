return {
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "mason-org/mason.nvim",
    enabled = vim.fn.executable("nix") ~= 1,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    enabled = vim.fn.executable("nix") ~= 1,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
