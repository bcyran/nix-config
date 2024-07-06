return {
  {
    "nvimdev/dashboard-nvim",
    enabled = false,
  },
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "williamboman/mason.nvim",
    enabled = vim.fn.executable("nix") ~= 1,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = vim.fn.executable("nix") ~= 1,
  },
}
