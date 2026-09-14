-- OpenAI Codex CLI 連携。claudecode.lua と同じ操作感になるように設定している。
--   ・右側に画面半分の縦分割でターミナルを開く
--   ・1 つのキーでトグル（Codex の端末内からも同じキーで閉じる）
--   ・<leader>x を Codex 用のプレフィックスにする（Claude は <leader>a）
-- 事前に Codex CLI が PATH 上に必要:  npm i -g @openai/codex
--
-- 本家は対応 OS を macOS / Linux としており、Windows では 2 か所ひっかかる。
-- どちらも下で回避しているが、本家が Windows 対応したら外してよい:
--   1. `codex`（拡張子なしの sh スクリプト）は Windows では起動できないので
--      `codex.cmd` を呼ぶ            -> cmd = { "codex.cmd" }
--   2. パス絶対判定が POSIX 前提で `C:/...` を相対扱いしてしまう
--                                     -> init で codex.cwd を差し替え
local is_windows = vim.fn.has("win32") == 1

return {
  "nwiizo/codex.nvim",
  init = function()
    -- codex.cwd が本家のまま読み込まれる前に、修正版へ差し替えておく
    if is_windows then
      package.loaded["codex.cwd"] = require("config.codex_cwd_windows")
    end
    require("config.codex_terminal").setup()
  end,
  -- keys から `<cmd>Codex...<cr>` を叩くため、遅延ロード用にコマンドを列挙しておく
  cmd = {
    "Codex", "CodexOpen", "CodexClose", "CodexFocus", "CodexResume", "CodexContinue",
    "CodexFork", "CodexReview", "CodexImage", "CodexPrompt", "CodexSend",
    "CodexSendVisual", "CodexAddVisual", "CodexAdd", "CodexTreeAdd", "CodexSendText",
    "CodexDiff", "CodexInterrupt", "CodexStatus", "CodexStop", "CodexHealth",
  },
  opts = {
    backend = "terminal", -- Codex の TUI をそのまま端末で動かす（app-server は実験的）
    cmd = is_windows and { "codex.cmd" } or { "codex" },
    terminal = {
      layout = "split",             -- フロートではなく分割
      split_side = "right",         -- 右側に開く
      split_width_percentage = 0.5, -- 画面の半分の幅（claudecode と同じ）
      auto_insert = true,
      auto_close = true,
      -- 入力中の fj は文字として通す。ノーマルモードへは <C-\><C-n>、
      -- 開閉は下の <C-g> を使う。

      -- 端末からのウィンドウ移動。keymaps.lua で <M-j>/<M-k> を
      -- 「上/下」逆に割り当てているので、それに合わせて入れ替える
      window_navigation = {
        left  = "<M-h>",
        down  = "<M-k>",
        up    = "<M-j>",
        right = "<M-l>",
      },
    },
  },
  keys = {
    { "<leader>x",  nil,                                desc = "AI/Codex" },
    -- ノーマル/ターミナル両モードでトグル（Codex の端末内からも同キーで閉じられる）。
    -- Claude の <C-n> に対して Codex は <C-g>
    { "<C-g>",      "<cmd>Codex<cr>",                   mode = { "n", "t" }, desc = "Toggle Codex" },
    { "<leader>xf", "<cmd>CodexFocus<cr>",              desc = "Focus Codex" },
    { "<leader>xr", "<cmd>CodexResume<cr>",             desc = "Resume Codex（セッション選択）" },
    { "<leader>xC", "<cmd>CodexContinue<cr>",           desc = "Continue Codex（直近セッション）" },
    { "<leader>xb", "<cmd>CodexAdd %<cr>",              desc = "Add current buffer" },
    { "<leader>xd", "<cmd>CodexDiff<cr>",               desc = "Show latest diff" },
    { "<leader>xi", "<cmd>CodexInterrupt<cr>",          desc = "Interrupt Codex" },
    -- モデル切り替え（引数はそのまま codex CLI に渡される）。
    -- 引数が効くのはセッション未起動のとき。起動済みなら :CodexStop で落としてから使う。
    -- 使えるモデル名は TUI の `/model` か ~/.codex/models_cache.json で確認できる
    { "<leader>xm", "<cmd>Codex --model gpt-5.6-terra<cr>", desc = "Codex: GPT-5.6-Terra（標準）" },
    { "<leader>xM", "<cmd>Codex --model gpt-6-astra<cr>",   desc = "Codex: GPT-6-Astra（最上位）" },
    -- 選択範囲を送る（CodexSendVisual は選択そのままを送信）
    { "<leader>xs", "<cmd>CodexSendVisual<cr>",         mode = "v", desc = "Send to Codex" },
    -- 送信せずに選択範囲を入力欄へ挿入（Codex 側で書き足してから送りたいとき）
    { "<leader>xa", "<cmd>CodexAddVisual<cr>",          mode = "v", desc = "Add selection to Codex" },
    {
      "<leader>xs",
      "<cmd>CodexTreeAdd<cr>",
      desc = "Add file",
      -- NvimTree では `m` で複数マークしておくとまとめて渡せる
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    },
  },
}
