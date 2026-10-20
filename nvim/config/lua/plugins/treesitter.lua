-- Syntax highlight via tree-sitter (branch main; requer o binário `tree-sitter`)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()
      ts.install({
        "lua", "vim", "vimdoc", "bash", "python", "javascript", "typescript", "tsx",
        "json", "yaml", "toml", "markdown", "markdown_inline", "html", "css",
        "go", "rust", "c", "cpp", "llvm", "make", "cmake", "dockerfile", "regex", "diff", "gitcommit",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
