return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" }, -- ターミナル表示に使用（任意）
  opts = {
    terminal = {
      provider = "native",          -- Snacks ではなく Neovim ネイティブ端末を使用
      split_side = "right",         -- 右側に開く
      split_width_percentage = 0.5,   -- 画面の半分の幅
    },
    diff_opts = {
      -- 修正案を「上下分割」で表示（元ファイル=上 / 修正案=下）。
      -- 追加行・削除行が同じ縦並びの一画面に収まり、
      -- 修正画面は現在のウィンドウの下（他ファイルが開いていれば左画面の下半分）に開く。
      layout = "horizontal",
      open_in_new_tab = false,       -- 新しいタブではなく現在のタブに開く
    },
  },
  keys = {
    { "<leader>a",  nil,                              desc = "AI/Claude Code" },
    -- ノーマル/ターミナル両モードでトグル（Claude の端末内からも同キーで閉じられる）
    { "<C-n>", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude Code" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                 desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil" },
    },
    -- 差分の承認 / 拒否
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
  },
}
