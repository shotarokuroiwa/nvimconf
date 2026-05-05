return {
  {
    "simeji/winresizer",
  },
  -- FIXME: wanna get plugins which preview doesnt overwrap on color code
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("ibl").setup()
    end,
  },
  {
    'junegunn/vim-easy-align',
    config = function()
      vim.keymap.set('v', 'ga', '<Plug>(EasyAlign)')
      vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
    end,
  },
  -- {
  --   "kylechui/nvim-surround",
  --   version = "*", -- Use for stability; omit to use `main` branch for the latest features
  --   event = "VeryLazy",
  --   config = function()
  --     require("nvim-surround").setup({
  --       -- Configuration here, or leave empty to use defaults
  --     })
  --   end
  -- }
}
