-- LSP + autocomplete
return {
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = "BufReadPre",
    opts = { ensure_installed = { "lua_ls", "pyright", "ts_ls", "gopls", "bashls" } },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = { keymap = { preset = "default" }, sources = { default = { "lsp", "path", "buffer" } } },
  },
}
