local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- esc
map("i", "fj", "<Esc>", opts)
map("t", "fj", [[<C-\><C-n>]], opts)

-- カーソル移動上下逆転
map("n", "j", "k", { noremap = true })
map("v", "j", "k", { noremap = true })
map("t", "j", "j", { noremap = true })

map("n", "k", "j", { noremap = true })
map("v", "k", "j", { noremap = true })
map("t", "k", "k", { noremap = true })

-- 行移動逆転
map("n", "<A-k>", ":m .+1<CR>==", opts)
map("n", "<A-j>", ":m .-2<CR>==", opts)

-- 複数行の移動（ビジュアルモード）
map("v", "<A-k>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-j>", ":m '<-2<CR>gv=gv", opts)

-- 括弧やクォーテーションの外に出る
map("i", "<a-l>", "<Right>", opts)

-- ターミナル（トグル式：隠してもバッファは消えず、再度開くと続きから）
-- split_cmd ごとに独立したバッファを保持するトグル関数を生成する
local function make_terminal_toggle(split_cmd)
  local term = { buf = nil, win = nil }
  return function()
    -- 表示中ならウィンドウだけ閉じて隠す（バッファは残す）
    if term.win and vim.api.nvim_win_is_valid(term.win) then
      vim.api.nvim_win_hide(term.win)
      term.win = nil
      return
    end

    -- 指定の分割で開く
    vim.cmd(split_cmd)
    term.win = vim.api.nvim_get_current_win()

    -- バッファが生きていれば再利用、なければ新規作成
    if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
      vim.api.nvim_win_set_buf(term.win, term.buf)
    else
      vim.cmd("terminal powershell")
      term.buf = vim.api.nvim_get_current_buf()
    end
    vim.cmd("startinsert")
  end
end

-- 右に縦分割（<C-j>）
local toggle_term_vertical = make_terminal_toggle("botright vsplit")
vim.keymap.set("n", "<C-j>", toggle_term_vertical, { noremap = true, silent = true, desc = "Terminal toggle (vertical)" })
vim.keymap.set("t", "<C-j>", toggle_term_vertical, { noremap = true, silent = true, desc = "Terminal toggle (vertical)" })

-- 下に横分割（<C-k>）。<C-i> は <Tab>（ジャンプリスト前進）と同一コードなので避ける
local toggle_term_horizontal = make_terminal_toggle("belowright split")
vim.keymap.set("n", "<C-k>", toggle_term_horizontal, { noremap = true, silent = true, desc = "Terminal toggle (horizontal bottom)" })
vim.keymap.set("t", "<C-k>", toggle_term_horizontal, { noremap = true, silent = true, desc = "Terminal toggle (horizontal bottom)" })

-- leager+g+gで先頭行頭へ
-- visualモードで行末へ
map("n", "gg", "gg0", opts)
map("v", "G", "G$", opts)

-- 画面移動左右い
map("n", "<M-h>", "<C-w>h", opts)
map("n", "<M-l>", "<C-w>l", opts)
-- ウィンドウ移動（上下）
map("n", "<M-k>", "<C-w>j", opts) -- Alt + j で下のウィンドウへ
map("n", "<M-j>", "<C-w>k", opts) -- Alt + k で上のウィンドウへ


-- 現在のパス
vim.keymap.set('c', '%%', "getcmdtype() == ':' ? expand('%:p:h') .. '/' : '%%'", { expr = true })

-- 一括変換
map("n", "<Leader>s", ":%s/", { noremap = true })
map("v", "<Leader>s", ":s/", { noremap = true })

-- Leader + Enter で検索ハイライトを消す
map("n", "<Leader><CR>", ":nohlsearch<CR>", opts)

-- 開いている全てのファイルで一括置換を開始
map("n", "<Leader>sa", ":bufdo %s/\\v", { noremap = true })

-- インデントを連続して変更できる(< >で連続して移動させることができる)
map('v', '<', '<gv', opts)
map('v', '>', '>gv', opts)

-- ビジュアルモード(x)で選択中に、特定のキーでコメントを揃える設定
-- ここでは <Leader>a （デフォルトは \a）に割り当てています
map('x', '<Leader>a', ':EasyAlign / \\/\\//<CR>', opts)