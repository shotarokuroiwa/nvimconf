return {
  "coder/claudecode.nvim",
 dependencies = { "folke/snacks.nvim" }, -- ターミナル表示に使用（任意）
  opts = {
    terminal = {
      provider = "native",          -- Snacks ではなく Neovim ネイティブ端末を使用
      split_side = "right",         -- 右側に開く
      split_width_percentage = 0.5,   -- 画面の半分の幅
    },
  },
  -- 差分はエディタではなく Claude Code のターミナル内に表示させている。
  -- これは Neovim 側ではなく CLI 側の設定:
  --   /config -> Connections -> Diff tool = terminal
  -- （CLI は「IDE が接続されているか」だけを見て差分の出し先を決めるので、
  --   プラグイン側の diff_opts では制御できない）
  keys = {
    { "<leader>a",  nil,                              desc = "AI/Claude Code" },
    -- ノーマル/ターミナル両モードでトグル（Claude の端末内からも同キーで閉じられる）
    { "<C-n>", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude Code" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    -- モデル切り替え（引数はそのまま claude CLI に渡される）
    { "<leader>m", "<cmd>ClaudeCode --model opus<cr>",  desc = "Claude: Opus 4.8" },
    { "<leader>M", "<cmd>ClaudeCode --model fable<cr>", desc = "Claude: Fable 5（最上位）" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                 desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil" },
    },
    -- 差分はターミナル内で承認 / 拒否するので、
    -- エディタ側の差分キーマップ（<leader>aa / ad / au）は不要になった。
  },
}
