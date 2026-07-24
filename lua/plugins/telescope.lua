return {
  "nvim-telescope/telescope.nvim",
  lazy = false,
  priority = 10000,
  keys = {
    { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Telescope find_files" },
    { "<leader>g", "<cmd>Telescope live_grep<cr>", desc = "Telescope live_greps" },
    { "<leader>r", "<cmd>Telescope resume<cr>", desc = "Telescope Resume" },
    { "<leader>b", "<cmd>Telescope pickers<cr>", desc = "Telescope Previous Picker" },
    { "<leader>f", "<cmd>Telescope quickfix<cr>", desc = "Telescope Quixfix" },
    { "<leader>H", "<cmd>Telescope help_tags<cr>", desc = "Telescope Help Tags" },
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = {
      winblend = 50,
      -- ファイル名を先頭に表示して、深い階層のファイルも見つけやすくする
      -- （フィルタは従来どおりディレクトリを含むパス全体に効く）
      path_display = { "filename_first" },
      mappings = {
        i = {
          -- insert モードでは "q" を文字入力として使えるようにし、
          -- 閉じるのは入力の邪魔にならない <C-q> に割り当てる
          ["<C-q>"] = require("telescope.actions").close,
        },
        n = {
          ["q"] = require("telescope.actions").close,
        },
      },
    },
    pickers = {
      colorscheme = {
        enable_preview = true,
      }
    }
  }
}
