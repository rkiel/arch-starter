return {
  {
    "neovim/nvim-lspconfig",

    config = function()
      vim.lsp.enable("ruby_lsp")
    end,
  },
}

-- instead, let each Rails application's Gemfile determine its RuboCop version:

--   gem "rubocop", require: false
-- end