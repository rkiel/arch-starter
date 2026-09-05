return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",

    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.install({
        "bash",
        "css",
        "erb",
        "html",
        "javascript",
        "json",
        "lua",
        "ruby",
        "sql",
        "yaml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}