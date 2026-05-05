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

-- ターミナル
map("n", "<C-j>", ":vsplit | wincmd l | terminal powershell<CR>", { desc = "Terminal (vertical)" })

-- leager+g+gで先頭行頭へ
-- visualモードで行末へ
map("n", "gg", "gg0", opts)
map("v", "G", "G$", opts)

-- 画面移動左右
map("n", "<M-h>", "<C-w>h", opts)
map("n", "<M-l>", "<C-w>l", opts)

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