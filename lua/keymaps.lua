local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- esc
map("i", "fj", "<Esc>", opts)
map("t", "fj", [[<C-\><C-n>]], opts)

-- Shift+Enter を明示的に改行に割り当て（以前は有効だった挙動を復元）
map("i", "<S-CR>", "<C-o>o", opts)
vim.keymap.set("t", "<S-CR>", function()
  local chan = vim.b.terminal_job_id
  if chan then
    vim.fn.chansend(chan, "\n")
  end
end, opts)

-- カーソル移動上下逆転
map("n", "j", "k", { noremap = true })
map("v", "j", "k", { noremap = true })
map("t", "j", "j", { noremap = true })

map("n", "k", "j", { noremap = true })
map("v", "k", "j", { noremap = true })
map("t", "k", "k", { noremap = true })

-- マウスホイールのように画面だけスクロールする（カーソルは画面外に出るまで同じ行に留まる）
-- Shift+J=上 / Shift+K=下（j/k 逆転に合わせる）。ホイール1ノッチと同じ3行ずつ動かす
-- ※ 標準の J（行結合）と K（LSP ホバー）は上書きされる
map("n", "J", "3<C-y>", opts)
map("n", "K", "3<C-e>", opts)
map("v", "J", "3<C-y>", opts)
map("v", "K", "3<C-e>", opts)

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
local function make_terminal_toggle(split_cmd, fix)
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

    -- 他の分割が増えてもサイズが再分配されないよう固定する
    if fix == "width" then
      vim.wo[term.win].winfixwidth = true
    elseif fix == "height" then
      vim.wo[term.win].winfixheight = true
    end

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

-- 右に縦分割（<C-k>）。幅を固定して Claude カラムと取り合っても細くならないようにする
local toggle_term_vertical = make_terminal_toggle("botright vsplit", "width")
vim.keymap.set("n", "<C-k>", toggle_term_vertical, { noremap = true, silent = true, desc = "Terminal toggle (vertical)" })
vim.keymap.set("t", "<C-k>", toggle_term_vertical, { noremap = true, silent = true, desc = "Terminal toggle (vertical)" })

-- 下に横分割（<C-j>）。botright で画面下端にフル幅で開き、Claude カラムの内側に
-- 入れ子にならないようにする（入れ子になると Claude の TUI が崩れて入力不能に見える）
local toggle_term_horizontal = make_terminal_toggle("botright split", "height")
vim.keymap.set("n", "<C-j>", toggle_term_horizontal, { noremap = true, silent = true, desc = "Terminal toggle (horizontal bottom)" })
vim.keymap.set("t", "<C-j>", toggle_term_horizontal, { noremap = true, silent = true, desc = "Terminal toggle (horizontal bottom)" })

-- Claude Code の端末ウィンドウは幅を固定し、他の分割が増えても細くならないようにする
-- （claudecode.nvim の native provider は winfixwidth を設定しないため、ここで補う）
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(args)
    if vim.api.nvim_buf_get_name(args.buf):match("claude") then
      vim.schedule(function()
        local win = vim.fn.bufwinid(args.buf)
        if win ~= -1 then
          vim.wo[win].winfixwidth = true
        end
      end)
    end
  end,
})

-- Claude Code 等のフルスクリーン TUI を「キーボードで」スクロールする。
-- TUI は代替スクリーンを使うため Neovim 側ではスクロールできないが、
-- マウスホイールと同じ SGR エスケープシーケンスを端末ジョブへ直接送ることで、
-- TUI に「ホイール操作」と認識させてスクロールさせる（mouse 設定・モード切替は不要）。
local function term_wheel(seq, count)
  return function()
    local chan = vim.b.terminal_job_id
    if not chan then return end
    vim.fn.chansend(chan, string.rep(seq, count or 3))
  end
end

-- SGR マウス: 64=ホイール上 / 65=ホイール下（位置 1;1）。j=上 / k=下 の規約に合わせる
vim.keymap.set("t", "<A-j>", term_wheel("\27[<64;1;1M", 3), opts) -- 上へスクロール
vim.keymap.set("t", "<A-k>", term_wheel("\27[<65;1;1M", 3), opts) -- 下へスクロール

-- 端末内で動かす TUI 版 nvim では、ホスト端末が Ctrl+C を「コンソール制御イベント」
-- として食ってしまい、内蔵ターミナルジョブへ 0x03 が転送されないことがある
-- （neovide/GUI では発生しない）。キーイベントを捕まえて 0x03 を明示送出して回避する。
vim.keymap.set("t", "<C-c>", function()
  local chan = vim.b.terminal_job_id
  if chan then vim.fn.chansend(chan, "\3") end
end, { noremap = true, silent = true, desc = "Send Ctrl+C (0x03) to terminal job" })

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

-- ===========================================================================
-- VSCode (vscode-neovim) 用の上書き
-- Neovim 内蔵のターミナル/分割ウィンドウは VSCode では使えないため、
-- 対応する VSCode コマンドに割り当て直す。
-- （このブロックは前方の定義より後に置くことで上書きする）
-- ===========================================================================
if vim.g.vscode then
  local vscode = require("vscode")

  -- ターミナルパネルのトグル（元: <C-j>/<C-k> の Neovim ターミナル）
  vim.keymap.set("n", "<C-j>", function() vscode.action("workbench.action.terminal.toggleTerminal") end, opts)
  vim.keymap.set("n", "<C-k>", function() vscode.action("workbench.action.terminal.toggleTerminal") end, opts)

  -- 領域間のフォーカス移動（ツリー/エディタ/パネル/AIチャット）は
  -- フォーカス位置に依存せず効く必要があるため keybindings.json 側で
  -- Alt+h/j/k/l・Alt+t・Alt+a に設定している（ここでは扱わない）。
end
