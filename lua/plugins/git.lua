return {
  {
    'tpope/vim-fugitive',
  },
  { 'tpope/vim-rhubarb' }, -- open browser for git repo
  { 'akinsho/git-conflict.nvim', version = "*", config = true },
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Leader + gg で Lazygit を起動
      vim.api.nvim_set_keymap("n", "<Leader>v", ":LazyGit<CR>", { noremap = true, silent = true })
    end,
  },
}
