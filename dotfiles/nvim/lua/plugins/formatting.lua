return {
  {
    "stevearc/conform.nvim",

    opts = {
      formatters_by_ft = {
        ruby = { "rubocop" },
      },

      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },
}