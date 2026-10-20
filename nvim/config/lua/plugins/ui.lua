return {
  -- tema
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night", transparent = false },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = { options = { theme = "tokyonight", globalstatus = true,
      component_separators = "", section_separators = { left = "", right = "" } } },
  },

  -- abas de buffers
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = { options = { diagnostics = "nvim_lsp", offsets = {
      { filetype = "neo-tree", text = "Arquivos", highlight = "Directory", separator = true } } } },
  },


  -- dicas de atalhos
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- git na margem
  { "lewis6991/gitsigns.nvim", event = "BufReadPre", opts = {} },

  -- explorador de arquivos
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = { { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorador" } },
    opts = { filesystem = { filtered_items = { visible = true } } },
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Buscar arquivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Buscar texto" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Ajuda" },
    },
  },

  -- pares automáticos e comentários
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
}
