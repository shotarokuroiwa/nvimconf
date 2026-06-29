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
      -- フローティングウィンドウの透明度（0=不透明, 100=完全透過）
      vim.g.lazygit_floating_window_winblend = 50
      -- Leader + gg で Lazygit を起動
      vim.api.nvim_set_keymap("n", "<Leader>v", ":LazyGit<CR>", { noremap = true, silent = true })
    end,
  },
}
