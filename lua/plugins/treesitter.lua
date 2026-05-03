-- lua/plugins/treesitter.lua
vim.env.CC = "gcc"

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  lazy = false, 
  build = ":TSUpdate",
  config = function()

    local ok, configs = pcall(require, 'nvim-treesitter')
    if not ok then 
      return 
    end

    configs.setup({
      ensure_installed = {
        "python",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
        "ruby",
        "php",
        "go",
        "gotmpl",
        "gomod",
        "gosum",
        "zig",
        "tsx",
        "jsx",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "html",
        "css",
        "sql",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "graphql",
        "c",
        "cpp",
        "c_sharp",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
