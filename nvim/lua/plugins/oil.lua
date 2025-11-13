return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>o",
      function()
        require("oil").open()
      end,
      desc = "[F]ormat buffer",
    },
  },
  opts = {
    default_file_explorer = true,
    skip_confirm_for_simple_edit = true,
    view_options = {
      show_hidden = true,
    },
  },
}
