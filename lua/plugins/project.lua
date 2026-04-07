return {
  "ahmedkhalf/project.nvim",
  lazy = false,
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("project_nvim").setup {
      manual_mode = false,
      detection_methods = { "pattern", "lsp" },
      patterns = { ".git", "Makefile", "package.json", "pyproject.toml", "rust-project.json" },
      exclude_dirs = {},
      show_hidden = true,
      silent_chdir = true,
      datapath = vim.fn.stdpath("data"),
    }

    local ok, telescope = pcall(require, "telescope")
    if ok then
      telescope.load_extension("projects")
    end
  end,
  keys = {
    { "<leader>o", "<cmd>Telescope projects<cr>", desc = "Recent projects" },
  },
}
