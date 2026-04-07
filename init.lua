require('base')
require('keymaps')
require('filetype')
require("config.lazy")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { 
    "python",
    "lua", 
    "javascript",
    "typescript",
    "css",
    "c",
    "ruby",
    "json",
    "markdown",
    },
  callback = function()
    vim.treesitter.start()
  end,
})